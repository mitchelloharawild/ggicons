#' Pictograms
#'
#' `geom_pictogram()` draws a value as a grid of repeated icons, some
#' fraction of them in a distinct "filled" style - a single-row rating
#' widget, a square waffle/percentage chart, and a growing isotype-style
#' unit chart are all this geom with different [stat_pictogram()] grid
#' params. See that page for how `n`/`nrow`/`ncol`/`symbol_value` combine to
#' pick the grid shape and fill count.
#'
#' @section Aesthetics:
#' `geom_pictogram()` understands the following aesthetics (`value` and
#' `icon` are required):
#'
#' - `x`, `y`: the grid's anchor position, justified by `hjust`/`vjust`.
#'   Neither is required on its own - see [stat_pictogram()]'s Orientation
#'   section for what leaving one out draws instead.
#' - **`value`**: the magnitude a pictogram represents; see
#'   [stat_pictogram()] for how it's turned into a filled slot count.
#' - **`icon`**: the icon drawn in every slot, filled or empty (as in
#'   [geom_icon()]).
#' - `colour`/`fill`: the *filled*-slot colour (as in [geom_icon()]); empty
#'   slots use `empty.colour` instead.
#' - `alpha`, `angle`: as in [geom_icon()].
#' - `size`: as in [geom_icon()], but defaults (`NA`) to auto-fit instead of
#'   a fixed number - see `size.unit`.
#'
#' @eval ggplot2:::rd_aesthetics("geom", "pictogram")
#' @inheritParams ggplot2::geom_point
#' @inheritParams stat_pictogram
#' @param size.unit The unit `size` is interpreted in, as in [geom_icon()].
#'   Also the unit auto-fit sizing computes in, when `size` is left at its
#'   default (`NA`): the grid then grows or shrinks to use as much of its
#'   available space as it can without overflowing - each pictogram's own
#'   share of the panel on an axis you mapped (the same way `geom_bar()`
#'   derives bar width from [ggplot2::resolution()]), full panel height/width
#'   on one [stat_pictogram()] left unmapped. Set `size` to a number to
#'   opt back out to a fixed physical size, as in [geom_icon()].
#' @param spacing Gap between adjacent icons, as a fraction of `size`.
#' @param hjust,vjust Where the grid sits relative to `(x, y)`, as a
#'   fraction of its width/height - `0.5` centres it, `0`/`1` anchor an
#'   edge, the way `geom_bar()`'s bars sit on their baseline. Default
#'   (`NULL`) follows [stat_pictogram()]'s orientation: `0.5` on an axis
#'   you mapped, `0` on one you left unmapped - anchored to that edge of
#'   the plot panel itself, not a data value, since an unmapped axis gets
#'   no position scale at all. So leaving `y` out of `aes()` draws a column
#'   chart, grown up from the bottom of the panel, with no extra
#'   arguments, and leaving `x` out draws a horizontal bar from the left.
#' @param empty.colour,empty.alpha Colour and alpha for empty slots.
#'   `empty.alpha` defaults to the `alpha` aesthetic.
#'
#' @return A ggplot2 layer.
#' @seealso [stat_pictogram()], [geom_icon()]
#' @export
#' @examples
#' library(ggplot2)
#' library(icons)
#'
#' # single-row rating: 5 slots, 3 filled
#' ggplot(NULL, aes(y = "Rating", value = 3)) +
#'   geom_pictogram(icon = fontawesome$solid$star, n = 5, colour = "goldenrod")
#'
#' # 10x10 waffle: 37%
#' ggplot(NULL, aes(x = "Proportion", value = 37)) +
#'   geom_pictogram(icon = fontawesome$solid$square, n = 100, nrow = 10)
#'
#' # growing isotype chart: two categories, each sized to its own value
#' pets <- data.frame(animal = c("Cat", "Dog"), count = c(23, 15))
#' ggplot(pets, aes(animal, y = "Pet", value = count, icon = animal, colour = animal)) +
#'   geom_pictogram(symbol_value = 1, nrow = 5) +
#'   scale_icon_manual(values = c(fontawesome$solid$cat, fontawesome$solid$dog))
#'
#' # column chart: no y aesthetic, so icons fill like a column geometry
#' ggplot(pets, aes(animal, value = count, icon = animal, colour = animal)) +
#'   geom_pictogram(ncol = 5) +
#'   scale_icon_manual(values = c(fontawesome$solid$cat, fontawesome$solid$dog))
geom_pictogram <- function(
  mapping = NULL,
  data = NULL,
  stat = "pictogram",
  position = "identity",
  ...,
  n = NULL,
  nrow = NULL,
  ncol = NULL,
  symbol_value = 1,
  flow = "row",
  size.unit = "mm",
  spacing = 0.2,
  hjust = NULL,
  vjust = NULL,
  empty.colour = "grey85",
  empty.alpha = NULL,
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
) {
  ggplot2::layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomPictogram,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = rlang::list2(
      na.rm = na.rm,
      n = n,
      nrow = nrow,
      ncol = ncol,
      symbol_value = symbol_value,
      flow = flow,
      size.unit = size.unit,
      spacing = spacing,
      hjust = hjust,
      vjust = vjust,
      empty.colour = empty.colour,
      empty.alpha = empty.alpha,
      ...
    )
  )
}

