# Continuous scale for the pictogram value aesthetic

`scale_value_continuous()` registers `value` (as mapped in
[`geom_pictogram()`](https://pkg.mitchelloharawild.com/ggicons/reference/geom_pictogram.md))
as a real trained aesthetic, purely so it can carry a default guide (see
[`guide_pictogram()`](https://pkg.mitchelloharawild.com/ggicons/reference/guide_pictogram.md)).
It never rescales `value` itself: `symbol_value` slot counts need the
real data value, so the palette is the identity function.

## Usage

``` r
scale_value_continuous(
  name = ggplot2::waiver(),
  breaks = ggplot2::waiver(),
  labels = ggplot2::waiver(),
  limits = NULL,
  guide = "pictogram",
  ...
)
```

## Arguments

- name:

  The name of the scale. Used as the axis or legend title. If
  [`waiver()`](https://ggplot2.tidyverse.org/reference/waiver.html), the
  default, the name of the scale is taken from the first mapping used
  for that aesthetic. If `NULL`, the legend title will be omitted.

- breaks:

  One of:

  - `NULL` for no breaks

  - [`waiver()`](https://ggplot2.tidyverse.org/reference/waiver.html)
    for the default breaks computed by the [transformation
    object](https://scales.r-lib.org/reference/new_transform.html)

  - A numeric vector of positions

  - A function that takes the limits as input and returns breaks as
    output (e.g., a function returned by
    [`scales::extended_breaks()`](https://scales.r-lib.org/reference/breaks_extended.html)).
    Note that for position scales, limits are provided after scale
    expansion. Also accepts rlang
    [lambda](https://rlang.r-lib.org/reference/as_function.html)
    function notation.

- labels:

  One of the options below. Please note that when `labels` is a vector,
  it is highly recommended to also set the `breaks` argument as a vector
  to protect against unintended mismatches.

  - `NULL` for no labels

  - [`waiver()`](https://ggplot2.tidyverse.org/reference/waiver.html)
    for the default labels computed by the transformation object

  - A character vector giving labels (must be same length as `breaks`)

  - An expression vector (must be the same length as breaks). See
    ?plotmath for details.

  - A function that takes the breaks as input and returns labels as
    output. Also accepts rlang
    [lambda](https://rlang.r-lib.org/reference/as_function.html)
    function notation.

- limits:

  One of:

  - `NULL` to use the default scale range

  - A numeric vector of length two providing limits of the scale. Use
    `NA` to refer to the existing minimum or maximum

  - A function that accepts the existing (automatic) limits and returns
    new limits. Also accepts rlang
    [lambda](https://rlang.r-lib.org/reference/as_function.html)
    function notation. Note that setting limits on positional scales
    will **remove** data outside of the limits. If the purpose is to
    zoom, use the limit argument in the coordinate system (see
    [`coord_cartesian()`](https://ggplot2.tidyverse.org/reference/coord_cartesian.html)).

- guide:

  The value legend's guide; defaults to
  [`guide_pictogram()`](https://pkg.mitchelloharawild.com/ggicons/reference/guide_pictogram.md).
  Set to `"none"` (or pass `show.legend = FALSE` to
  [`geom_pictogram()`](https://pkg.mitchelloharawild.com/ggicons/reference/geom_pictogram.md))
  to hide it.

- ...:

  Arguments passed on to
  [`continuous_scale`](https://ggplot2.tidyverse.org/reference/continuous_scale.html)

  `minor_breaks`

  :   One of:

      - `NULL` for no minor breaks

      - [`waiver()`](https://ggplot2.tidyverse.org/reference/waiver.html)
        for the default breaks (none for discrete, one minor break
        between each major break for continuous)

      - A numeric vector of positions

      - A function that given the limits returns a vector of minor
        breaks. Also accepts rlang
        [lambda](https://rlang.r-lib.org/reference/as_function.html)
        function notation. When the function has two arguments, it will
        be given the limits and major break positions.

  `oob`

  :   One of:

      - Function that handles limits outside of the scale limits (out of
        bounds). Also accepts rlang
        [lambda](https://rlang.r-lib.org/reference/as_function.html)
        function notation.

      - The default
        ([`scales::censor()`](https://scales.r-lib.org/reference/oob.html))
        replaces out of bounds values with `NA`.

      - [`scales::squish()`](https://scales.r-lib.org/reference/oob.html)
        for squishing out of bounds values into range.

      - [`scales::squish_infinite()`](https://scales.r-lib.org/reference/oob.html)
        for squishing infinite values into range.

  `na.value`

  :   Missing values will be replaced with this value.

  `call`

  :   The `call` used to construct the scale for reporting messages.

  `super`

  :   The super class to use for the constructed scale

## Value

A ggplot2 scale.

## Details

Picked up automatically for `aes(value = ...)`, so most plots never need
to call it directly. Exported for overriding `guide` or setting explicit
`breaks`.

## See also

[`guide_pictogram()`](https://pkg.mitchelloharawild.com/ggicons/reference/guide_pictogram.md),
[`geom_pictogram()`](https://pkg.mitchelloharawild.com/ggicons/reference/geom_pictogram.md)

## Examples

``` r
library(ggplot2)

# bundled placeholder shapes; a real pack (e.g. icons::fontawesome) works the same
shapes <- icons::icon_set(system.file("icons", package = "ggicons"))

# applied automatically; shown explicitly here just to relabel the legend
ggplot(NULL, aes(x = "Proportion", value = 37)) +
  geom_pictogram(icon = shapes$square, n = 100, nrow = 10) +
  scale_value_continuous(name = "%")
```
