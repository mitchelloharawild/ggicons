# Friendly validation for the icon aesthetic, shared by GeomIcon's
# use_defaults() (see geom-icon.R) and draw_key_icon(). Both call this right
# before handing data$icon to icons::icon_path() -- which, given anything
# other than an icon/icon_vec, aborts with a correct but terse
# "`x` must be an <icon> object." Left uncaught, that happens deep inside
# grob construction (icon_grob() <- draw_panel() <- Layer$draw_geom()),
# where ggplot2's by_layer() re-wraps it as an opaque
# "Problem while converting geom to grob." -- true, but it points at grob
# conversion, not at the actually-missing scale.
#
# Calling this from GeomIcon$use_defaults() catches the same problem earlier
# (at ggplot_build() time, via Layer$compute_geom_2(), right after scale
# mapping runs). There's no default discrete palette for icon (no meaningful
# "next icon" the way there's a default shape or colour), so ggplot2 just
# skips adding *any* scale when it can't find a `scale_icon_*()` default
# (see ggplot2:::find_scale()) -- the data is effectively left under an
# identity mapping, unconverted. `call = NULL` keeps by_layer()'s wrapping
# ("Problem while setting up geom aesthetics.") as the only framing text;
# without it, the parent condition's call would additionally print
# "Caused by error in `use_defaults()`:", naming an internal implementation
# detail with nothing useful for a caller to act on.
check_icon_aes <- function(icon, call = NULL) {
  if (is.null(icon) || inherits(icon, "icon_vec") || inherits(icon, "icon")) {
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
