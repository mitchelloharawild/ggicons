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
                       size.unit = "mm") {
  # path is a plain character vector of SVG file paths, already resolved from the icon aesthetic.
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
      size = rep(vsize[idx], npts), size.unit = size.unit,
      id.lengths = unlist(lapply(vgeoms[idx], `[[`, "id.lengths")),
      pathId.lengths = npts,
      rule = vgeoms[[idx[[1]]]]$rule,
      gp = grid::gpar(fill = vfill[idx], col = NA)
    )
  })

  ggname("geom_icon", grid::gTree(children = do.call(grid::gList, shape_grobs)))
}

# Defers icon sizing to draw time: local_x/local_y are rotated but unscaled coordinates,
# resolved into a single pathGrob once the real viewport exists.
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
  # Convert size separately per axis so icons keep their proportions regardless of panel aspect ratio.
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
