# Map discrete values to icons manually

`scale_icon_manual()` maps a discrete data value (e.g. a category
column) to an icon, using a manually-specified lookup, the `icon`
analogue of
[`ggplot2::scale_shape_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html).
There's no automatic discrete palette for icons, so `values` is
required.

## Usage

``` r
scale_icon_manual(..., values, breaks = ggplot2::waiver(), na.value = NA)
```

## Arguments

- ...:

  Arguments passed on to
  [`discrete_scale`](https://ggplot2.tidyverse.org/reference/discrete_scale.html)

  `limits`

  :   One of:

      - `NULL` to use the default scale values

      - A character vector that defines possible values of the scale and
        their order

      - A function that accepts the existing (automatic) values and
        returns new ones. Also accepts rlang
        [lambda](https://rlang.r-lib.org/reference/as_function.html)
        function notation.

  `drop`

  :   Should unused factor levels be omitted from the scale? The
      default, `TRUE`, uses the levels that appear in the data; `FALSE`
      includes the levels in the factor. Please note that to display
      every level in a legend, the layer should use
      `show.legend = TRUE`.

  `na.translate`

  :   Unlike continuous scales, discrete scales can easily show missing
      values, and do so by default. If you want to remove missing values
      from a discrete scale, specify `na.translate = FALSE`.

  `name`

  :   The name of the scale. Used as the axis or legend title. If
      [`waiver()`](https://ggplot2.tidyverse.org/reference/waiver.html),
      the default, the name of the scale is taken from the first mapping
      used for that aesthetic. If `NULL`, the legend title will be
      omitted.

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

  `labels`

  :   One of the options below. Please note that when `labels` is a
      vector, it is highly recommended to also set the `breaks` argument
      as a vector to protect against unintended mismatches.

      - `NULL` for no labels

      - [`waiver()`](https://ggplot2.tidyverse.org/reference/waiver.html)
        for the default labels computed by the transformation object

      - A character vector giving labels (must be same length as
        `breaks`)

      - An expression vector (must be the same length as breaks). See
        ?plotmath for details.

      - A function that takes the breaks as input and returns labels as
        output. Also accepts rlang
        [lambda](https://rlang.r-lib.org/reference/as_function.html)
        function notation.

  `guide`

  :   A function used to create a guide or its name. See
      [`guides()`](https://ggplot2.tidyverse.org/reference/guides.html)
      for more information.

  `call`

  :   The `call` used to construct the scale for reporting messages.

  `super`

  :   The super class to use for the constructed scale

- values:

  An icon vector from the
  [icons](https://github.com/mitchelloharawild/icons) package, the same
  length as the number of levels to map. Unlike most `scale_*_manual()`
  counterparts, `values` can't be named by level, since icon vectors
  don't support names, so it's matched positionally against the sorted
  data levels; use `breaks` to map against a different order.

- breaks:

  One of:

  - `NULL` for no breaks

  - [`waiver()`](https://ggplot2.tidyverse.org/reference/waiver.html)
    for the default breaks (the scale limits)

  - A character vector of breaks

  - A function that takes the limits as input and returns breaks as
    output

- na.value:

  The aesthetic value to use for missing (`NA`) values

## Value

A ggplot2 scale.

## See also

[`scale_icon_identity()`](https://pkg.mitchelloharawild.com/ggicons/reference/scale_icon_identity.md)

## Examples

``` r
library(ggplot2)
library(icons)

df <- data.frame(
  x = 1:3, y = c(1, 3, 2),
  type = c("a", "b", "c")
)
ggplot(df, aes(x, y, icon = type)) +
  geom_icon(size = 10) +
  scale_icon_manual(values = c(
    fontawesome$solid$rocket,
    fontawesome$solid$star,
    fontawesome$solid$heart
  ))
#> Error: ✖ The fontawesome icon library is not yet installed.
#> ℹ Install it with `download_fontawesome()`.
```
