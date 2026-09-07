# Caches flattened path geometry per icon: local x/y coordinates, id.lengths grouping, and fill rule.
# Runs pictureGrob() once per unique icon and caches its raw coordinates, instead of recomputing per row.
icon_geometry_cache <- new.env(parent = emptyenv())

get_icon_geometry <- function(path) {
  if (is.na(path)) {
    return(NULL)
  }

  cached <- icon_geometry_cache[[path]]
  if (!is.null(cached)) {
    return(cached)
  }

  geom <- build_icon_geometry(path)
  icon_geometry_cache[[path]] <- geom
  geom
}

build_icon_geometry <- function(path) {
  pic <- get_icon_converted(path)
  if (is.null(pic)) {
    return(NULL)
  }

  # No padding, same aspect-ratio handling as a normal draw. Colour is applied later per row, not baked in here.
  g <- grImport2::pictureGrob(
    pic,
    x = 0.5, y = 0.5, width = 1, height = 1,
    default.units = "npc", expansion = 0, distort = FALSE, gpFUN = identity
  )

  shapes <- collect_picpaths(g)
  if (length(shapes) == 0) {
    cli::cli_warn(c(
      "Icon at {.file {path}} has no fillable path data.",
      "i" = "Only SVG {.code <path>} elements are supported; the icon will be skipped."
    ))
    return(NULL)
  }

  rules <- unique(vapply(shapes, function(s) s$rule, character(1)))
  if (length(rules) > 1) {
    cli::cli_warn(c(
      "Icon at {.file {path}} mixes multiple path fill rules.",
      "i" = "ggicons can only draw a single icon shape with one fill rule; the icon will be skipped."
    ))
    return(NULL)
  }

  # The icon's viewBox bounds, pre-flipped to convert SVG's y-down coordinates into grid's y-up convention.
  xr <- pic@summary@xscale
  yr <- pic@summary@yscale

  x <- unlist(lapply(shapes, `[[`, "x"))
  y <- unlist(lapply(shapes, `[[`, "y"))
  # id.lengths is NULL for a single-subpath shape; fill it in explicitly before concatenating.
  id.lengths <- unlist(lapply(shapes, function(s) s$id.lengths %||% length(s$x)))

  list(
    x = (x - xr[1]) / (xr[2] - xr[1]) - 0.5,
    y = (yr[1] - y) / (yr[1] - yr[2]) - 0.5,
    id.lengths = id.lengths,
    rule = rules
  )
}

# Depth-first walk collecting every picPath grob, the fill-region primitive for an SVG path element.
collect_picpaths <- function(grob, out = list()) {
  if (inherits(grob, "picPath")) {
    out[[length(out) + 1]] <- grob
  }
  children <- tryCatch(grid::childNames(grob), error = function(e) character())
  for (child_name in children) {
    out <- collect_picpaths(grid::getGrob(grob, child_name), out)
  }
  out
}
