# Flattened, cached-per-icon path geometry: local x/y coordinates (unit
# square, y-up, centred on the origin), the `id.lengths` grouping needed to
# render holes via the fill rule, and that rule. This is what lets
# icon_grob() (see icon-grob.R) draw an entire layer with one
# grid::pathGrob() call instead of one grob per row.
#
# grImport2::pictureGrob() computes exactly this (segment flattening,
# subpath bookkeeping, viewBox scaling) internally, but redoes it from
# scratch on every call rather than caching it -- fine for a one-off
# picture, wasteful for the same icon drawn at thousands of rows. So this
# runs pictureGrob() once per unique icon (on top of the already-cached
# grImport2::Picture from icon-convert.R), pulls the resulting shapes' raw
# numeric coordinates back out, and caches *that*. Recolouring/positioning
# still happens later, per row, in icon_grob().
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

  # expansion = 0, distort = FALSE: no padding, same aspect-ratio handling
  # pictureGrob() normally draws with. gpFUN is identity here because
  # colour is applied per row later (icon_grob()), not baked into the
  # cached geometry.
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

  # xscale/yscale are the icon's viewBox bounds, pre-flipped by grImport2
  # (yscale = c(ymax, ymin)) to translate SVG's y-down coordinates into
  # grid's y-up convention. Normalising by them here means each row's
  # transform (icon_grob()) is just rotate/scale/translate on plain numbers.
  xr <- pic@summary@xscale
  yr <- pic@summary@yscale

  x <- unlist(lapply(shapes, `[[`, "x"))
  y <- unlist(lapply(shapes, `[[`, "y"))
  # A picPath's id.lengths is NULL (not length(x)) when it has only one
  # subpath -- grImport2's/grid's shorthand for "treat all of x/y as one
  # path" -- so it has to be filled in explicitly before concatenating
  # shapes together, or those points silently go missing from the combined
  # id.lengths total below.
  id.lengths <- unlist(lapply(shapes, function(s) s$id.lengths %||% length(s$x)))

  list(
    x = (x - xr[1]) / (xr[2] - xr[1]) - 0.5,
    y = (yr[1] - y) / (yr[1] - yr[2]) - 0.5,
    id.lengths = id.lengths,
    rule = rules
  )
}

# Depth-first walk collecting every grImport2 "picPath" grob -- the
# fill-region primitive readPicture() produces for an SVG <path> (as
# opposed to "picRect"/"picPolyline" for <rect>/stroke data, which single-
# fill icon glyphs don't rely on).
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
