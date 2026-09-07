#' Pictograms
#'
#' `geom_pictogram()` draws a value as a grid of repeated icons, some
#' fraction of them filled in and the rest left faded. The same geom
#' produces a single-row rating widget, a waffle/percentage chart, or a
#' growing isotype-style unit chart, depending on the grid arguments
#' (`n`/`nrow`/`ncol`/`symbol_value`) passed to [stat_pictogram()].
#'
#' @section Aesthetics:
#' `geom_pictogram()` understands the following aesthetics (`value` and
#' `icon` are required):
#'
#' - `x`, `y`: the grid's anchor position. Leaving one out draws a
#'   bar/column chart instead of a fixed-position grid; see
#'   [stat_pictogram()]'s Orientation section.
#' - **`value`**: the magnitude a pictogram represents. [stat_pictogram()]
#'   turns it into a filled slot count using `symbol_value`, the amount one
#'   icon stands for. Also drives an automatic [guide_pictogram()] legend
#'   spelling that ratio out; turn it off with `guides(value = "none")`.
#' - **`icon`**: the icon drawn in every slot, filled or empty (as in
#'   [geom_icon()]).
#' - `colour`/`fill`: the filled-slot colour; empty slots use
#'   `empty.colour` instead.
#' - `alpha`, `angle`, `size`: as in [geom_icon()].
#'
#' @eval ggplot2:::rd_aesthetics("geom", "pictogram")
#' @inheritParams ggplot2::geom_point
#' @inheritParams stat_pictogram
#' @param size.unit The unit `size` is interpreted in, as in [geom_icon()].
#'   Left at its default (`NA`), `size` instead auto-fits: each pictogram
#'   grows or shrinks to fill its own share of the panel, the way
#'   `geom_bar()` derives bar width. Set `size` to a number to opt out to a
#'   fixed physical size.
#' @param spacing Gap between adjacent icons, as a fraction of `size`.
#' @param hjust,vjust Where the grid sits relative to `(x, y)`, as a
#'   fraction of its width/height: `0.5` centres it, `0`/`1` anchor an
#'   edge. Usually left at the default (`NULL`), which follows
#'   [stat_pictogram()]'s orientation: centred on an axis you mapped,
#'   anchored to the panel edge on one you left unmapped. So leaving `y`
#'   out of `aes()` draws a column chart growing up from the bottom, and
#'   leaving `x` out draws a bar growing from the left.
#' @param empty.colour,empty.alpha Colour and alpha for empty slots.
#'   `empty.alpha` defaults to the `alpha` aesthetic.
#'
#' @return A ggplot2 layer.
#' @seealso [stat_pictogram()], [geom_icon()], [guide_pictogram()]
#' @export
#' @examples
#' library(ggplot2)
#'
#' # bundled placeholder shapes; a real pack (e.g. icons::fontawesome) works the same
#' shapes <- icons::icon_set(system.file("icons", package = "ggicons"))
#'
#' # 10x10 waffle: 37%
#' ggplot(NULL, aes(x = "Proportion", value = 37)) +
#'   geom_pictogram(icon = shapes$square, n = 100, nrow = 10)
#'
#' # single-row rating: 5 slots, 3 filled, legend switched off
#' ggplot(NULL, aes(y = "Rating", value = 3)) +
#'   geom_pictogram(icon = shapes$star, n = 5, colour = "goldenrod") +
#'   guides(value = "none")
#'
#' @examplesIf icons::icon_installed(icons::fontawesome)
#' # growing isotype chart: two categories, each sized to its own value
#' pets <- data.frame(animal = c("Cat", "Dog"), count = c(23, 15))
#' ggplot(pets, aes(animal, y = "Pet", value = count, icon = animal, colour = animal)) +
#'   geom_pictogram(nrow = 5) +
#'   scale_icon_manual(values = c(icons::fontawesome$solid$cat, icons::fontawesome$solid$dog))
#'
#' @examplesIf icons::icon_installed(icons::fontawesome)
#' # column chart: no y aesthetic, so icons fill like a column geometry
#' commutes <- data.frame(mode = c("Bicycle", "Car"), count = c(890, 1230))
#' ggplot(commutes, aes(mode, value = count, icon = mode, colour = mode)) +
#'   geom_pictogram(ncol = 5) +
#'   scale_icon_manual(values = c(icons::fontawesome$solid$bicycle, icons::fontawesome$solid$car)) +
#'   labs(value = "commuters")
geom_pictogram <- function(
  mapping = NULL,
  data = NULL,
  stat = "pictogram",
  position = "identity",
  ...,
  n = NULL,
  nrow = NULL,
  ncol = NULL,
  symbol_value = NULL,
  n_target = 20,
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
      n_target = n_target,
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
  # stat_pictogram() may leave x or y out; draw_panel() fills it in at draw time.
  required_aes = c("value", "icon"),
  # size stays out: its default NA means auto-fit, not a missing value to drop.
  non_missing_aes = c("colour", "angle"),
  default_aes = ggplot2::aes(
    colour = "black",
    fill = NA,
    size = NA,
    alpha = NA,
    angle = 0
  ),

  draw_key = draw_key_icon,

  # Validate icon right after scale mapping, before setup_data() sees it.
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

    # NULL hjust/vjust follow orientation: anchored (0) on the unmapped axis, centred (0.5) on the mapped one.
    orientation <- coords$.orientation %||% "grid"
    if (is.null(hjust)) hjust <- ifelse(orientation == "horizontal", 0, 0.5)
    if (is.null(vjust)) vjust <- ifelse(orientation == "vertical", 0, 0.5)

    # An axis left out of `data` never got trained or transformed; pin it to the panel edge (npc 0).
    if (is.null(coords$x)) coords$x <- 0
    if (is.null(coords$y)) coords$y <- 0

    # Slot centres, in icon-size units, relative to the grid's justification box.
    cellsize <- 1 + spacing
    offset_x <- (coords$.col - 0.5) * cellsize - hjust * coords$.ncol * cellsize
    offset_y <- (1 - vjust) * coords$.nrow * cellsize - (coords$.row - 0.5) * cellsize

    # size (NA by default) auto-fits: each pictogram gets its own share of panel resolution,
    # with a small fit_margin for breathing room, like geom_bar()'s default width.
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
