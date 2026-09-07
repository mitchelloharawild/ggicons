# Recursively collects grid text-grob labels from a gtable/gTree, to check what a guide
# actually rendered without depending on ggplot2's internal guide/gtable structure.
find_text_labels <- function(grob) {
  if (is.null(grob)) return(character())
  labels <- if (inherits(grob, "text")) as.character(grob$label) else character()
  for (child in c(grob$children, grob$grobs)) labels <- c(labels, find_text_labels(child))
  labels
}

# ggplotGrob() always reserves a "guide-box-<side>" cell, populated with a zeroGrob when there's
# nothing to draw there - so its mere presence in the layout doesn't say whether a legend
# actually rendered, only whether the cell is non-empty.
has_legend <- function(p, side = "right") {
  gt <- ggplot2::ggplotGrob(p)
  idx <- which(gt$layout$name == paste0("guide-box-", side))
  !inherits(gt$grobs[[idx]], "zeroGrob")
}

test_that("value is trained as a continuous scale with guide_pictogram() by default", {
  df <- data.frame(x = "a", value = 37)
  p <- ggplot2::ggplot(df, ggplot2::aes(x, value = value)) +
    geom_pictogram(icon = icons::fontawesome$solid$square, n = 100, nrow = 10)

  b <- ggplot2::ggplot_build(p)
  scale <- b$plot$scales$get_scales("value")
  expect_s3_class(scale, "ScaleContinuous")
  expect_identical(scale$map(37), 37) # unrescaled, unlike scale_size_continuous()
})

test_that("geom_pictogram() draws an automatic value legend with symbol_value's ratio", {
  df <- data.frame(x = "a", value = 37)
  p <- ggplot2::ggplot(df, ggplot2::aes(x, value = value)) +
    geom_pictogram(icon = icons::fontawesome$solid$square, n = 100, nrow = 10, symbol_value = 5) +
    ggplot2::labs(value = "widgets")

  expect_true(has_legend(p))
  labels <- find_text_labels(ggplot2::ggplotGrob(p))
  expect_true("widgets" %in% labels)
  expect_true("= 5" %in% labels)
})

test_that("the legend shows decimals for an explicit symbol_value under 1", {
  df <- data.frame(x = "a", value = 37)
  p <- ggplot2::ggplot(df, ggplot2::aes(x, value = value)) +
    geom_pictogram(icon = icons::fontawesome$solid$square, n = 100, nrow = 10, symbol_value = 0.5)

  labels <- find_text_labels(ggplot2::ggplotGrob(p))
  expect_true("= 0.5" %in% labels)
})

test_that("the value legend can be suppressed", {
  df <- data.frame(x = "a", value = 37)
  base <- ggplot2::ggplot(df, ggplot2::aes(x, value = value)) +
    geom_pictogram(icon = icons::fontawesome$solid$square, n = 100, nrow = 10)

  expect_true(has_legend(base))
  expect_false(has_legend(base + ggplot2::guides(value = "none")))

  hidden <- ggplot2::ggplot(df, ggplot2::aes(x, value = value)) +
    geom_pictogram(
      icon = icons::fontawesome$solid$square, n = 100, nrow = 10,
      show.legend = FALSE
    )
  expect_false(has_legend(hidden))
})

test_that("guide_pictogram() lets title/label/symbol_value/icon be overridden", {
  df <- data.frame(x = "a", value = 37)
  p <- ggplot2::ggplot(df, ggplot2::aes(x, value = value)) +
    geom_pictogram(icon = icons::fontawesome$solid$square, n = 100, nrow = 10) +
    ggplot2::guides(value = guide_pictogram(
      title = "Meaning",
      label = "one percentage point",
      symbol_value = 2
    ))

  expect_no_error(gt <- ggplot2::ggplotGrob(p))
  labels <- find_text_labels(gt)
  expect_true("Meaning" %in% labels)
  expect_true("one percentage point" %in% labels)
})

test_that("a mapped icon falls back to a colour swatch, or an explicit override", {
  df <- data.frame(animal = c("Cat", "Dog"), count = c(23, 15))
  p <- ggplot2::ggplot(
    df,
    ggplot2::aes(animal, value = count, icon = animal, colour = animal)
  ) +
    geom_pictogram(symbol_value = 5) +
    scale_icon_manual(values = c(icons::fontawesome$solid$cat, icons::fontawesome$solid$dog))

  # No single icon represents both categories - shouldn't error, and shouldn't need one.
  expect_no_error(grid::grid.draw(ggplot2::ggplotGrob(p)))

  overridden <- p + ggplot2::guides(value = guide_pictogram(icon = icons::fontawesome$solid$paw))
  expect_no_error(grid::grid.draw(ggplot2::ggplotGrob(overridden)))
})
