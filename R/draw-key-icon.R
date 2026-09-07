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
#' @examples
#' library(ggplot2)
#'
#' # bundled placeholder shapes; a real pack (e.g. icons::fontawesome) works the same
#' shapes <- icons::icon_set(system.file("icons", package = "ggicons"))
#'
#' # borrowed onto geom_point() so its legend key shows the mapped icon
#' df <- data.frame(x = 1:3, y = c(1, 3, 2), cat = c("a", "b", "c"))
#' ggplot(df, aes(x, y, colour = cat, icon = cat)) +
#'   geom_point(size = 10, key_glyph = draw_key_icon) +
#'   scale_icon_manual(values = c(shapes$square, shapes$circle, shapes$triangle))
draw_key_icon <- function(data, params, size) {
  check_icon_aes(data$icon)
  key_size <- data$size %||% NA
  if (is.na(key_size)) key_size <- 6
  icon_grob(
    path = if (is.null(data$icon)) NA_character_ else icons::icon_path(data$icon)[[1]],
    x = 0.5, y = 0.5,
    size = key_size,
    colour = data$colour %||% "black",
    fill = data$fill %||% NA,
    alpha = data$alpha %||% NA,
    angle = data$angle %||% 0,
    size.unit = params$size.unit %||% "mm"
  )
}
