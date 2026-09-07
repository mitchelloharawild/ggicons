# A small bundled icon set of basic shapes (see inst/icons/), used in place of a
# downloaded icon library (e.g. fontawesome) so most tests don't need one installed.
# Real icon-pack integration (multi-style lookup, icon_find() across installed
# libraries, etc.) is exercised separately in test-fontawesome.R, which skips
# unless fontawesome is installed.
shapes <- icons::icon_set(system.file("icons", package = "ggicons"))
