# Pictogram grid layout

`stat_pictogram()` turns one row of data (an anchor position and a
`value`) into one row per icon slot in a grid, ready for
[`geom_pictogram()`](https://pkg.mitchelloharawild.com/ggicons/reference/geom_pictogram.md)
to draw. It's the counting/layout half of a pictogram.

## Usage

``` r
stat_pictogram(
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

- geom:

  Override the default connection between `stat_pictogram()` and
  [`geom_pictogram()`](https://pkg.mitchelloharawild.com/ggicons/reference/geom_pictogram.md).
  For more information about overriding these connections, see
  [`ggplot2::layer()`](https://ggplot2.tidyverse.org/reference/layer.html).

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

## Grid sizing

Two modes, chosen by whether `n` (or both `nrow` and `ncol`) is set:

- **Fixed grid** (`n`, or both `nrow`/`ncol`, given): the grid always
  has `n` slots; `round(value / symbol_value)` of them are filled
  (capped at `n`), the rest empty. This is the
  waffle-chart/rating-widget shape: proportions vary, the grid footprint
  doesn't.

- **Growing grid** (`n`, `nrow` and `ncol` all left `NULL`, or only one
  of `nrow`/`ncol` given): the grid has exactly
  `round(value / symbol_value)` slots, all filled. An isotype/unit-chart
  shape where more icons *is* the value, so the footprint grows with it.

At most one of `nrow`/`ncol` needs setting; the other wraps to fit. With
neither set, the grid defaults to a single row, unless `x`/`y` asks for
a bar/column shape instead; see Orientation below.

## Orientation

`x` and `y` are the grid's anchor, but only `value` is actually
required. Map both and you get a fixed-position grid, centred on
`(x, y)`: a waffle chart or rating widget. Leave one unmapped and that
becomes the growth axis of a bar-style stack instead, anchored to that
edge of the plot panel. `aes(x = category, value = count)` draws a
column chart, one growing column per category, up from the bottom of the
panel; `aes(y = category, value = count)` draws a horizontal bar,
growing right from the left of the panel.

## See also

[`geom_pictogram()`](https://pkg.mitchelloharawild.com/ggicons/reference/geom_pictogram.md)

## Examples

``` r
library(ggplot2)

# bundled placeholder shapes; a real pack (e.g. icons::fontawesome) works the same
shapes <- icons::icon_set(system.file("icons", package = "ggicons"))

# only needed directly when pairing with a different geom
ggplot(NULL, aes(x = "Proportion", value = 37)) +
  stat_pictogram(geom = "pictogram", icon = shapes$square, n = 100, nrow = 10)
```
