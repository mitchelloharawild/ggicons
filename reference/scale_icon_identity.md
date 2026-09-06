# Use icon values as-is

`scale_icon_identity()` is for the common case where the `icon`
aesthetic is already mapped to icon values (an icon vector from the
[icons](https://github.com/mitchelloharawild/icons) package), so the
data is passed through unchanged rather than looked up in a palette. No
legend is drawn by default, as with
[`ggplot2::scale_shape_identity()`](https://ggplot2.tidyverse.org/reference/scale_identity.html).

## Usage

``` r
scale_icon_identity(
  name = ggplot2::waiver(),
  ...,
  guide = "none",
  aesthetics = "icon"
)
```

## Arguments

- name:

  The name of the scale. Used as the axis or legend title. If
  [`waiver()`](https://ggplot2.tidyverse.org/reference/waiver.html), the
  default, the name of the scale is taken from the first mapping used
  for that aesthetic. If `NULL`, the legend title will be omitted.

- ...:

  Other arguments passed on to
  [`discrete_scale()`](https://ggplot2.tidyverse.org/reference/discrete_scale.html)
  or
  [`continuous_scale()`](https://ggplot2.tidyverse.org/reference/continuous_scale.html)

- guide:

  Guide to use for this scale. Defaults to `"none"`.

- aesthetics:

  Character string(s) naming the aesthetic(s) this scale works with,
  defaulting to `"icon"`.

## Value

A ggplot2 scale.

## Details

Requesting a legend (`guide = "legend"`) isn't supported here: ggplot2's
discrete scale training only recognises character/factor data, not icon
vectors. Use
[`scale_icon_manual()`](https://pkg.mitchelloharawild.com/ggicons/reference/scale_icon_manual.md)
instead when a legend is needed.

## See also

[`scale_icon_manual()`](https://pkg.mitchelloharawild.com/ggicons/reference/scale_icon_manual.md)
