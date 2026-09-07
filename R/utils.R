#' @importFrom rlang %||%
NULL

# Give a grob a namespaced name so it's identifiable in gtable inspection.
ggname <- function(prefix, grob) {
  grob$name <- grid::grobName(grob, prefix)
  grob
}
