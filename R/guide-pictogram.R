#' Pictogram value guide
#'
#' `guide_pictogram()` is the default guide for [scale_value_continuous()]
#' (and so, automatically, for `geom_pictogram()`'s `value` aesthetic): a
#' one-entry legend spelling out the ratio every pictogram already encodes
#' but never states: one icon, labelled with the `symbol_value` it stands
#' for (e.g. an icon glyph next to "= 1000"), the way an infographic
#' isotype chart captions "each icon represents 1000 units" or a map's
#' scale bar does for distance.
#'
#' Unlike a standard legend, this never shows one key per break:
#' `symbol_value` is a single ratio, not something that varies over
#' `value`'s range, so there is only ever one row to show, and it comes
#' from the matched [geom_pictogram()] layer's own `symbol_value` rather
#' than from the scale's trained breaks.
#'
#' @param title The legend title. Defaults to the `value` scale's name
#'   (typically set via `labs(value = ...)`, e.g. the units `value` counts).
#' @param symbol_value Override the ratio shown, instead of reading it from
#'   the matched layer. Rarely needed.
#' @param label Override the key's label text entirely, instead of the
#'   default `"= {symbol_value}"`.
#' @param icon Which icon to draw in the key. Only needed when the matched
#'   layer's `icon` aesthetic is *mapped* rather than fixed (as in the
#'   isotype-chart example below, where each category gets its own icon):
#'   there's no single icon to show automatically then, so the key falls
#'   back to a plain colour swatch instead of guessing a category's icon;
#'   set this to pick one deliberately.
#' @inheritParams ggplot2::guide_legend
#'
#' @return A ggplot2 guide.
#' @seealso [scale_value_continuous()], [geom_pictogram()]
#' @export
#' @examples
#' library(ggplot2)
#' library(icons)
#'
#' # legend reads "\[square\] = 1": each waffle square is one percentage point
#' # (the default symbol_value)
#' ggplot(NULL, aes(x = "Proportion", value = 37)) +
#'   geom_pictogram(icon = fontawesome$solid$square, n = 100, nrow = 10) +
#'   labs(value = "%")
#'
#' # a unit chart where each icon is worth 5: the legend spells that out
#' pets <- data.frame(animal = c("Cat", "Dog"), count = c(23, 15))
#' ggplot(pets, aes(animal, value = count, icon = animal, colour = animal)) +
#'   geom_pictogram(symbol_value = 5) +
#'   scale_icon_manual(values = c(fontawesome$solid$cat, fontawesome$solid$dog)) +
#'   labs(value = "pets")
guide_pictogram <- function(
  title = ggplot2::waiver(),
  symbol_value = NULL,
  label = NULL,
  icon = NULL,
  theme = NULL,
  position = NULL,
  direction = NULL,
  override.aes = list(),
  order = 0,
  ...
) {
  ggplot2::new_guide(
    title = title,
    symbol_value = symbol_value,
    label = label,
    icon = icon,
    theme = theme,
    direction = direction,
    override.aes = override.aes,
    order = order,
    position = position,
    ...,
    available_aes = "value",
    name = "pictogram",
    super = GuidePictogram
  )
}

#' @rdname guide_pictogram
#' @format NULL
#' @usage NULL
#' @export
GuidePictogram <- ggplot2::ggproto(
  "GuidePictogram",
  ggplot2::GuideLegend,

  params = c(
    ggplot2::GuideLegend$params,
    list(symbol_value = NULL, label = NULL, icon = NULL)
  ),

  available_aes = "value",

  # A single placeholder row, so train() never drops the guide just because the scale's
  # breaks come back empty. Real content comes from get_layer_key() below.
  extract_key = function(scale, aesthetic, symbol_value = NULL, ...) {
    sv <- symbol_value %||% 1
    vctrs::data_frame(!!aesthetic := sv, .value = sv, .label = as.character(sv))
  },

  # Builds the key and its decor directly, one per matched pictogram-shaped layer, since
  # there's only ever one row to show here.
  get_layer_key = function(self, params, layers, data = NULL, theme = NULL) {
    decor <- list()

    for (i in seq_along(layers)) {
      layer <- layers[[i]]
      symbol_value <- params$symbol_value %||%
        layer$computed_stat_params$symbol_value %||%
        layer$computed_geom_params$symbol_value
      # No symbol_value means this isn't a pictogram-shaped layer; skip it.
      if (is.null(symbol_value)) next

      key <- vctrs::data_frame(value = symbol_value)
      # icon is usually a fixed layer param. When mapped instead (varies by category, as in
      # an isotype chart), there's no single icon to show automatically; params$icon lets a
      # user pick one deliberately, otherwise the key falls back to a plain colour swatch.
      key$icon <- params$icon %||% layer$aes_params$icon

      single_params <- layer$aes_params[lengths(layer$aes_params) == 1L]
      single_params$icon <- NULL
      key <- layer$geom$use_defaults(key, single_params, theme = theme)

      for (aes in names(params$override.aes)) {
        key[[aes]] <- params$override.aes[[aes]]
      }

      key$.value <- symbol_value
      key$.label <- params$label %||% paste0("= ", format_symbol_value(symbol_value))

      draw_key <- layer$geom$draw_key
      if (is.null(key$icon)) {
        # Match a filled slot's fill/colour fallback, since a plain colour swatch would
        # otherwise render unfilled when only colour was set.
        draw_key <- ggplot2::draw_key_polygon
        if (is.na(key$fill)) key$fill <- key$colour
      }

      decor[[length(decor) + 1]] <- list(
        draw_key = draw_key,
        data = key,
        params = c(layer$computed_geom_params, layer$computed_stat_params)
      )
    }

    if (length(decor) == 0) {
      return(NULL)
    }

    # One guide, one ratio; key only needs the columns build_labels()/build_ticks() read.
    params$key <- decor[[1]]$data[c(".value", ".label")]
    params$decor <- decor
    params
  }
)
