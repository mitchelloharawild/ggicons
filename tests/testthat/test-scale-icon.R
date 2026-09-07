test_that("scale_type.icons() reports discrete", {
  expect_identical(scale_type.icons(shapes$square), "discrete")
  # icon_find() searches every registered icon set, including custom ones like `shapes`
  expect_identical(scale_type.icons(icons::icon_find("square")), "discrete")
})

test_that("scale_icon_identity() passes icon vectors through unchanged", {
  df <- data.frame(x = 1:2, y = 1:2)
  df$icon <- c(shapes$square, shapes$circle)
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, icon = icon)) +
    geom_icon() +
    scale_icon_identity()

  expect_no_error(b <- ggplot2::ggplot_build(p))
  expect_identical(b$data[[1]]$icon, df$icon)
  expect_no_error(grid::grid.draw(ggplot2::ggplotGrob(p)))
})

test_that("scale_icon_identity() draws no legend by default", {
  s <- scale_icon_identity()
  expect_identical(s$guide, "none")
})

test_that("scale_icon_manual() maps discrete levels to icons positionally", {
  # Row order deliberately differs from vals' order, to check values match sorted levels, not row order.
  df <- data.frame(x = 1:3, y = 1:3, cat = c("c", "a", "b"))
  vals <- c(shapes$square, shapes$circle, shapes$triangle)
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, icon = cat)) +
    geom_icon() +
    scale_icon_manual(values = vals)

  expect_no_error(b <- ggplot2::ggplot_build(p))
  # vals map to sorted levels a/b/c; rows are ordered c/a/b.
  expected <- unname(icons::icon_path(vals))[c(3, 1, 2)]
  expect_identical(unname(icons::icon_path(b$data[[1]]$icon)), expected)
  expect_no_error(grid::grid.draw(ggplot2::ggplotGrob(p)))
})
