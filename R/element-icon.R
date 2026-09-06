# Validates that `icons` is a named list of length-1 <icons> vectors.
check_icon_lookup <- function(icons, call = rlang::caller_env()) {
  if (is.null(icons)) {
    return(invisible(icons))
  }
  if (!is.list(icons) || is.null(names(icons)) || any(!nzchar(names(icons)))) {
    cli::cli_abort(
      c(
        "{.arg icons} must be a named {.cls list} of icons, or {.code NULL}.",
        "i" = "Each name is the label string it should replace, e.g. {.code list(low = icons::fontawesome$solid$rocket)}."
      ),
      call = call
    )
  }
  ok <- vapply(
    icons, function(x) inherits(x, "icons") && length(x) == 1L, logical(1)
  )
  if (!all(ok)) {
    cli::cli_abort(
      "Every element of {.arg icons} must be a single icon (a length-1 {.cls icons} vector).",
      call = call
    )
  }
  invisible(icons)
}

#' Theme element: draw labels as icons
#'
#' @description
#' `element_icon()` is a theme element parallel to [ggplot2::element_text()],
#' for use in `axis.text`/`axis.text.x`/`axis.text.y`, `strip.text`,
#' `legend.text`, and similar text-drawing theme settings passed to
#' [ggplot2::theme()]. Any label that matches a name in `icons` is drawn as
#' the corresponding icon; every other label, and *every* label if `icons`
#' is left `NULL`, is drawn exactly as [ggplot2::element_text()] would draw
#' it.
#'
#' @details
#' # How labels are matched to icons
#' ggplot2's label pipeline (scales, guides, facets) only ever hands theme
#' elements character label strings, never icon objects directly. So,
#' unlike [geom_icon()]'s `icon` aesthetic, `element_icon()` is given a
#' *lookup* from label string to icon, and resolves each label to an icon
#' (or falls back to text) at draw time, once the actual break/strip/legend
#' labels are known.
#'
#' `icons` must be a **named `list()`** of individual, length-1 icons (e.g.
#' `icons::fontawesome$solid$rocket`), one entry per label it should
#' replace:
#'
#' ```r
#' element_icon(icons = list(
#'   low = icons::fontawesome$solid$`battery-quarter`,
#'   high = icons::fontawesome$solid$`battery-full`
#' ))
#' ```
#'
#' A named multi-icon vector is not accepted, and can't even be built: an
#' `icons` vector is a `vctrs` record type that cannot carry element
#' `names()`, and the `icons` package's own combining method (`c.icons()`)
#' always drops any names passed to it. A named `list()` of individual
#' icons is the supported way to build this lookup.
#'
#' Any label not found in `icons` (including every label, when `icons` is
#' `NULL`) is drawn by delegating straight to `element_text()`'s own
#' `element_grob()` method, so hjust/vjust/margin/rotation for the text
#' side behave exactly as they do for a plain `element_text()`.
#'
#' # Sizing
#' `size` is interpreted the same way `element_text()` interprets it (a
#' point size). For the icon side, that same numeric value is used as an
#' absolute size with `size.unit = "pt"`, i.e. an icon's width/height in
#' points equals `size`. This is a simple, documented convention, not an
#' attempt at pixel-parity with a font's x-height, so icons will typically
#' read as a little larger/bolder than the text they replace at the same
#' `size`. This also differs from [geom_icon()]'s `size` aesthetic, which
#' defaults to millimetres; themes conventionally size text in points, so
#' `element_icon()` follows that convention instead.
#'
#' # Known limitations
#' - Only a single fill colour is supported for the icon side (`colour`, no
#'   separate `fill`), consistent with [geom_icon()].
#' - `angle` rotates the icon the same number of degrees `element_text()`
#'   would rotate text, but the `hjust`/`vjust`/`margin` adjustments
#'   `element_text()` applies to text are not replicated for the icon side;
#'   icons are always centred at the given `x`/`y`. For axis text in
#'   particular this means an icon won't shift the way a rotated text label
#'   would to stay clear of the axis line.
#' - When a set of breaks/strips mixes matched and unmatched labels, one
#'   icon grob and one delegated text grob are drawn as sibling children of
#'   a `gTree`, with no attempt to visually align icon size against the
#'   surrounding text's line box beyond the `size` convention above.
#' - `coord_flip()` is manually smoke-tested but not covered by an
#'   automated test, so worth a second look after any ggplot2 upgrade.
#'
#' @param icons A named `list()` of icon objects (see Details), or `NULL`
#'   (the default) to disable icon substitution entirely, behaving exactly
#'   like `element_text()`.
#' @param size Point size for text, and (see Details) the point-equivalent
#'   width/height for icons.
#' @param colour Colour for text, and the fill colour for icons.
#' @param inherit.blank See [ggplot2::element_text()].
#' @param ... Other arguments passed on to [ggplot2::element_text()] (e.g.
#'   `family`, `face`, `hjust`, `vjust`, `angle`, `lineheight`, `margin`,
#'   `debug`), used for the text-fallback side of rendering only.
#'
#' @return An `element_icon` object: a subclass of `element_text` (itself a
#'   ggplot2 theme element), for use in [ggplot2::theme()].
#' @seealso [geom_icon()]
#' @export
#' @examples
#' library(ggplot2)
#'
#' battery <- list(
#'   `4` = icons::fontawesome$solid$`battery-quarter`,
#'   `6` = icons::fontawesome$solid$`battery-half`,
#'   `8` = icons::fontawesome$solid$`battery-full`
#' )
#'
#' ggplot(mtcars, aes(factor(cyl), mpg)) +
#'   geom_boxplot() +
#'   theme(axis.text.x = element_icon(icons = battery, size = 14))
element_icon <- function(icons = NULL, ..., size = NULL, colour = NULL,
                          inherit.blank = FALSE) {
  check_icon_lookup(icons)
  text <- ggplot2::element_text(
    ..., size = size, colour = colour, inherit.blank = inherit.blank
  )
  # `element_text()` returns an S7 object, whose `$` accessor only returns
  # its own declared properties, so `icons` is stashed as a plain attribute
  # instead (which survives ggplot2's element merging) and read via attr().
  attr(text, "icons") <- icons
  class(text) <- c("element_icon", class(text))
  text
}

