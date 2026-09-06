# Annotate a plot with icons at fixed positions

`annotation_icon()` draws one or more icons at fixed `(x, y)` positions,
the `icon` analogue of
[`ggplot2::annotation_custom()`](https://ggplot2.tidyverse.org/reference/annotation_custom.html)
/
[`ggplot2::annotation_raster()`](https://ggplot2.tidyverse.org/reference/annotation_raster.html):
a single call that adds icons directly, without a data frame or `aes()`
mapping. Unlike those, though, `annotation_icon()` *does* train the
panel's position scales, since a fixed-position icon is more usefully
treated like a point annotation (e.g.
[`ggplot2::annotate()`](https://ggplot2.tidyverse.org/reference/annotate.html))
than like an arbitrary grob pinned to the panel's corners, so placing
one outside the data's range still expands the axes to fit it.

## Usage

``` r
annotation_icon(
  icon,
  x,
  y,
  colour = "black",
  fill = NA,
  size = 6,
  alpha = NA,
  angle = 0,
  size.unit = "mm"
)
```

## Arguments

- icon:

  An icon vector from the
  [icons](https://github.com/mitchelloharawild/icons) package. Character
  ids are not resolved; pass an actual icon vector.

- x, y:

  The position(s) to draw the icon(s) at, in data coordinates.

- colour, fill:

  Fill colour for the icon; `fill` wins when both are set.

- size:

  The icon's width/height, in `size.unit`.

- alpha:

  Transparency, from 0 (fully transparent) to 1 (opaque).

- angle:

  Rotation, in degrees.

- size.unit:

  The unit in which `size` is interpreted, one of `"mm"` (default),
  `"pt"`, `"cm"`, `"in"`, or another
  [`grid::unit()`](https://rdrr.io/r/grid/unit.html)-compatible absolute
  unit.

## Value

A ggplot2 layer.

## Details

`icon`, `x`, `y` and the style arguments are all recycled to a common
length, so a single call can place several icons at once (e.g.
`annotation_icon(icon = c(rocket, star), x = c(1, 2), y = c(1, 1))`).

## Aesthetics

`annotation_icon()` sets the same per-icon properties
[`geom_icon()`](https://pkg.mitchelloharawild.com/ggicons/reference/geom_icon.md)
understands as aesthetics, but as plain arguments instead:

- **`icon`** (required): an icon vector from the
  [icons](https://github.com/mitchelloharawild/icons) package, an icon
  object (e.g. from
  [`icons::read_icon()`](https://pkg.mitchelloharawild.com/icons/reference/read_icon.html)
  or `icons::fontawesome$solid$rocket`) or an
  [`icons::icon_find()`](https://pkg.mitchelloharawild.com/icons/reference/icon_find.html)
  result.

- `x`, `y`: the position(s) to draw at, in data coordinates.

- `colour`/`fill`: both map to the icon's single fill colour (icons
  don't have a separate border); `fill` wins when both are set.

- `alpha`

- `size`: the icon's width/height, in `size.unit` (default millimetres).

- `angle`: rotation, in degrees.

`stroke`/`linewidth` don't apply, since icons are filled shapes, not
framed ones.

## See also

[`geom_icon()`](https://pkg.mitchelloharawild.com/ggicons/reference/geom_icon.md)

## Examples

``` r
library(ggplot2)
library(icons)

ggplot(data.frame(x = 1:3, y = c(1, 3, 2)), aes(x, y)) +
  geom_point() +
  annotation_icon(
    icon = fontawesome$solid$rocket,
    x = 2, y = 3, size = 12, colour = "steelblue"
  )
#> Error: ✖ The fontawesome icon library is not yet installed.
#> ℹ Install it with `download_fontawesome()`.
```
