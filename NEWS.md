# ggicons (development version)

Initial CRAN submission.

* Added `geom_icon()`, a =geom that draws an icon per row from the `icon` 
  aesthetic, styled with `colour`/`fill`, `size`, `alpha` and `angle`. The 
  `icon` aesthetic takes an icon vector from the `icons` package directly (e.g. `icons::fontawesome$solid$rocket`).
* Added `draw_key_icon()`, the default `geom_icon()` legend key glyph.
* Added `scale_icon_identity()` and `scale_icon_manual()`, plus 
  `scale_type.icon()` method so `aes(icon = ...)` picks a sensible scale.
