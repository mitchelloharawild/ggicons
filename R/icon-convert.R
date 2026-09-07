# Caches SVG-to-Picture conversion per icon path, so each distinct icon is parsed once, not once per row.
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

  # Normalise arbitrary SVG into the restricted dialect readPicture() expects.
  tmp <- tempfile(fileext = ".svg")
  on.exit(unlink(tmp))
  rsvg::rsvg_svg(path, tmp)

  grImport2::readPicture(tmp, warn = FALSE)
}
