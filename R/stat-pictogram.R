#' Pictogram grid layout
#'
#' `stat_pictogram()` turns one row of data (an anchor position and a
#' `value`) into one row per icon slot in a grid, ready for
#' [geom_pictogram()] to draw. It's the counting/layout half of a pictogram.
#'
#' @section Grid sizing:
#' Two modes, chosen by whether `n` (or both `nrow` and `ncol`) is set:
#'
#' - **Fixed grid** (`n`, or both `nrow`/`ncol`, given): the grid always has
#'   `n` slots; `round(value / symbol_value)` of them are filled (capped at
#'   `n`), the rest empty. This is the waffle-chart/rating-widget shape:
#'   proportions vary, the grid footprint doesn't.
#' - **Growing grid** (`n`, `nrow` and `ncol` all left `NULL`, or only one of
#'   `nrow`/`ncol` given): the grid has exactly `round(value / symbol_value)`
#'   slots, all filled. An isotype/unit-chart shape where more icons *is*
#'   the value, so the footprint grows with it.
#'
#' At most one of `nrow`/`ncol` needs setting; the other wraps to fit. With
#' neither set, the grid defaults to a single row, unless `x`/`y` asks for a
#' bar/column shape instead; see Orientation below.
#'
#' @section Orientation:
#' `x` and `y` are the grid's anchor, but only `value` is actually required.
#' Map both and you get a fixed-position grid, centred on `(x, y)`: a
#' waffle chart or rating widget. Leave one unmapped and that becomes the
#' growth axis of a bar-style stack instead, anchored to that edge of the
#' plot panel. `aes(x = category, value = count)` draws a column chart,
#' one growing column per category, up from the bottom of the panel;
#' `aes(y = category, value = count)` draws a horizontal bar, growing
#' right from the left of the panel.
#'
#' @param n Total slots in the grid (fixed-grid mode). `NULL` (the default)
#'   grows the grid to fit `value` instead.
#' @param nrow,ncol Grid shape. Set at most one; the other is derived to
#'   wrap the slots. Both `NULL` wraps to a single row/column; see
#'   Orientation for which.
#' @param symbol_value The data value one slot represents. `NULL` (the
#'   default) picks one automatically: `1` in fixed-grid mode (`value` is
#'   already a slot count, e.g. a percentage out of `n = 100`), or, in
#'   growing mode, the smallest "nice" round number (1, 2 or 5 times a
#'   power of ten) that keeps the layer's largest value to around
#'   `n_target` icons; see that argument. Set explicitly to turn
#'   auto-picking off.
#' @param n_target In growing mode, roughly how many icons deep the growing
#'   dimension should get for the layer's largest value, when
#'   `symbol_value` is picked automatically. Turn this up for a
#'   finer-grained chart (more, smaller icons), down for a coarser one
#'   (fewer, bigger icons). Ignored if `symbol_value` is set explicitly, or
#'   in fixed-grid mode.
#' @param flow Fill order: `"row"` (default) fills left-to-right then wraps
#'   to the next row; `"col"` fills top-to-bottom then wraps to the next
#'   column.
#' @param geom Override the default connection between `stat_pictogram()` and
#'   [geom_pictogram()]. For more information about overriding these
#'   connections, see [ggplot2::layer()].
#' @inheritParams ggplot2::stat_count
#'
#' @return A ggplot2 layer.
#' @seealso [geom_pictogram()]
#' @export
#' @examples
#' library(ggplot2)
#'
#' # bundled placeholder shapes; a real pack (e.g. icons::fontawesome) works the same
#' shapes <- icons::icon_set(system.file("icons", package = "ggicons"))
#'
#' # only needed directly when pairing with a different geom
#' ggplot(NULL, aes(x = "Proportion", value = 37)) +
#'   stat_pictogram(geom = "pictogram", icon = shapes$square, n = 100, nrow = 10)
stat_pictogram <- function(
  mapping = NULL,
  data = NULL,
  geom = "pictogram",
  position = "identity",
  ...,
  n = NULL,
  nrow = NULL,
  ncol = NULL,
  symbol_value = NULL,
  n_target = 20,
  flow = "row",
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
) {
  ggplot2::layer(
    stat = StatPictogram,
    data = data,
    mapping = mapping,
    geom = geom,
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
      ...
    )
  )
}

#' @rdname stat_pictogram
#' @format NULL
#' @usage NULL
#' @export
StatPictogram <- ggplot2::ggproto(
  "StatPictogram",
  ggplot2::Stat,
  required_aes = c("value"),

  # Resolves an automatic symbol_value once for the whole layer, not per group/panel, so
  # facets/categories can't disagree about what one icon is worth. Stored in
  # computed_stat_params, where guide_pictogram() also reads symbol_value from.
  setup_params = function(data, params) {
    if (is.null(params$symbol_value)) {
      n <- params$n
      nrow <- params$nrow
      ncol <- params$ncol
      # A fixed grid already caps the icon count at n; only a growing grid gets an auto non-1 value.
      if (!is.null(n) || (!is.null(nrow) && !is.null(ncol))) {
        params$symbol_value <- 1
      } else {
        # Mirror compute_group()'s bar/column defaulting so the target below matches the same
        # growing dimension compute_group() actually draws.
        if (is.null(nrow) && is.null(ncol)) {
          if (pictogram_orientation(data) == "horizontal") nrow <- 1 else ncol <- 1
        }
        # The fixed dimension bounds the other, growing one; target n_target icons in that dimension.
        fixed_dim <- nrow %||% ncol %||% 1
        params$symbol_value <- pictogram_auto_symbol_value(
          data$value,
          fixed_dim * (params$n_target %||% 20)
        )
      }
    }
    params
  },

  compute_group = function(
    data,
    scales,
    n = NULL,
    nrow = NULL,
    ncol = NULL,
    symbol_value = 1,
    n_target = 20, # only used by setup_params()
    flow = "row"
  ) {
    flow <- rlang::arg_match0(flow, c("row", "col"))

    # Leaving x or y unmapped reads as a bar/column chart, not a fixed-position grid. Kept
    # out of `data` entirely so it's never trained into a position scale.
    orientation <- pictogram_orientation(data)

    # A bar/column reading grows along its missing axis by default, instead of wrapping.
    if (is.null(n) && is.null(nrow) && is.null(ncol)) {
      if (orientation == "vertical") ncol <- 1
      if (orientation == "horizontal") nrow <- 1
    }

    slots <- lapply(seq_along(data$value), function(i) {
      grid <- resolve_pictogram_grid(data$value[[i]], n, nrow, ncol, symbol_value)
      expand_pictogram_slots(data[i, , drop = FALSE], grid, flow, reverse_rows = orientation == "vertical")
    })
    out <- do.call(vctrs::vec_rbind, slots)
    out$.orientation <- orientation
    out
  }
)

