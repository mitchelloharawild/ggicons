# ggicons 0.1.0

Initial CRAN submission.

* Added `geom_icon()`, a geom that draws an icon per row from the `icon` 
  aesthetic, styled with `colour`/`fill`, `size`, `alpha` and `angle`. The 
  `icon` aesthetic takes an icon vector from the `icons` package directly (e.g. `icons::fontawesome$solid$rocket`).
* Added `draw_key_icon()`, the default `geom_icon()` legend key glyph.
* Added `scale_icon_identity()` and `scale_icon_manual()`, plus 
  `scale_type.icon()` method so `aes(icon = ...)` picks a sensible scale.
* Added `annotation_icon()`, for drawing one or more icons at fixed
  positions, recycled the way `annotate()` recycles its arguments.
* Added `element_icon()`, a `theme()` element (parallel to `element_text()`)
  for `axis.text`/`strip.text`/`legend.text` that draws any label matching
  a name in a supplied `icons` lookup as an icon, falling back to ordinary
  text for everything else.
* Added `geom_pictogram()` and `stat_pictogram()`, for isotype-style unit
  charts, waffle/percentage charts and rating widgets: a `value` is turned
  into a grid of repeated icons, some fraction of them filled in. The grid
  can be fixed-size (a waffle chart) or grow with `value` (an isotype
  chart), and reads as a bar/column chart when `x` or `y` is left unmapped.
* Added `guide_pictogram()` and `scale_value_continuous()`, which together
  give `geom_pictogram()`'s `value` aesthetic a default legend spelling out
  the amount one icon represents (e.g. "= 1000").
