# ggicons (development version)

Initial CRAN submission.

* Added `geom_icon()`, a =geom that draws an icon per row from the `icon` 
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
  text for everything else. This is a first cut of the trickiest part of
  the package's design, and ships with some known rough edges (documented
  in full in `?element_icon`): the lookup must be a named `list()` of
  individual icons rather than a named icon vector (the `icons` package's
  vector type can't carry element names at all); icon sizing follows a
  simple `size` (points) convention rather than matching text x-height
  exactly; and `hjust`/`vjust`/margin nudging only apply to the text-fallback
  side, not to icons (which are always centred at the label position).
