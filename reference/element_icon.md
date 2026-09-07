# Theme element: draw labels as icons

A theme element parallel to
[`ggplot2::element_text()`](https://ggplot2.tidyverse.org/reference/element.html),
for use in `axis.text`, `strip.text`, `legend.text`, and similar theme
settings. Any label matching a name in `icons` is drawn as that icon;
every other label falls back to plain
[`element_text()`](https://ggplot2.tidyverse.org/reference/element.html)
drawing.

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
  (see Details), or `NULL` (the default) to disable icon substitution.

- ...:

  Other arguments passed on to
  [`ggplot2::element_text()`](https://ggplot2.tidyverse.org/reference/element.html).

- size:

  Point size for text, and the point width/height for icons.

- colour:

  Colour for text, and the fill colour for icons.

- inherit.blank:

  See
  [`ggplot2::element_text()`](https://ggplot2.tidyverse.org/reference/element.html).

## Value

An `element_icon` object: a subclass of `element_text` (itself a ggplot2
theme element), for use in
[`ggplot2::theme()`](https://ggplot2.tidyverse.org/reference/theme.html).

## Details

`icons` is a named [`list()`](https://rdrr.io/r/base/list.html) of
individual, length-1 icons, one entry per label to replace:

    element_icon(icons = list(
      low = icons::fontawesome$solid$`battery-quarter`,
      high = icons::fontawesome$solid$`battery-full`
    ))

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
