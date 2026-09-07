# Pictograms

`geom_pictogram()` draws a value as a grid of repeated icons, some
fraction of them filled in and the rest left faded. The same geom
produces a single-row rating widget, a waffle/percentage chart, or a
growing isotype-style unit chart, depending on the grid arguments
(`n`/`nrow`/`ncol`/`symbol_value`) passed to
[`stat_pictogram()`](https://pkg.mitchelloharawild.com/ggicons/reference/stat_pictogram.md).

## Usage

``` r
geom_pictogram(
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
)
```

## Arguments

- mapping:

  Set of aesthetic mappings created by
  [`aes()`](https://ggplot2.tidyverse.org/reference/aes.html). If
  specified and `inherit.aes = TRUE` (the default), it is combined with
  the default mapping at the top level of the plot. You must supply
  `mapping` if there is no plot mapping.

- data:

  The data to be displayed in this layer. There are three options:

  If `NULL`, the default, the data is inherited from the plot data as
  specified in the call to
  [`ggplot()`](https://ggplot2.tidyverse.org/reference/ggplot.html).

  A `data.frame`, or other object, will override the plot data. All
  objects will be fortified to produce a data frame. See
  [`fortify()`](https://ggplot2.tidyverse.org/reference/fortify.html)
  for which variables will be created.

  A `function` will be called with a single argument, the plot data. The
  return value must be a `data.frame`, and will be used as the layer
  data. A `function` can be created from a `formula` (e.g.
  `~ head(.x, 10)`).

- stat:

  The statistical transformation to use on the data for this layer. When
  using a `geom_*()` function to construct a layer, the `stat` argument
  can be used to override the default coupling between geoms and stats.
  The `stat` argument accepts the following:

  - A `Stat` ggproto subclass, for example `StatCount`.

  - A string naming the stat. To give the stat as a string, strip the
    function name of the `stat_` prefix. For example, to use
    [`stat_count()`](https://ggplot2.tidyverse.org/reference/geom_bar.html),
    give the stat as `"count"`.

  - For more information and other ways to specify the stat, see the
    [layer
    stat](https://ggplot2.tidyverse.org/reference/layer_stats.html)
    documentation.

- position:

  A position adjustment to use on the data for this layer. This can be
  used in various ways, including to prevent overplotting and improving
  the display. The `position` argument accepts the following:

  - The result of calling a position function, such as
    [`position_jitter()`](https://ggplot2.tidyverse.org/reference/position_jitter.html).
    This method allows for passing extra arguments to the position.

  - A string naming the position adjustment. To give the position as a
    string, strip the function name of the `position_` prefix. For
    example, to use
    [`position_jitter()`](https://ggplot2.tidyverse.org/reference/position_jitter.html),
    give the position as `"jitter"`.

  - For more information and other ways to specify the position, see the
    [layer
    position](https://ggplot2.tidyverse.org/reference/layer_positions.html)
    documentation.

- ...:

  Other arguments passed on to
  [`layer()`](https://ggplot2.tidyverse.org/reference/layer.html)'s
  `params` argument. These arguments broadly fall into one of 4
  categories below. Notably, further arguments to the `position`
  argument, or aesthetics that are required can *not* be passed through
  `...`. Unknown arguments that are not part of the 4 categories below
  are ignored.

  - Static aesthetics that are not mapped to a scale, but are at a fixed
    value and apply to the layer as a whole. For example,
    `colour = "red"` or `linewidth = 3`. The geom's documentation has an
    **Aesthetics** section that lists the available options. The
    'required' aesthetics cannot be passed on to the `params`. Please
    note that while passing unmapped aesthetics as vectors is
    technically possible, the order and required length is not
    guaranteed to be parallel to the input data.

  - When constructing a layer using a `stat_*()` function, the `...`
    argument can be used to pass on parameters to the `geom` part of the
    layer. An example of this is
    `stat_density(geom = "area", outline.type = "both")`. The geom's
    documentation lists which parameters it can accept.

  - Inversely, when constructing a layer using a `geom_*()` function,
    the `...` argument can be used to pass on parameters to the `stat`
    part of the layer. An example of this is
    `geom_area(stat = "density", adjust = 0.5)`. The stat's
    documentation lists which parameters it can accept.

  - The `key_glyph` argument of
    [`layer()`](https://ggplot2.tidyverse.org/reference/layer.html) may
    also be passed on through `...`. This can be one of the functions
    described as [key
    glyphs](https://ggplot2.tidyverse.org/reference/draw_key.html), to
    change the display of the layer in the legend.

- n:

  Total slots in the grid (fixed-grid mode). `NULL` (the default) grows
  the grid to fit `value` instead.

- nrow, ncol:

  Grid shape. Set at most one; the other is derived to wrap the slots.
  Both `NULL` wraps to a single row/column; see Orientation for which.

- symbol_value:

  The data value one slot represents. `NULL` (the default) picks one
  automatically: `1` in fixed-grid mode (`value` is already a slot
  count, e.g. a percentage out of `n = 100`), or, in growing mode, the
  smallest "nice" round number (1, 2 or 5 times a power of ten) that
  keeps the layer's largest value to around `n_target` icons; see that
  argument. Set explicitly to turn auto-picking off.

- n_target:

  In growing mode, roughly how many icons deep the growing dimension
  should get for the layer's largest value, when `symbol_value` is
  picked automatically. Turn this up for a finer-grained chart (more,
  smaller icons), down for a coarser one (fewer, bigger icons). Ignored
  if `symbol_value` is set explicitly, or in fixed-grid mode.

- flow:

  Fill order: `"row"` (default) fills left-to-right then wraps to the
  next row; `"col"` fills top-to-bottom then wraps to the next column.

- size.unit:

  The unit `size` is interpreted in, as in
  [`geom_icon()`](https://pkg.mitchelloharawild.com/ggicons/reference/geom_icon.md).
  Left at its default (`NA`), `size` instead auto-fits: each pictogram
  grows or shrinks to fill its own share of the panel, the way
  [`geom_bar()`](https://ggplot2.tidyverse.org/reference/geom_bar.html)
  derives bar width. Set `size` to a number to opt out to a fixed
  physical size.

- spacing:

  Gap between adjacent icons, as a fraction of `size`.

- hjust, vjust:

  Where the grid sits relative to `(x, y)`, as a fraction of its
  width/height: `0.5` centres it, `0`/`1` anchor an edge. Usually left
  at the default (`NULL`), which follows
  [`stat_pictogram()`](https://pkg.mitchelloharawild.com/ggicons/reference/stat_pictogram.md)'s
  orientation: centred on an axis you mapped, anchored to the panel edge
  on one you left unmapped. So leaving `y` out of
  [`aes()`](https://ggplot2.tidyverse.org/reference/aes.html) draws a
  column chart growing up from the bottom, and leaving `x` out draws a
  bar growing from the left.

- empty.colour, empty.alpha:

  Colour and alpha for empty slots. `empty.alpha` defaults to the
  `alpha` aesthetic.

- na.rm:

  If `FALSE`, the default, missing values are removed with a warning. If
  `TRUE`, missing values are silently removed.

- show.legend:

  logical. Should this layer be included in the legends? `NA`, the
  default, includes if any aesthetics are mapped. `FALSE` never
  includes, and `TRUE` always includes. It can also be a named logical
  vector to finely select the aesthetics to display. To include legend
  keys for all levels, even when no data exists, use `TRUE`. If `NA`,
  all levels are shown in legend, but unobserved levels are omitted.

- inherit.aes:

  If `FALSE`, overrides the default aesthetics, rather than combining
  with them. This is most useful for helper functions that define both
  data and aesthetics and shouldn't inherit behaviour from the default
  plot specification, e.g.
  [`annotation_borders()`](https://ggplot2.tidyverse.org/reference/annotation_borders.html).

## Value

A ggplot2 layer.

## Aesthetics

`geom_pictogram()` understands the following aesthetics (`value` and
`icon` are required):

- `x`, `y`: the grid's anchor position. Leaving one out draws a
  bar/column chart instead of a fixed-position grid; see
  [`stat_pictogram()`](https://pkg.mitchelloharawild.com/ggicons/reference/stat_pictogram.md)'s
  Orientation section.

- **`value`**: the magnitude a pictogram represents.
  [`stat_pictogram()`](https://pkg.mitchelloharawild.com/ggicons/reference/stat_pictogram.md)
  turns it into a filled slot count using `symbol_value`, the amount one
  icon stands for. Also drives an automatic
  [`guide_pictogram()`](https://pkg.mitchelloharawild.com/ggicons/reference/guide_pictogram.md)
  legend spelling that ratio out; turn it off with
  `guides(value = "none")`.

- **`icon`**: the icon drawn in every slot, filled or empty (as in
  [`geom_icon()`](https://pkg.mitchelloharawild.com/ggicons/reference/geom_icon.md)).

- `colour`/`fill`: the filled-slot colour; empty slots use
  `empty.colour` instead.

- `alpha`, `angle`, `size`: as in
  [`geom_icon()`](https://pkg.mitchelloharawild.com/ggicons/reference/geom_icon.md).

`geom_pictogram()` understands the following aesthetics. Required
aesthetics are displayed in bold and defaults are displayed for optional
aesthetics:

|  |  |  |
|----|----|----|
| • | **`value`** |  |
| • | **`icon`** |  |
| • | [`alpha`](https://ggplot2.tidyverse.org/reference/aes_colour_fill_alpha.html) | → `NA` |
| • | `angle` | → `0` |
| • | [`colour`](https://ggplot2.tidyverse.org/reference/aes_colour_fill_alpha.html) | → `"black"` |
| • | [`fill`](https://ggplot2.tidyverse.org/reference/aes_colour_fill_alpha.html) | → `NA` |
| • | [`group`](https://ggplot2.tidyverse.org/reference/aes_group_order.html) | → inferred |
| • | [`size`](https://ggplot2.tidyverse.org/reference/aes_linetype_size_shape.html) | → `NA` |

Learn more about setting these aesthetics in
[`vignette("ggplot2-specs")`](https://ggplot2.tidyverse.org/articles/ggplot2-specs.html).

## See also

[`stat_pictogram()`](https://pkg.mitchelloharawild.com/ggicons/reference/stat_pictogram.md),
[`geom_icon()`](https://pkg.mitchelloharawild.com/ggicons/reference/geom_icon.md),
[`guide_pictogram()`](https://pkg.mitchelloharawild.com/ggicons/reference/guide_pictogram.md)

## Examples

``` r
library(ggplot2)

# bundled placeholder shapes; a real pack (e.g. icons::fontawesome) works the same
shapes <- icons::icon_set(system.file("icons", package = "ggicons"))

# 10x10 waffle: 37%
ggplot(NULL, aes(x = "Proportion", value = 37)) +
  geom_pictogram(icon = shapes$square, n = 100, nrow = 10)


# single-row rating: 5 slots, 3 filled, legend switched off
ggplot(NULL, aes(y = "Rating", value = 3)) +
  geom_pictogram(icon = shapes$star, n = 5, colour = "goldenrod") +
  guides(value = "none")


# growing isotype chart: two categories, each sized to its own value
pets <- data.frame(animal = c("Cat", "Dog"), count = c(23, 15))
ggplot(pets, aes(animal, y = "Pet", value = count, icon = animal, colour = animal)) +
  geom_pictogram(nrow = 5) +
  scale_icon_manual(values = c(icons::fontawesome$solid$cat, icons::fontawesome$solid$dog))

# column chart: no y aesthetic, so icons fill like a column geometry
commutes <- data.frame(mode = c("Bicycle", "Car"), count = c(890, 1230))
ggplot(commutes, aes(mode, value = count, icon = mode, colour = mode)) +
  geom_pictogram(ncol = 5) +
  scale_icon_manual(values = c(icons::fontawesome$solid$bicycle, icons::fontawesome$solid$car)) +
  labs(value = "commuters")
```
