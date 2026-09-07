#' Continuous scale for the pictogram value aesthetic
#'
#' `scale_value_continuous()` registers `value` (as mapped in
#' [geom_pictogram()]) as a real trained aesthetic, purely so it can carry a
#' default guide (see [guide_pictogram()]). It never rescales `value`
#' itself: `symbol_value` slot counts need the real data value, so the
#' palette is the identity function.
#'
#' Picked up automatically for `aes(value = ...)`, so most plots never need
#' to call it directly. Exported for overriding `guide` or setting explicit
#' `breaks`.
#'
#' @inheritParams ggplot2::scale_size_continuous
#' @param guide The value legend's guide; defaults to [guide_pictogram()].
#'   Set to `"none"` (or pass `show.legend = FALSE` to [geom_pictogram()])
#'   to hide it.
#'
#' @return A ggplot2 scale.
#' @seealso [guide_pictogram()], [geom_pictogram()]
#' @export
#' @examples
#' library(ggplot2)
#'
#' # bundled placeholder shapes; a real pack (e.g. icons::fontawesome) works the same
#' shapes <- icons::icon_set(system.file("icons", package = "ggicons"))
#'
#' # applied automatically; shown explicitly here just to relabel the legend
#' ggplot(NULL, aes(x = "Proportion", value = 37)) +
#'   geom_pictogram(icon = shapes$square, n = 100, nrow = 10) +
#'   scale_value_continuous(name = "%")
scale_value_continuous <- function(
  name = ggplot2::waiver(),
  breaks = ggplot2::waiver(),
  labels = ggplot2::waiver(),
  limits = NULL,
  guide = "pictogram",
  ...
) {
  ggplot2::continuous_scale(
    aesthetics = "value",
    palette = identity,
    rescaler = scales::rescale_none,
    name = name,
    breaks = breaks,
    labels = labels,
    limits = limits,
    guide = guide,
    ...
  )
}
