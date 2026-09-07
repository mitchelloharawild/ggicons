#' Discrete scale for the icon aesthetic
#'
#' Tells ggplot2's scale machinery that an icon vector from the
#' [icons](https://github.com/mitchelloharawild/icons) package is discrete,
#' the same way a bare `factor`/`character` column already is. Without this,
#' `scale_type.default()` warns and defaults to continuous, which is wrong
#' for icons.
#'
#' This purely silences that warning: `icon` has no automatic discrete
#' palette (see [scale_icon_manual()]).
#'
#' @param x A vector mapped to an aesthetic.
#' @return `"discrete"`.
#' @exportS3Method ggplot2::scale_type
#' @keywords internal
scale_type.icons <- function(x) "discrete"

#' Use icon values as-is
#'
#' `scale_icon_identity()` is for the common case where the `icon`
#' aesthetic is already mapped to icon values (an icon vector from the
#' [icons](https://github.com/mitchelloharawild/icons) package), so the data
#' is passed through unchanged rather than looked up in a palette. No legend
#' is drawn by default, as with [ggplot2::scale_shape_identity()].
#'
#' Requesting a legend (`guide = "legend"`) isn't supported here: ggplot2's
#' discrete scale training only recognises character/factor data, not icon
#' vectors. Use [scale_icon_manual()] instead when a legend is needed.
#'
#' @inheritParams ggplot2::scale_shape_identity
#' @param aesthetics Character string(s) naming the aesthetic(s) this scale
#'   works with, defaulting to `"icon"`.
#'
#' @return A ggplot2 scale.
#' @seealso [scale_icon_manual()]
#' @export
#' @examples
#' library(ggplot2)
#'
#' # bundled placeholder shapes; a real pack (e.g. icons::fontawesome) works the same
#' shapes <- icons::icon_set(system.file("icons", package = "ggicons"))
#' df <- data.frame(
#'   x = 1:3, y = c(1, 3, 2),
#'   icon = c(shapes$square, shapes$circle, shapes$triangle)
#' )
#' # applied automatically for an icon-vector aesthetic; shown explicitly here
#' ggplot(df, aes(x, y, icon = icon)) +
#'   geom_icon(size = 10) +
#'   scale_icon_identity()
scale_icon_identity <- function(name = ggplot2::waiver(), ...,
                                 guide = "none", aesthetics = "icon") {
  ggplot2::discrete_scale(
    aesthetics = aesthetics,
    name = name,
    palette = scales::pal_identity(),
    ...,
    guide = guide,
    super = ggplot2::ScaleDiscreteIdentity
  )
}

#' Map discrete values to icons manually
#'
#' `scale_icon_manual()` maps a discrete data value (e.g. a category
#' column) to an icon, using a manually-specified lookup, the `icon`
#' analogue of [ggplot2::scale_shape_manual()]. There's no automatic
#' discrete palette for icons, so `values` is required.
#'
#' @inheritParams ggplot2::scale_shape_manual
#' @param values An icon vector from the
#'   [icons](https://github.com/mitchelloharawild/icons) package, the same
#'   length as the number of levels to map. Unlike most `scale_*_manual()`
#'   counterparts, `values` can't be named by level, since icon vectors don't
#'   support names, so it's matched positionally against the sorted data
#'   levels; pass `limits` to map against a different order (`breaks` only
#'   controls the legend, not this matching).
#'
#' @return A ggplot2 scale.
#' @seealso [scale_icon_identity()]
#' @export
#' @examples
#' library(ggplot2)
#'
#' # bundled placeholder shapes; a real pack (e.g. icons::fontawesome) works the same
#' shapes <- icons::icon_set(system.file("icons", package = "ggicons"))
#' df <- data.frame(
#'   x = 1:3, y = c(1, 3, 2),
#'   type = c("a", "b", "c")
#' )
#' ggplot(df, aes(x, y, icon = type)) +
#'   geom_icon(size = 10) +
#'   scale_icon_manual(values = c(shapes$square, shapes$circle, shapes$triangle))
scale_icon_manual <- function(..., values, breaks = ggplot2::waiver(),
                               na.value = NA) {
  ggplot2::scale_discrete_manual(
    aesthetics = "icon",
    values = values,
    breaks = breaks,
    na.value = na.value,
    ...
  )
}