#' @rdname geom_pictogram
#' @format NULL
#' @usage NULL
#' @export
GeomPictogram <- ggplot2::ggproto(
  "GeomPictogram",
  ggplot2::Geom,
  # x/y aren't both required - stat_pictogram() may leave one of them out of the data entirely
  # (see its Orientation section), and draw_panel() below fills it in at draw time.
  required_aes = c("value", "icon"),
  # size isn't listed here (unlike GeomIcon) - its default is NA, the auto-fit sentinel (see
  # draw_panel()), a legitimate value handle_na() would otherwise drop every row for.
  non_missing_aes = c("colour", "angle"),
  default_aes = ggplot2::aes(
    colour = "black",
    fill = NA,
    size = NA,
    alpha = NA,
    angle = 0
  ),

  draw_key = draw_key_icon,

  # Same reasoning as GeomIcon: validate right after scale mapping, before setup_data() sees it.
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
    size.unit = "mm",
    spacing = 0.2,
    hjust = NULL,
    vjust = NULL,
    empty.colour = "grey85",
    empty.alpha = NULL
  ) {
    check_icon_aes(data$icon)
    data$icon <- icons::icon_path(data$icon)
    coords <- coord$transform(data, panel_params)

    # NULL follows stat_pictogram()'s orientation: 0 (baseline-anchored, like a bar) on the axis
    # it found unmapped, 0.5 (centred) on the one it found given - see pictogram_orientation().
    orientation <- coords$.orientation %||% "grid"
    if (is.null(hjust)) hjust <- ifelse(orientation == "horizontal", 0, 0.5)
    if (is.null(vjust)) vjust <- ifelse(orientation == "vertical", 0, 0.5)

    # A missing axis never went through scale training (stat_pictogram() left it out of `data`
    # entirely rather than filling in a stray 0 - see pictogram_orientation()), so coord$transform()
    # never added it either. Pin it here, directly in npc, to the actual edge of the panel - not
    # wherever a fallback [0, 1] scale's own default expansion would happen to rescale a 0 to.
    if (is.null(coords$x)) coords$x <- 0
    if (is.null(coords$y)) coords$y <- 0

    # Slot centres, in units of one icon's size, relative to the grid's own justification box -
    # not yet converted to npc, since that conversion needs the real viewport (see icon-grob.R).
    cellsize <- 1 + spacing
    offset_x <- (coords$.col - 0.5) * cellsize - hjust * coords$.ncol * cellsize
    offset_y <- (1 - vjust) * coords$.nrow * cellsize - (coords$.row - 0.5) * cellsize

    # `size` (NA by default - see default_aes) grows or shrinks to use as much of its available
    # space as it can without overflowing it: resolution() gives each pictogram its own share of
    # the panel on an axis the user mapped (the same way geom_bar() derives bar width from it),
    # and the full panel edge-to-edge on one stat_pictogram() left unmapped and pinned to 0/1 -
    # resolution() of an unvarying column is 1 by definition, which is exactly that. fit_margin
    # leaves a little breathing room on both, the way geom_bar()'s default width does. The actual
    # icon size in real units is resolved later, once the true viewport exists (see icon-grob.R);
    # this just packages what that resolution needs.
    fit_margin <- 0.9
    auto_fit <- list(
      avail_w_npc = ggplot2::resolution(coords$x, zero = FALSE) * fit_margin,
      avail_h_npc = ggplot2::resolution(coords$y, zero = FALSE) * fit_margin,
      grid_w_units = max(coords$.ncol) * cellsize,
      grid_h_units = max(coords$.nrow) * cellsize
    )

    filled_colour <- ifelse(is.na(coords$fill), coords$colour, coords$fill)
    colour <- ifelse(coords$.filled, filled_colour, empty.colour)
    alpha <- if (is.null(empty.alpha)) {
      coords$alpha
    } else {
      ifelse(coords$.filled, coords$alpha, empty.alpha)
    }

    icon_grob(
      path = coords$icon,
      x = coords$x,
      y = coords$y,
      offset_x = offset_x,
      offset_y = offset_y,
      size = coords$size,
      colour = colour,
      fill = NA,
      alpha = alpha,
      angle = coords$angle,
      size.unit = size.unit,
      auto_fit = auto_fit
    )
  }
)
