# Legend key glyph: an icon

A
[`ggplot2::draw_key()`](https://ggplot2.tidyverse.org/reference/draw_key.html)
function that draws the icon itself as the legend key glyph, instead of
a generic point/rect. This is
[`geom_icon()`](https://pkg.mitchelloharawild.com/ggicons/reference/geom_icon.md)'s
default `key_glyph`; set `key_glyph = draw_key_icon` on another geom to
borrow it.

## Usage

``` r
draw_key_icon(data, params, size)
```

## Arguments

- data:

  A single row data frame containing the scaled aesthetics to display in
  this key

- params:

  A list of additional parameters supplied to the geom.

- size:

  Width and height of key in mm.

## Value

A grob.
