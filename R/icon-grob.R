# Builds the grob for a whole geom_icon() layer, one row per element of the vectors below
# (also used with length-1 vectors for a single icon).
# Each row's icon is transformed by hand from its cached local geometry and drawn with
# as few pathGrob() calls as the icons' fill rules require, typically just one per layer.
#
# size is in an absolute unit, but this runs before the real panel viewport exists,
# so converting to npc here isn't safe. That conversion is deferred to a lazy "iconpath"
# grob, resolved once real drawing starts.
#
# Plain numeric arithmetic is used instead of grid's unit arithmetic, since profiling
# showed Ops.unit dominates cost at this scale.
icon_grob <- function(path, x, y, size, colour, fill, alpha, angle,
                       size.unit = "mm", offset_x = 0, offset_y = 0, auto_fit = NULL) {
  # path is a plain character vector of SVG file paths, already resolved from the icon aesthetic.
  n <- max(
    length(path), length(x), length(y), length(size),
    length(colour), length(fill), length(alpha), length(angle),
    length(offset_x), length(offset_y)
  )
  path <- rep_len(path, n)
  x <- rep_len(x, n)
  y <- rep_len(y, n)
  size <- rep_len(size, n)
  angle <- rep_len(angle, n)
  offset_x <- rep_len(offset_x, n)
  offset_y <- rep_len(offset_y, n)

  colour <- rep_len(colour, n)
  fill <- rep_len(fill, n)
  fill_colour <- ifelse(is.na(fill), colour, fill)
  fill_colour <- rep_len(scales::alpha(fill_colour, alpha), n)

  geoms <- lapply(path, get_icon_geometry)
  # A NA size is normally an invalid row (nothing to draw), but under auto_fit it's a
  # not-yet-resolved "auto" size instead - keep it in, makeContent.iconpath() resolves it later.
  valid <- !is.na(path) & !is.na(x) & !is.na(y) & (!is.na(size) | !is.null(auto_fit)) &
    !vapply(geoms, is.null, logical(1))
  if (!any(valid)) {
    return(grid::nullGrob())
  }

  vx <- x[valid]
  vy <- y[valid]
  vsize <- size[valid]
  voffset_x <- offset_x[valid]
  voffset_y <- offset_y[valid]
  vfill <- fill_colour[valid]
  vgeoms <- geoms[valid]

  radians <- angle[valid] * pi / 180
  cosA <- cos(radians)
  sinA <- sin(radians)

  # rule applies per pathGrob() call, so icons with different fill rules need separate calls; usually just one.
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
      # Rotated but not yet scaled by size; that needs a factor only known at draw time.
      local_x[rng] <- g$x * cosA[[i]] - g$y * sinA[[i]]
      local_y[rng] <- g$x * sinA[[i]] + g$y * cosA[[i]]
      pos <- pos + k
    }

    iconpath_grob(
      local_x = local_x, local_y = local_y,
      pos_x = rep(vx[idx], npts), pos_y = rep(vy[idx], npts),
      offset_x = rep(voffset_x[idx], npts), offset_y = rep(voffset_y[idx], npts),
      size = rep(vsize[idx], npts), size.unit = size.unit,
      id.lengths = unlist(lapply(vgeoms[idx], `[[`, "id.lengths")),
      pathId.lengths = npts,
      rule = vgeoms[[idx[[1]]]]$rule,
      gp = grid::gpar(fill = vfill[idx], col = NA),
      auto_fit = auto_fit
    )
  })

  ggname("geom_icon", grid::gTree(children = do.call(grid::gList, shape_grobs)))
}

# Defers icon sizing to draw time: local_x/local_y are rotated but unscaled coordinates,
# resolved into a single pathGrob once the real viewport exists.
iconpath_grob <- function(local_x, local_y, pos_x, pos_y, size, size.unit,
                           id.lengths, pathId.lengths, rule, gp,
                           offset_x = 0, offset_y = 0, auto_fit = NULL) {
  grid::gTree(
    local_x = local_x, local_y = local_y, pos_x = pos_x, pos_y = pos_y,
    offset_x = offset_x, offset_y = offset_y,
    size = size, size.unit = size.unit, auto_fit = auto_fit,
    id.lengths = id.lengths, pathId.lengths = pathId.lengths, rule = rule,
    gp = gp, cl = "iconpath"
  )
}

#' @exportS3Method grid::makeContent
makeContent.iconpath <- function(x) {
  size <- x$size
  if (!is.null(x$auto_fit) && anyNA(size)) {
    af <- x$auto_fit
    avail_w <- grid::convertWidth(grid::unit(af$avail_w_npc, "npc"), x$size.unit, valueOnly = TRUE)
    avail_h <- grid::convertHeight(grid::unit(af$avail_h_npc, "npc"), x$size.unit, valueOnly = TRUE)
    auto_size <- min(avail_w / af$grid_w_units, avail_h / af$grid_h_units)
    size <- ifelse(is.na(size), auto_size, size)
  }
  # Convert size separately per axis so icons keep their proportions regardless of panel aspect ratio.
  size_npc_x <- grid::convertWidth(grid::unit(size, x$size.unit), "npc", valueOnly = TRUE)
  size_npc_y <- grid::convertHeight(grid::unit(size, x$size.unit), "npc", valueOnly = TRUE)
  path <- grid::pathGrob(
    x$pos_x + x$offset_x * size_npc_x + x$local_x * size_npc_x,
    x$pos_y + x$offset_y * size_npc_y + x$local_y * size_npc_y,
    id.lengths = x$id.lengths,
    pathId.lengths = x$pathId.lengths,
    rule = x$rule,
    default.units = "npc",
    gp = x$gp
  )
  grid::setChildren(x, grid::gList(path))
}