# Whether the grid's anchor was fully given ("grid": centred on x and y, e.g. a waffle chart or
# rating widget) or one axis was left unmapped, reading as a bar/column stack growing from 0 on
# that axis. Neither given defaults to vertical (a single growing column at x = 0).
pictogram_orientation <- function(data) {
  has_x <- !is.null(data$x)
  has_y <- !is.null(data$y)
  if (has_x && has_y) "grid" else if (has_y) "horizontal" else "vertical"
}

# Smallest "nice" number (1, 2 or 5 times a power of ten) that's >= x. Only rounds up: rounding
# down could push a growing grid's icon count above its target.
nice_ceiling <- function(x) {
  if (!is.finite(x) || x <= 0) {
    return(1)
  }
  exponent <- floor(log10(x))
  fraction <- x / 10^exponent
  nice_fraction <- if (fraction <= 1) 1 else if (fraction <= 2) 2 else if (fraction <= 5) 5 else 10
  nice_fraction * 10^exponent
}

# Auto-picks symbol_value for a growing pictogram: roughly `target` icons for the layer's
# largest value, rounded up to a nice number. Never below 1, since value is usually a count.
pictogram_auto_symbol_value <- function(value, target = 20) {
  max_value <- suppressWarnings(max(abs(value), na.rm = TRUE))
  if (!is.finite(max_value) || max_value <= 0) {
    return(1)
  }
  max(1, nice_ceiling(max_value / target))
}

# Formats symbol_value with just enough decimal places to show it exactly, since the default
# accuracy would truncate a fractional value like 0.5 to "0".
format_symbol_value <- function(x) {
  accuracy <- if (is.finite(x) && x > 0 && x < 1) 10^floor(log10(x)) else 1
  scales::label_number(accuracy = accuracy)(x)
}

# One pictogram's (value, n, nrow, ncol, symbol_value) -> grid shape and filled count.
# n set (or nrow & ncol both set) fixes the grid: filled varies, total doesn't.
# n left NULL grows total to match filled instead, so there are never empty slots.
resolve_pictogram_grid <- function(value, n, nrow, ncol, symbol_value) {
  if (is.null(n) && !is.null(nrow) && !is.null(ncol)) {
    n <- nrow * ncol
  }

  filled <- round(value / symbol_value)
  if (is.null(n)) {
    total <- max(filled, 0)
  } else {
    total <- n
    filled <- min(max(filled, 0), n)
  }

  dims <- pictogram_wrap_dims(total, nrow, ncol)
  list(nrow = dims$nrow, ncol = dims$ncol, total = total, filled = filled)
}

# Derives whichever of nrow/ncol wasn't given, wrapping n slots to fit. Neither given: one row.
pictogram_wrap_dims <- function(n, nrow, ncol) {
  if (!is.null(nrow) && !is.null(ncol)) {
    return(list(nrow = nrow, ncol = ncol))
  }
  if (!is.null(nrow)) {
    return(list(nrow = nrow, ncol = max(1, ceiling(n / nrow))))
  }
  if (!is.null(ncol)) {
    return(list(nrow = max(1, ceiling(n / ncol)), ncol = ncol))
  }
  list(nrow = 1, ncol = max(n, 1))
}

# Replicates one input row into grid$total rows, one per icon slot, tagged with its grid
# position (.row/.col, 1-indexed) and fill state (.filled). Positions are grid indices, not
# data coordinates; geom_pictogram() turns them into a physical offset at draw time.
#
# .row numbers top-down (row 1 = top) by default. reverse_rows flips that to bottom-up, for a
# vertical pictogram anchored at the bottom, so row 1 sits nearest the axis.
expand_pictogram_slots <- function(row, grid, flow, reverse_rows = FALSE) {
  total <- grid$total
  if (total <= 0) {
    return(row[0, , drop = FALSE])
  }

  idx <- seq_len(total)
  if (flow == "row") {
    col <- ((idx - 1) %% grid$ncol) + 1
    r <- ((idx - 1) %/% grid$ncol) + 1
  } else {
    r <- ((idx - 1) %% grid$nrow) + 1
    col <- ((idx - 1) %/% grid$nrow) + 1
  }
  if (reverse_rows) r <- grid$nrow - r + 1

  out <- row[rep(1L, total), , drop = FALSE]
  out$.row <- r
  out$.col <- col
  out$.nrow <- grid$nrow
  out$.ncol <- grid$ncol
  out$.filled <- idx <= grid$filled
  out
}
