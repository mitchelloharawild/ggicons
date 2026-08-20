# Build the grob for a whole geom_icon() layer -- one row per element of
# the vectors below (also used with length-1 vectors for a single icon,
# e.g. draw_key_icon()). Rather than one gTree+viewport+pictureGrob per row
# (grImport2's own recolour/reposition mechanism), every row's icon is
# transformed by hand from its cached local geometry (see icon-geometry.R)
# and drawn with as few grid::pathGrob() calls as the icons' fill rules
# allow -- one per distinct rule among the rows actually drawn, typically
# just one for a whole layer. That turns an O(n) sequence of grid draw
# calls into O(1) (or O(distinct rules)), which is where the real cost was:
# grImport2::pictureGrob() rebuilds its entire path tree from scratch on
# every call, even for an already-cached grImport2::Picture.
#
# The `size` aesthetic is in an absolute unit (size.unit, default "mm"),
# but this function runs at grob-*construction* time (inside draw_panel()),
# before ggplot2's gtable has pushed the actual panel viewport -- so mm
# can't be safely converted to npc here; whatever viewport happens to be
# active on the device at that point is not necessarily the panel's. That
# conversion is deferred to a lazy "iconpath" grob (see makeContent.iconpath
# below), resolved once real drawing starts and the correct viewport is
# current -- the same trick grid uses for `viewport(width = unit(x, "mm"))`,
# and grImport2 for its own pictureGrob() sizing.
#
# The conversion is deliberately *not* done via grid's unit arithmetic
# (`unit(x, "npc") + unit(y, "mm")` per point) either: profiling showed
# `Ops.unit` dominates cost at this scale, eating most of the win from
# batching. One `convertWidth()` call up front, then plain numeric
# arithmetic, is both correct and fast.
icon_grob <- function(path, x, y, size, colour, fill, alpha, angle,
                       size.unit = "mm") {
  # Callers always pass `path` as a plain character vector of SVG file
  # paths, already resolved from the `icon` aesthetic's icon vector via
  # icons::icon_path() (see geom-icon.R / draw-key-icon.R).
  n <- max(
    length(path), length(x), length(y), length(size),
    length(colour), length(fill), length(alpha), length(angle)
  )
  path <- rep_len(path, n)
  x <- rep_len(x, n)
  y <- rep_len(y, n)
  size <- rep_len(size, n)
  angle <- rep_len(angle, n)

  fill_colour <- ifelse(is.na(fill), colour, fill)
  fill_colour <- rep_len(scales::alpha(fill_colour, alpha), n)

  geoms <- lapply(path, get_icon_geometry)
  valid <- !is.na(path) & !is.na(x) & !is.na(y) & !is.na(size) &
    !vapply(geoms, is.null, logical(1))
  if (!any(valid)) {
    return(grid::nullGrob())
  }

  vx <- x[valid]
  vy <- y[valid]
  vsize <- size[valid]
  vfill <- fill_colour[valid]
  vgeoms <- geoms[valid]

  radians <- angle[valid] * pi / 180
  cosA <- cos(radians)
  sinA <- sin(radians)

  # rule is one setting per pathGrob() call, not per icon instance, so
  # icons whose fill rules differ (rare -- see icon-geometry.R) need
  # separate calls. In the common case (every icon uses the same rule)
  # this is a single grob for the entire layer.
  rules <- vapply(vgeoms, `[[`, character(1), "rule")
  shape_grobs <- lapply(split(seq_along(vgeoms), rules), function(idx) {
    npts <- vapply(vgeoms[idx], function(g) length(g$x), integer(1))
    local_x <- local_y <- numeric(sum(npts))

    pos <- 0
    for (j in seq_along(idx)) {
      i <- idx[[j]]
      g <- vgeoms[[i]]
      k <- length(g$x)
      rng <- (pos + 1):(pos + k)
      # Rotated, but *not* yet scaled by size -- that needs an mm-to-npc
      # factor only known at draw time (see makeContent.iconpath).
      local_x[rng] <- g$x * cosA[[i]] - g$y * sinA[[i]]
      local_y[rng] <- g$x * sinA[[i]] + g$y * cosA[[i]]
      pos <- pos + k
    }

    iconpath_grob(
      local_x = local_x, local_y = local_y,
      pos_x = rep(vx[idx], npts), pos_y = rep(vy[idx], npts),
      size = rep(vsize[idx], npts), size.unit = size.unit,
      id.lengths = unlist(lapply(vgeoms[idx], `[[`, "id.lengths")),
      pathId.lengths = npts,
      rule = vgeoms[[idx[[1]]]]$rule,
      gp = grid::gpar(fill = vfill[idx], col = NA)
    )
  })

  ggname("geom_icon", grid::gTree(children = do.call(grid::gList, shape_grobs)))
}

# A grob that defers icon sizing to draw time: `local_x`/`local_y` are
# rotated but unscaled icon-shape coordinates, `size`/`size.unit` an
# absolute-unit scale factor per point. makeContent() below turns this into
# a plain grid::pathGrob() once, at the point grid actually resolves it
# against the real (panel) viewport -- a gTree with no children yet, filled
# in lazily, the same pattern grImport2's own pictureGrob(ext = "gridSVG")
# uses via makeContent.PictureGrob()/setChildren().
iconpath_grob <- function(local_x, local_y, pos_x, pos_y, size, size.unit,
                           id.lengths, pathId.lengths, rule, gp) {
  grid::gTree(
    local_x = local_x, local_y = local_y, pos_x = pos_x, pos_y = pos_y,
    size = size, size.unit = size.unit,
    id.lengths = id.lengths, pathId.lengths = pathId.lengths, rule = rule,
    gp = gp, cl = "iconpath"
  )
}

#' @exportS3Method grid::makeContent
makeContent.iconpath <- function(x) {
  # npc is fraction-of-viewport-*width* on x and fraction-of-viewport-
  # *height* on y -- the same size in "npc" only maps to the same physical
  # length on both axes when the panel happens to be square. Converting
  # separately per axis (and applying each factor to its own coordinate)
  # keeps icons at their original proportions regardless of panel aspect
  # ratio; a single shared factor would stretch/squish them to match it.
  size_npc_x <- grid::convertWidth(grid::unit(x$size, x$size.unit), "npc", valueOnly = TRUE)
  size_npc_y <- grid::convertHeight(grid::unit(x$size, x$size.unit), "npc", valueOnly = TRUE)
  path <- grid::pathGrob(
    x$pos_x + x$local_x * size_npc_x,
    x$pos_y + x$local_y * size_npc_y,
    id.lengths = x$id.lengths,
    pathId.lengths = x$pathId.lengths,
    rule = x$rule,
    default.units = "npc",
    gp = x$gp
  )
  grid::setChildren(x, grid::gList(path))
}
