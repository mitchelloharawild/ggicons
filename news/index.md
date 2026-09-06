# Changelog

## ggicons (development version)

Initial CRAN submission.

- Added
  [`geom_icon()`](https://pkg.mitchelloharawild.com/ggicons/reference/geom_icon.md),
  a =geom that draws an icon per row from the `icon` aesthetic, styled
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
  to ordinary text for everything else. This is a first cut of the
  trickiest part of the package’s design, and ships with some known
  rough edges (documented in full in
  [`?element_icon`](https://pkg.mitchelloharawild.com/ggicons/reference/element_icon.md)):
  the lookup must be a named
  [`list()`](https://rdrr.io/r/base/list.html) of individual icons
  rather than a named icon vector (the `icons` package’s vector type
  can’t carry element names at all); icon sizing follows a simple `size`
  (points) convention rather than matching text x-height exactly; and
  `hjust`/`vjust`/margin nudging only apply to the text-fallback side,
  not to icons (which are always centred at the label position).
