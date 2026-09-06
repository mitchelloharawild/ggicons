# Theme element: draw labels as icons

`element_icon()` is a theme element parallel to
[`ggplot2::element_text()`](https://ggplot2.tidyverse.org/reference/element.html),
for use in `axis.text`/`axis.text.x`/`axis.text.y`, `strip.text`,
`legend.text`, and similar text-drawing theme settings passed to
[`ggplot2::theme()`](https://ggplot2.tidyverse.org/reference/theme.html).
Any label that matches a name in `icons` is drawn as the corresponding
icon; every other label, and *every* label if `icons` is left `NULL`, is
drawn exactly as
[`ggplot2::element_text()`](https://ggplot2.tidyverse.org/reference/element.html)
would draw it.

## Usage

``` r
element_icon(
  icons = NULL,
  ...,
  size = NULL,
  colour = NULL,
  inherit.blank = FALSE
)
```

## Arguments

- icons:

  A named [`list()`](https://rdrr.io/r/base/list.html) of icon objects
  (see Details), or `NULL` (the default) to disable icon substitution
  entirely, behaving exactly like
  [`element_text()`](https://ggplot2.tidyverse.org/reference/element.html).

- ...:

  Other arguments passed on to
  [`ggplot2::element_text()`](https://ggplot2.tidyverse.org/reference/element.html)
  (e.g. `family`, `face`, `hjust`, `vjust`, `angle`, `lineheight`,
  `margin`, `debug`), used for the text-fallback side of rendering only.

- size:

  Point size for text, and (see Details) the point-equivalent
  width/height for icons.

- colour:

  Colour for text, and the fill colour for icons.

- inherit.blank:

  See
  [`ggplot2::element_text()`](https://ggplot2.tidyverse.org/reference/element.html).

## Value

An `element_icon` object: a subclass of `element_text` (itself a ggplot2
theme element), for use in
[`ggplot2::theme()`](https://ggplot2.tidyverse.org/reference/theme.html).

## How labels are matched to icons

ggplot2's label pipeline (scales, guides, facets) only ever hands theme
elements character label strings, never icon objects directly. So,
unlike
[`geom_icon()`](https://pkg.mitchelloharawild.com/ggicons/reference/geom_icon.md)'s
`icon` aesthetic, `element_icon()` is given a *lookup* from label string
to icon, and resolves each label to an icon (or falls back to text) at
draw time, once the actual break/strip/legend labels are known.

`icons` must be a **named [`list()`](https://rdrr.io/r/base/list.html)**
of individual, length-1 icons (e.g. `icons::fontawesome$solid$rocket`),
one entry per label it should replace:

    element_icon(icons = list(
      low = icons::fontawesome$solid$`battery-quarter`,
      high = icons::fontawesome$solid$`battery-full`
    ))

A named multi-icon vector is not accepted, and can't even be built: an
`icons` vector is a `vctrs` record type that cannot carry element
[`names()`](https://rdrr.io/r/base/names.html), and the `icons`
package's own combining method (`c.icons()`) always drops any names
passed to it. A named [`list()`](https://rdrr.io/r/base/list.html) of
individual icons is the supported way to build this lookup.

Any label not found in `icons` (including every label, when `icons` is
`NULL`) is drawn by delegating straight to
[`element_text()`](https://ggplot2.tidyverse.org/reference/element.html)'s
own
[`element_grob()`](https://ggplot2.tidyverse.org/reference/element_grob.html)
method, so hjust/vjust/margin/rotation for the text side behave exactly
as they do for a plain
[`element_text()`](https://ggplot2.tidyverse.org/reference/element.html).

## Sizing

`size` is interpreted the same way
[`element_text()`](https://ggplot2.tidyverse.org/reference/element.html)
interprets it (a point size). For the icon side, that same numeric value
is used as an absolute size with `size.unit = "pt"`, i.e. an icon's
width/height in points equals `size`. This is a simple, documented
convention, not an attempt at pixel-parity with a font's x-height, so
icons will typically read as a little larger/bolder than the text they
replace at the same `size`. This also differs from
[`geom_icon()`](https://pkg.mitchelloharawild.com/ggicons/reference/geom_icon.md)'s
`size` aesthetic, which defaults to millimetres; themes conventionally
size text in points, so `element_icon()` follows that convention
instead.

## Known limitations

- Only a single fill colour is supported for the icon side (`colour`, no
  separate `fill`), consistent with
  [`geom_icon()`](https://pkg.mitchelloharawild.com/ggicons/reference/geom_icon.md).

- `angle` rotates the icon the same number of degrees
  [`element_text()`](https://ggplot2.tidyverse.org/reference/element.html)
  would rotate text, but the `hjust`/`vjust`/`margin` adjustments
  [`element_text()`](https://ggplot2.tidyverse.org/reference/element.html)
  applies to text are not replicated for the icon side; icons are always
  centred at the given `x`/`y`. For axis text in particular this means
  an icon won't shift the way a rotated text label would to stay clear
  of the axis line.

- When a set of breaks/strips mixes matched and unmatched labels, one
  icon grob and one delegated text grob are drawn as sibling children of
  a `gTree`, with no attempt to visually align icon size against the
  surrounding text's line box beyond the `size` convention above.

- [`coord_flip()`](https://ggplot2.tidyverse.org/reference/coord_flip.html)
  is manually smoke-tested but not covered by an automated test, so
  worth a second look after any ggplot2 upgrade.

## See also

[`geom_icon()`](https://pkg.mitchelloharawild.com/ggicons/reference/geom_icon.md)

## Examples

``` r
library(ggplot2)

battery <- list(
  `4` = icons::fontawesome$solid$`battery-quarter`,
  `6` = icons::fontawesome$solid$`battery-half`,
  `8` = icons::fontawesome$solid$`battery-full`
)
#> Error: ✖ The fontawesome icon library is not yet installed.
#> ℹ Install it with `download_fontawesome()`.

ggplot(mtcars, aes(factor(cyl), mpg)) +
  geom_boxplot() +
  theme(axis.text.x = element_icon(icons = battery, size = 14))
#> Error: object 'battery' not found
```
