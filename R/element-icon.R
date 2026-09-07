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
#' A theme element parallel to [ggplot2::element_text()], for use in
#' `axis.text`, `strip.text`, `legend.text`, and similar theme settings.
#' Any label matching a name in `icons` is drawn as that icon; every other
#' label falls back to plain `element_text()` drawing.
#'
#' @details
#' `icons` is a named `list()` of individual, length-1 icons, one entry per
#' label to replace:
#'
#' ```r
#' element_icon(icons = list(
#'   low = icons::fontawesome$solid$`battery-quarter`,
#'   high = icons::fontawesome$solid$`battery-full`
#' ))
#' ```
#'
#' @param icons A named `list()` of icon objects (see Details), or `NULL`
#'   (the default) to disable icon substitution.
#' @param size Point size for text, and the point width/height for icons.
#' @param colour Colour for text, and the fill colour for icons.
#' @param inherit.blank See [ggplot2::element_text()].
#' @param ... Other arguments passed on to [ggplot2::element_text()].
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
#
# `hjust`/`vjust`/`angle`/`margin`/`margin_x`/`margin_y` carry the same
# layout inputs element_text()'s own titleGrob() uses -- the `x`/`y` anchor
# alone isn't enough to reproduce its positioning, so makeContent() below
# redoes that math for the icon side (see icon_rotate_just()).
element_icon_grob <- function(path, x, y, size, colour, angle, size.unit,
                               hjust, vjust, margin, margin_x, margin_y) {
  grid::gTree(
    path = path, x = x, y = y, size = size, colour = colour, angle = angle,
    size.unit = size.unit, hjust = hjust, vjust = vjust, margin = margin,
    margin_x = margin_x, margin_y = margin_y,
    width = grid::unit(max(size), size.unit),
    height = grid::unit(max(size), size.unit),
    cl = "elementiconpath"
  )
}

# Coerce a position (numeric, or a grid::unit) to plain npc numerics, in the
# viewport current when this runs (`convert` is grid::convertX/convertY).
# Callers always supply a concrete value -- defaulting an omitted x/y (e.g.
# the position orthogonal to an axis, or both for a legend/strip label)
# happens earlier, in element_grob.element_icon(), via icon_rotate_just().
as_npc <- function(v, convert) {
  if (!grid::is.unit(v)) {
    v <- grid::unit(v, "npc")
  }
  convert(v, "npc", valueOnly = TRUE)
}

# Mirrors ggplot2's own (unexported) rotate_just(): swaps hjust/vjust by
# 90-degree quadrant, so a *default* (unspecified) x/y position, and any
# margin applied against it, land on the correct side of a rotated label --
# the same trick element_text()'s titleGrob() uses to size/place the row or
# column it's drawn into. Kept as a small local copy (same formula, same
# documented imprecision away from the 0/90/180/270 cardinal angles) rather
# than calling the unexported ggplot2 internal at run time. `hjust`/`vjust`
# are assumed already numeric (see element_grob.element_icon()).
icon_rotate_just <- function(angle, hjust, vjust) {
  angle <- (angle %||% 0) %% 360
  case <- findInterval(angle, c(0, 90, 180, 270, 360))
  switch(case,
    list(hjust = hjust, vjust = vjust),
    list(hjust = 1 - vjust, vjust = hjust),
    list(hjust = 1 - hjust, vjust = 1 - vjust),
    list(hjust = vjust, vjust = 1 - hjust)
  )
}

