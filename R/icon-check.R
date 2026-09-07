# Validates icon is an icons vector or NULL, raising a clear error early.
check_icon_aes <- function(icon, call = NULL) {
  if (is.null(icon) || inherits(icon, "icons")) {
    return(invisible(icon))
  }

  cli::cli_abort(
    c(
      "The default identity scale is unsuitable for non-icon vectors.",
      "i" = "To map discrete data values to icons, use {.fun scale_icon_manual}."
    ),
    call = call
  )
}
