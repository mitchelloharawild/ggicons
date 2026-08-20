# SVG -> grImport2::Picture conversion, cached per icon (per unique SVG file
# path) so a plot with thousands of rows re-parses each distinct icon once,
# not once per row. This is one layer below icon-geometry.R's cache (which
# turns this Picture into flattened, per-row-transformable coordinates) --
# recolouring/resizing/positioning happens later, per row, at draw time
# (see icon_grob()), without touching either cache.
icon_convert_cache <- new.env(parent = emptyenv())

get_icon_converted <- function(path) {
  if (is.na(path)) {
    return(NULL)
  }

  cached <- icon_convert_cache[[path]]
  if (!is.null(cached)) {
    return(cached)
  }

  converted <- build_icon_converted(path)
  icon_convert_cache[[path]] <- converted
  converted
}

build_icon_converted <- function(path) {
  if (!file.exists(path)) {
    cli::cli_abort("Can't find the icon's SVG file at {.file {path}}.")
  }

  # grImport2::readPicture() expects a restricted/"cleaned" SVG dialect;
  # rsvg normalises arbitrary SVG (including the icons package's path data)
  # into that dialect.
  tmp <- tempfile(fileext = ".svg")
  on.exit(unlink(tmp))
  rsvg::rsvg_svg(path, tmp)

  grImport2::readPicture(tmp, warn = FALSE)
}