# A grob that defers both x/y position conversion and the icon_grob() call
# to makeContent(), since the correct viewport (native scale for the axis,
# etc.) only exists once grid is actually drawing, not at construction time.
# `width`/`height` are set eagerly so gtable can size the row/column before
# makeContent() runs; otherwise the row collapses to zero size.
element_icon_grob <- function(path, x, y, size, colour, angle, size.unit) {
  grid::gTree(
    path = path, x = x, y = y, size = size, colour = colour, angle = angle,
    size.unit = size.unit,
    width = grid::unit(max(size), size.unit),
    height = grid::unit(max(size), size.unit),
    cl = "elementiconpath"
  )
}

# Coerce a position vector (numeric, or a grid::unit) to plain npc numerics.
# `NULL` (no position supplied, e.g. a legend key glyph) defaults to
# centred, `n` values of 0.5.
as_npc <- function(v, convert, n) {
  if (is.null(v)) {
    return(rep(0.5, n))
  }
  if (!grid::is.unit(v)) {
    v <- grid::unit(v, "npc")
  }
  convert(v, "npc", valueOnly = TRUE)
}

#' @exportS3Method grid::makeContent
makeContent.elementiconpath <- function(x) {
  grob <- icon_grob(
    path = x$path,
    x = as_npc(x$x, grid::convertX, length(x$path)),
    y = as_npc(x$y, grid::convertY, length(x$path)),
    size = x$size,
    colour = x$colour,
    fill = NA,
    alpha = NA,
    angle = x$angle,
    size.unit = x$size.unit
  )
  grid::setChildren(x, grid::gList(grob))
}

#' @exportS3Method grid::widthDetails
widthDetails.elementiconpath <- function(x) x$width

#' @exportS3Method grid::heightDetails
heightDetails.elementiconpath <- function(x) x$height

#' @exportS3Method grid::widthDetails
widthDetails.elementicongrob <- function(x) x$width

#' @exportS3Method grid::heightDetails
heightDetails.elementicongrob <- function(x) x$height

#' @exportS3Method ggplot2::element_grob
element_grob.element_icon <- function(element, label = "", x = NULL, y = NULL, ...,
                                       margin_x = FALSE, margin_y = FALSE) {
  n <- max(length(label), length(x), length(y))
  if (n == 0L) {
    # No labels to draw at all (e.g. a guide with zero breaks).
    return(grid::nullGrob())
  }
  label <- rep_len(label %||% "", n)
  if (!is.null(x)) x <- rep_len(x, n)
  if (!is.null(y)) y <- rep_len(y, n)

  icon_lookup <- attr(element, "icons")
  icon_idx <- rep(FALSE, n)
  if (!is.null(icon_lookup) && length(icon_lookup)) {
    icon_idx <- !is.na(label) & label %in% names(icon_lookup)
  }

  icon_part <- NULL
  text_part <- NULL

  if (any(icon_idx)) {
    matched <- icon_lookup[label[icon_idx]]
    paths <- vapply(matched, function(ic) icons::icon_path(ic)[[1]], character(1))

    icon_part <- element_icon_grob(
      path = paths,
      x = if (is.null(x)) NULL else x[icon_idx],
      y = if (is.null(y)) NULL else y[icon_idx],
      size = element$size %||% 11,
      colour = element$colour %||% "black",
      angle = element$angle %||% 0,
      size.unit = "pt"
    )
  }

  if (any(!icon_idx)) {
    # Dispatch to element_text()'s own element_grob() method for every
    # unmatched label, rather than reimplementing its layout logic.
    text_element <- element
    class(text_element) <- setdiff(class(text_element), "element_icon")
    text_part <- ggplot2::element_grob(
      text_element,
      label = label[!icon_idx],
      x = if (is.null(x)) NULL else x[!icon_idx],
      y = if (is.null(y)) NULL else y[!icon_idx],
      ...,
      margin_x = margin_x,
      margin_y = margin_y
    )
  }

  children <- Filter(Negate(is.null), list(icon_part, text_part))
  if (length(children) == 0) {
    return(grid::nullGrob())
  }

  # Combine both children's sizes eagerly for gtable layout, before either
  # child's own content is built.
  widths <- lapply(children, grid::grobWidth)
  heights <- lapply(children, grid::grobHeight)
  combined_width <- Reduce(grid::unit.pmax, widths)
  combined_height <- Reduce(grid::unit.pmax, heights)

  ggname(
    "element_icon",
    grid::gTree(
      children = do.call(grid::gList, children),
      width = combined_width, height = combined_height,
      cl = "elementicongrob"
    )
  )
}
