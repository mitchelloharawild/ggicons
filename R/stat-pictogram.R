#' Pictogram grid layout
#'
#' `stat_pictogram()` turns one row of data (an anchor position and a
#' `value`) into one row per icon slot in a grid, ready for
#' [geom_pictogram()] to draw. It's the counting/layout half of a pictogram,
#' the way [ggplot2::stat_count()] is for [ggplot2::geom_bar()].
#'
#' @section Grid sizing:
#' Two modes, chosen by whether `n` (or both `nrow` and `ncol`) is set:
#'
#' - **Fixed grid** (`n`, or both `nrow`/`ncol`, given): the grid always has
#'   `n` slots; `round(value / symbol_value)` of them are marked filled
#'   (capped at `n`), the rest empty. This is the waffle-chart/rating-widget
#'   shape — proportions vary, the grid footprint doesn't.
#' - **Growing grid** (`n`, `nrow` and `ncol` all left `NULL`, or only one of
#'   `nrow`/`ncol` given): the grid has exactly `round(value / symbol_value)`
#'   slots, all filled — an isotype/unit-chart shape where more icons *is*
#'   the value, so the footprint grows with it.
#'
#' Either way, at most one of `nrow`/`ncol` needs setting; the other wraps to
#' fit. With neither set, the grid defaults to a single row, unless `x`/`y`
#' asks for a bar/column shape instead - see Orientation below.
#'
#' @section Orientation:
#' `x` and `y` are the grid's anchor, but only `value` is actually required.
#' Map both and you get a fixed-position grid, centred on `(x, y)` - a
#' waffle chart or rating widget. Leave one unmapped and that becomes the
#' growth axis of a bar-style stack, anchored to that edge of the plot
#' panel itself rather than to any data value on it (an unmapped axis gets
#' no position scale at all - see [geom_pictogram()]'s `hjust`/`vjust`), the
#' way `geom_bar()` only requires `x`: `aes(x = category, value = count)`
#' draws a column chart, one growing column per category, up from the
#' bottom of the panel; `aes(y = category, value = count)` draws a
#' horizontal bar, growing right from the left of the panel. With neither
#' `nrow` nor `ncol` set, the missing axis is also the one that grows
#' instead of wraps (a single column for a column chart, a single row for
#' a bar).
#'
#' @param n Total slots in the grid (fixed-grid mode). `NULL` (the default)
#'   grows the grid to fit `value` instead.
#' @param nrow,ncol Grid shape. Set at most one; the other is derived to
#'   wrap the slots. Both `NULL` wraps to a single row/column - see
#'   Orientation for which.
#' @param symbol_value The data value one slot represents. Defaults to `1`,
#'   i.e. `value` is already a slot count.
#' @param flow Fill order: `"row"` (default) fills left-to-right then wraps
#'   to the next row; `"col"` fills top-to-bottom then wraps to the next
#'   column.
#' @inheritParams ggplot2::stat_count
#'
#' @return A ggplot2 layer.
#' @seealso [geom_pictogram()]
#' @export
stat_pictogram <- function(
  mapping = NULL,
  data = NULL,
  geom = "pictogram",
  position = "identity",
  ...,
  n = NULL,
  nrow = NULL,
  ncol = NULL,
  symbol_value = 1,
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

  compute_group = function(
    data,
    scales,
    n = NULL,
    nrow = NULL,
    ncol = NULL,
    symbol_value = 1,
    flow = "row"
  ) {
    flow <- rlang::arg_match0(flow, c("row", "col"))

    # x/y are the grid's anchor, but neither is required: leaving one unmapped reads as a
    # bar/column chart instead of a fixed-position grid - see pictogram_orientation(). Left out
    # of `data` entirely rather than filled with a placeholder 0: any real numeric value here,
    # even a constant, gets trained into that axis's position scale downstream, giving it a
    # spurious near-zero range (and the usual expansion around it, so the baseline isn't even
    # flush with the panel edge). geom_pictogram() pins the missing axis straight to the panel
    # edge in npc instead, bypassing scale training altogether.
    orientation <- pictogram_orientation(data)

    # A bar/column reading also wants to grow along its missing axis by default, rather than
    # wrapping into a single row/column the way a fixed-anchor grid does.
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

# Whether the grid's anchor was fully given (a "grid" - centred on both x and y, e.g. a waffle
# chart or rating widget) or one axis was left unmapped, which reads as a bar/column-style stack
# growing from 0 on that axis instead: x given, y missing -> vertical column growing up from
# y = 0 (a column chart); y given, x missing -> horizontal bar growing right from x = 0. Neither
# given defaults to vertical, the more common reading (a single growing column at x = 0).
pictogram_orientation <- function(data) {
  has_x <- !is.null(data$x)
  has_y <- !is.null(data$y)
  if (has_x && has_y) "grid" else if (has_y) "horizontal" else "vertical"
}

# One pictogram's worth of (value, n, nrow, ncol, symbol_value) -> grid shape and filled count.
# n set (or both nrow & ncol, which implies n = nrow*ncol) fixes the grid: `filled` varies, `total`
# doesn't. n left NULL grows `total` to match `filled` instead - no empty slots, ever.
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

# Derives whichever of nrow/ncol wasn't given, wrapping `n` slots to fit. Neither given -> one row.
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

# Replicates one input row into `grid$total` rows, one per icon slot, with the slot's
# position (.row/.col, 1-indexed) and fill state (.filled) attached. Positions are grid
# indices, not data coordinates - geom_pictogram() turns them into a physical offset from
# the anchor at draw time, the same way icon size itself is resolved late (see icon-grob.R).
#
# `.row` numbers top-down (row 1 = top) by default - the reading order a centred grid (waffle,
# rating widget) wants, first slots at the top. `reverse_rows` flips that to bottom-up: geom
# pictogram() anchors a "vertical" pictogram's box at the bottom (vjust = 0, see
# pictogram_orientation()), and under that anchor, row 1 sits nearest the axis, not row `nrow` -
# so without the flip, the *first* (idx-lowest) slots would render at the far/top edge and any
# partial last row would dangle at the bottom, away from the icons it wraps from.
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