#' @exportS3Method grid::makeContent
makeContent.elementiconpath <- function(x) {
  just <- icon_rotate_just(x$angle, x$hjust, x$vjust)

  anchor_x <- as_npc(x$x, grid::convertX)
  anchor_y <- as_npc(x$y, grid::convertY)

  # Margins are only added in the direction(s) the caller asked for
  # (margin_x/margin_y), exactly as element_text()'s titleGrob() does --
  # e.g. axis.text.x only ever sets margin_y (the gap between the axis line
  # and the label), never margin_x.
  if (isTRUE(x$margin_x) && !is.null(x$margin)) {
    l <- grid::convertWidth(x$margin[4], "npc", valueOnly = TRUE)
    r <- grid::convertWidth(x$margin[2], "npc", valueOnly = TRUE)
    anchor_x <- anchor_x - r * just$hjust + l * (1 - just$hjust)
  }
  if (isTRUE(x$margin_y) && !is.null(x$margin)) {
    t <- grid::convertHeight(x$margin[1], "npc", valueOnly = TRUE)
    b <- grid::convertHeight(x$margin[3], "npc", valueOnly = TRUE)
    anchor_y <- anchor_y - t * just$vjust + b * (1 - just$vjust)
  }

  # hjust/vjust shift the icon in its own local (unrotated) frame, then that
  # offset is rotated about the anchor -- the same order grid's own
  # textGrob() applies hjust/vjust and rotation in. Unlike the
  # quadrant-swapped `just` above (only needed to size/place the allocated
  # row/margin the same way ggplot2 does), this part is exact at every
  # angle, not just the cardinal ones, since the icon's local box is a
  # simple size-by-size square with no font metrics to approximate.
  size_npc_x <- grid::convertWidth(grid::unit(x$size, x$size.unit), "npc", valueOnly = TRUE)
  size_npc_y <- grid::convertHeight(grid::unit(x$size, x$size.unit), "npc", valueOnly = TRUE)
  local_dx <- size_npc_x * (0.5 - x$hjust)
  local_dy <- size_npc_y * (0.5 - x$vjust)
  rad <- x$angle * pi / 180
  dx <- local_dx * cos(rad) - local_dy * sin(rad)
  dy <- local_dx * sin(rad) + local_dy * cos(rad)

  grob <- icon_grob(
    path = x$path,
    x = anchor_x + dx,
    y = anchor_y + dy,
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

# Coerce hjust/vjust to numeric, the way ggplot2's own rotate_just() does --
# element_text() documents these as numeric, but some ggplot2-internal
# callers still pass "left"/"right"/"top"/"bottom" for certain guide
# elements, so this stays tolerant of the same inputs.
as_just_numeric <- function(v, chars) {
  if (is.character(v)) {
    out <- match(v, chars) - 1
    out[is.na(out)] <- 0.5
    return(out)
  }
  v
}

#' @exportS3Method ggplot2::element_grob
element_grob.element_icon <- function(element, label = "", x = NULL, y = NULL, ...,
                                       hjust = NULL, vjust = NULL, angle = NULL,
                                       margin = NULL, margin_x = FALSE, margin_y = FALSE) {
  n <- max(length(label), length(x), length(y))
  if (n == 0L) {
    # No labels to draw at all (e.g. a guide with zero breaks).
    return(grid::nullGrob())
  }
  label <- rep_len(label %||% "", n)

  hj <- as_just_numeric(hjust %||% element$hjust %||% 0.5, c("left", "right"))
  vj <- as_just_numeric(vjust %||% element$vjust %||% 0.5, c("bottom", "top"))
  ang <- angle %||% element$angle %||% 0
  mgn <- margin %||% element$margin

  # `x`/`y` may each be omitted (the position orthogonal to an axis, or both
  # for a legend/strip label) -- default them the way element_text()'s own
  # titleGrob() does, via the rotated justification, rather than always
  # centring at npc 0.5 regardless of hjust/vjust/angle.
  just <- icon_rotate_just(ang, hj, vj)
  if (is.null(x)) x <- rep(just$hjust, n) else x <- rep_len(x, n)
  if (is.null(y)) y <- rep(just$vjust, n) else y <- rep_len(y, n)

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
      x = x[icon_idx],
      y = y[icon_idx],
      size = element$size %||% 11,
      colour = element$colour %||% "black",
      angle = ang,
      size.unit = "pt",
      hjust = hj,
      vjust = vj,
      margin = mgn,
      margin_x = margin_x,
      margin_y = margin_y
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
      x = x[!icon_idx],
      y = y[!icon_idx],
      ...,
      hjust = hjust,
      vjust = vjust,
      angle = angle,
      margin = margin,
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
