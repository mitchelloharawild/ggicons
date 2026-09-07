#' Icons
#'
#' `geom_icon()` is a [ggplot2::geom_point()]-shaped geom that draws an
#' icon per row at `(x, y)`, instead of a point. Icons come from the
#' [icons](https://github.com/mitchelloharawild/icons) package: single-fill
#' SVG vector shapes, parsed once per unique icon and cached, then
#' recoloured/rescaled/rotated per row at draw time.
#'
#' @section Aesthetics:
#' `geom_icon()` understands the following aesthetics (`icon` is required):
#'
#' - **`icon`**: the icon to draw, as an icon vector from the
#'   [icons](https://github.com/mitchelloharawild/icons) package — an icon
#'   object (e.g. from [icons::read_icon()] or
#'   `icons::fontawesome$solid$rocket`) or an [icons::icon_find()] result.
#'   Character ids are not resolved; map an actual icon vector.
#' - `x`, `y`
#' - `colour`/`fill`: both map to the icon's single fill colour (icons
#'   don't have a separate border) — `fill` wins when both are set.
#' - `alpha`
#' - `size`: the icon's width/height, in `size.unit` (default millimetres).
#' - `angle`: rotation, in degrees.
#'
#' `stroke`/`linewidth` don't apply — icons are filled shapes, not framed
#' ones.
#'
#' @eval ggplot2:::rd_aesthetics("geom", "icon")
#' @inheritParams ggplot2::geom_point
#' @param size.unit The unit in which the `size` aesthetic is interpreted,
#'   one of `"mm"` (default), `"pt"`, `"cm"`, `"in"`, or another
#'   [grid::unit()]-compatible absolute unit.
#'
#' @return A ggplot2 layer.
#' @seealso [draw_key_icon()], [scale_icon_identity()], [scale_icon_manual()]
#' @export
#' @examples
#' library(ggplot2)
#' library(icons)
#'
#' df <- data.frame(
#'   x = 1:3, y = c(1, 3, 2),
#'   icon = c(
#'     fontawesome$solid$rocket,
#'     fontawesome$solid$star,
#'     fontawesome$solid$heart
#'   )
#' )
#' ggplot(df, aes(x, y, icon = icon)) +
#'   geom_icon(size = 10, colour = "steelblue")
geom_icon <- function(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  ...,
  size.unit = "mm",
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
) {
  ggplot2::layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomIcon,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = rlang::list2(
      na.rm = na.rm,
      size.unit = size.unit,
      ...
    )
  )
}

#' @rdname geom_icon
#' @format NULL
#' @usage NULL
#' @export
GeomIcon <- ggplot2::ggproto(
  "GeomIcon",
  ggplot2::Geom,
  required_aes = c("x", "y", "icon"),
  non_missing_aes = c("size", "colour", "angle"),
  default_aes = ggplot2::aes(
    colour = "black",
    fill = NA,
    size = 6,
    alpha = NA,
    angle = 0
  ),

  draw_key = draw_key_icon,

  # Validate data$icon right after scale mapping, before setup_data() would see raw values.
  # Also validates the legend key glyph, since guides build keys the same way.
  use_defaults = function(self, data, params = list(), modifiers = ggplot2::aes(),
                           default_aes = NULL, theme = NULL, ...) {
    data <- ggplot2::ggproto_parent(ggplot2::Geom, self)$use_defaults(
      data, params, modifiers, default_aes, theme, ...
    )
    check_icon_aes(data$icon)
    data
  },

  draw_panel = function(
    data,
    panel_params,
    coord,
    na.rm = FALSE,
    size.unit = "mm"
  ) {
    # Resolve icon paths at draw time, after scale mapping has run.
    # Icon is already validated; this is a cheap defensive check.
    check_icon_aes(data$icon)
    data$icon <- icons::icon_path(data$icon)
    coords <- coord$transform(data, panel_params)

    icon_grob(
      path = coords$icon,
      x = coords$x,
      y = coords$y,
      size = coords$size,
      colour = coords$colour,
      fill = coords$fill,
      alpha = coords$alpha,
      angle = coords$angle,
      size.unit = size.unit
    )
  }
)
