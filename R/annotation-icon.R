#' Annotate a plot with icons at fixed positions
#'
#' `annotation_icon()` draws one or more icons at fixed `(x, y)` positions,
#' the `icon` analogue of [ggplot2::annotation_custom()] /
#' [ggplot2::annotation_raster()] — a single call that adds icons directly,
#' without a data frame or `aes()` mapping. Unlike those, though,
#' `annotation_icon()` *does* train the panel's position scales: a
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
#'   [icons](https://github.com/mitchelloharawild/icons) package — an icon
#'   object (e.g. from [icons::read_icon()] or
#'   `icons::fontawesome$solid$rocket`) or an [icons::icon_find()] result.
#' - `x`, `y`: the position(s) to draw at, in data coordinates.
#' - `colour`/`fill`: both map to the icon's single fill colour (icons
#'   don't have a separate border) — `fill` wins when both are set.
#' - `alpha`
#' - `size`: the icon's width/height, in `size.unit` (default millimetres).
#' - `angle`: rotation, in degrees.
#'
#' `stroke`/`linewidth` don't apply — icons are filled shapes, not framed
#' ones.
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
  # Validated up front, before anything else is built: an opaque failure
  # from icons::icon_path() or vctrs' recycling machinery three calls deep
  # is a lot less useful than catching a bad `icon` argument right here,
  # pointing straight back at annotation_icon()'s own call (cli_abort()'s
  # default `call` already does that -- no need to pass one). Same
  # inherits() test as check_icon_aes() (see icon-check.R), but with
  # wording for a directly-called constructor rather than a mapped
  # aesthetic -- check_icon_aes()'s hint about scale_icon_manual() doesn't
  # apply here, there's no scale involved.
  if (!(inherits(icon, "icon_vec") || inherits(icon, "icon"))) {
    cli::cli_abort(
      "{.arg icon} must be an icon vector from the {.pkg icons} package (e.g. {.code icons::fontawesome$solid$rocket}), not {.obj_type_friendly {icon}}."
    )
  }

  # A single `icon` object (as opposed to an `icon_vec` built with `c()`,
  # e.g. `icons::icon_find()`'s result) is a scalar S3 list, not a vctrs
  # vector -- data.frame()/vec_recycle_common() can't treat it as a
  # length-1 column until it's coerced to `icon_vec`. `c()` on an
  # already-`icon_vec` value is a no-op.
  icon <- c(icon)

  # icon/x/y/colour/fill/size/alpha/angle are recycled to a common length
  # here (vctrs is already a transitive dependency via the icons package),
  # so e.g. two icons at two positions, or one icon repeated at several
  # positions, both work from a single call.
  rec <- vctrs::vec_recycle_common(
    icon = icon, x = x, y = y, colour = colour, fill = fill,
    size = size, alpha = alpha, angle = angle
  )
  data <- as.data.frame(rec)

  # colour/fill/size/alpha/angle are mapped as aesthetics below (not fixed
  # layer params) so that a single call can vary them per icon, the same as
  # x/y. Unlike x/y, though, these have a *default* scale in stock ggplot2
  # (e.g. a discrete hue palette for colour, a continuous area scale for
  # size) that would silently reinterpret literal values passed here --
  # e.g. colour = "steelblue" would come out as whatever hue the scale
  # happens to assign it, not steelblue itself, and if the plot already
  # maps colour elsewhere, this layer's values would be folded into (and
  # perturb) that shared scale. Wrapping them in base::I() marks them
  # "AsIs", which ggplot2's find_scale() special-cases to skip scale
  # selection entirely -- the same effectively-identity treatment `icon`
  # already gets for a different reason (no default `scale_icon_*()`
  # exists to find; see icon-check.R).
  data$colour <- I(data$colour)
  data$fill <- I(data$fill)
  data$size <- I(data$size)
  data$alpha <- I(data$alpha)
  data$angle <- I(data$angle)

  ggplot2::layer(
    data = data,
    # x/y are mapped as real aesthetics, not fixed at Inf/panel corners the
    # way annotation_custom()/annotation_raster() work -- so, deliberately,
    # they *do* train the panel's position scales, the same as
    # annotate("point", ...) does. That's more useful for a fixed-position
    # icon than annotation_custom()'s scale-invariant placement would be.
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
