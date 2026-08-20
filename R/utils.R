#' @importFrom rlang %||%
NULL

# Give a grob a namespaced name, mirroring ggplot2's internal `ggname()`
# helper, so grobs are identifiable (e.g. in gtable inspection) without
# depending on an unexported ggplot2 function.
ggname <- function(prefix, grob) {
  grob$name <- grid::grobName(grob, prefix)
  grob
}
