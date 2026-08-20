#' Legend key glyph: an icon
#'
#' A [ggplot2::draw_key()] function that draws the icon itself as the
#' legend key glyph, instead of a generic point/rect. This is
#' [geom_icon()]'s default `key_glyph`; set `key_glyph = draw_key_icon` on
#' another geom to borrow it.
#'
#' @inheritParams ggplot2::draw_key
#'
#' @return A grob.
#' @export
draw_key_icon <- function(data, params, size) {
  check_icon_aes(data$icon)
  icon_grob(
    path = if (is.null(data$icon)) NA_character_ else icons::icon_path(data$icon)[[1]],
    x = 0.5, y = 0.5,
    size = data$size %||% 6,
    colour = data$colour %||% "black",
    fill = data$fill %||% NA,
    alpha = data$alpha %||% NA,
    angle = data$angle %||% 0,
    size.unit = params$size.unit %||% "mm"
  )
}
