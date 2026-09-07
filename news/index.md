# Changelog

## ggicons (development version)

Initial CRAN submission.

- Added
  [`geom_icon()`](https://pkg.mitchelloharawild.com/ggicons/reference/geom_icon.md),
  a geom that draws an icon per row from the `icon` aesthetic, styled
  with `colour`/`fill`, `size`, `alpha` and `angle`. The `icon`
  aesthetic takes an icon vector from the `icons` package directly
  (e.g. `icons::fontawesome$solid$rocket`).
- Added
  [`draw_key_icon()`](https://pkg.mitchelloharawild.com/ggicons/reference/draw_key_icon.md),
  the default
  [`geom_icon()`](https://pkg.mitchelloharawild.com/ggicons/reference/geom_icon.md)
  legend key glyph.
- Added
  [`scale_icon_identity()`](https://pkg.mitchelloharawild.com/ggicons/reference/scale_icon_identity.md)
  and
  [`scale_icon_manual()`](https://pkg.mitchelloharawild.com/ggicons/reference/scale_icon_manual.md),
  plus `scale_type.icon()` method so `aes(icon = ...)` picks a sensible
  scale.
- Added
  [`annotation_icon()`](https://pkg.mitchelloharawild.com/ggicons/reference/annotation_icon.md),
  for drawing one or more icons at fixed positions, recycled the way
  [`annotate()`](https://ggplot2.tidyverse.org/reference/annotate.html)
  recycles its arguments.
- Added
  [`element_icon()`](https://pkg.mitchelloharawild.com/ggicons/reference/element_icon.md),
  a [`theme()`](https://ggplot2.tidyverse.org/reference/theme.html)
  element (parallel to
  [`element_text()`](https://ggplot2.tidyverse.org/reference/element.html))
  for `axis.text`/`strip.text`/`legend.text` that draws any label
  matching a name in a supplied `icons` lookup as an icon, falling back
  to ordinary text for everything else.
- Added
  [`geom_pictogram()`](https://pkg.mitchelloharawild.com/ggicons/reference/geom_pictogram.md)
  and
  [`stat_pictogram()`](https://pkg.mitchelloharawild.com/ggicons/reference/stat_pictogram.md),
  for isotype-style unit charts, waffle/percentage charts and rating
  widgets: a `value` is turned into a grid of repeated icons, some
  fraction of them filled in. The grid can be fixed-size (a waffle
  chart) or grow with `value` (an isotype chart), and reads as a
  bar/column chart when `x` or `y` is left unmapped.
- Added
  [`guide_pictogram()`](https://pkg.mitchelloharawild.com/ggicons/reference/guide_pictogram.md)
  and
  [`scale_value_continuous()`](https://pkg.mitchelloharawild.com/ggicons/reference/scale_value_continuous.md),
  which together give
  [`geom_pictogram()`](https://pkg.mitchelloharawild.com/ggicons/reference/geom_pictogram.md)’s
  `value` aesthetic a default legend spelling out the amount one icon
  represents (e.g. “= 1000”).
