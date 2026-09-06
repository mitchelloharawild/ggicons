#' Annotate a plot with icons at fixed positions
#'
#' `annotation_icon()` draws one or more icons at fixed `(x, y)` positions,
#' the `icon` analogue of [ggplot2::annotation_custom()] /
#' [ggplot2::annotation_raster()]: a single call that adds icons directly,
#' without a data frame or `aes()` mapping. Unlike those, though,
#' `annotation_icon()` *does* train the panel's position scales, since a
#' fixed-position icon is more usefully treated like a point annotation
#' (e.g. [ggplot2::annotate()]) than like an arbitrary grob pinned to the
#' panel's corners, so placing one outside the data's range still expands
#' the axes to fit it.
#'
#' `icon`, `x`, `y` and the style arguments are all recycled to a common
#' length, so a single call can place several icons at once (e.g.
#' `annotation_icon(icon = c(rocket, star), x = c(1, 2), y = c(1, 1))`).
#'
#' @section Aesthetics:
#' `annotation_icon()` sets the same per-icon properties [geom_icon()]
#' understands as aesthetics, but as plain arguments instead:
#'
#' - **`icon`** (required): an icon vector from the
#'   [icons](https://github.com/mitchelloharawild/icons) package, an icon
#'   object (e.g. from [icons::read_icon()] or
#'   `icons::fontawesome$solid$rocket`) or an [icons::icon_find()] result.
#' - `x`, `y`: the position(s) to draw at, in data coordinates.
#' - `colour`/`fill`: both map to the icon's single fill colour (icons
#'   don't have a separate border); `fill` wins when both are set.
#' - `alpha`
#' - `size`: the icon's width/height, in `size.unit` (default millimetres).
#' - `angle`: rotation, in degrees.
#'
#' `stroke`/`linewidth` don't apply, since icons are filled shapes, not
#' framed ones.
#'
#' @param icon An icon vector from the
#'   [icons](https://github.com/mitchelloharawild/icons) package. Character
#'   ids are not resolved; pass an actual icon vector.
#' @param x,y The position(s) to draw the icon(s) at, in data coordinates.
#' @param colour,fill Fill colour for the icon; `fill` wins when both are
#'   set.
#' @param size The icon's width/height, in `size.unit`.
#' @param alpha Transparency, from 0 (fully transparent) to 1 (opaque).
#' @param angle Rotation, in degrees.
#' @param size.unit The unit in which `size` is interpreted, one of `"mm"`
#'   (default), `"pt"`, `"cm"`, `"in"`, or another [grid::unit()]-compatible
#'   absolute unit.
#'
#' @return A ggplot2 layer.
#' @seealso [geom_icon()]
#' @export
#' @examples
#' library(ggplot2)
#' library(icons)
#'
#' ggplot(data.frame(x = 1:3, y = c(1, 3, 2)), aes(x, y)) +
#'   geom_point() +
#'   annotation_icon(
#'     icon = fontawesome$solid$rocket,
#'     x = 2, y = 3, size = 12, colour = "steelblue"
#'   )
annotation_icon <- function(icon, x, y, colour = "black", fill = NA, size = 6,
                             alpha = NA, angle = 0, size.unit = "mm") {
  # Validate icon up front so a bad argument is reported here, not as an
  # opaque failure deep inside icon_path() or vctrs' recycling machinery.
  if (!inherits(icon, "icons")) {
    cli::cli_abort(
      "{.arg icon} must be an icon vector from the {.pkg icons} package (e.g. {.code icons::fontawesome$solid$rocket}), not {.obj_type_friendly {icon}}."
    )
  }

  # Recycle all arguments to a common length, so e.g. two icons at two
  # positions, or one icon repeated at several positions, both work.
  rec <- vctrs::vec_recycle_common(
    icon = icon, x = x, y = y, colour = colour, fill = fill,
    size = size, alpha = alpha, angle = angle
  )
  data <- as.data.frame(rec)

  # Mark these AsIs so ggplot2 skips scale selection and uses the literal
  # values, rather than reinterpreting them through a default colour/size
  # scale (which would also perturb any shared scale used elsewhere).
  data$colour <- I(data$colour)
  data$fill <- I(data$fill)
  data$size <- I(data$size)
  data$alpha <- I(data$alpha)
  data$angle <- I(data$angle)

  ggplot2::layer(
    data = data,
    # x/y are mapped as real aesthetics, deliberately training the panel's
    # position scales the same as annotate("point", ...) does.
    mapping = ggplot2::aes(
      x = x, y = y, icon = icon, colour = colour, fill = fill,
      alpha = alpha, size = size, angle = angle
    ),
    stat = ggplot2::StatIdentity,
    position = ggplot2::PositionIdentity,
    geom = GeomIcon,
    inherit.aes = FALSE,
    show.legend = FALSE,
    params = list(size.unit = size.unit)
  )
}
