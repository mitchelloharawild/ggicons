test_that("scale_type.icons() reports discrete", {
  expect_identical(scale_type.icons(icons::fontawesome$solid$rocket), "discrete")
  expect_identical(scale_type.icons(icons::icon_find("rocket")), "discrete")
})

test_that("scale_icon_identity() passes icon vectors through unchanged", {
  df <- data.frame(x = 1:2, y = 1:2)
  df$icon <- c(icons::fontawesome$solid$rocket, icons::fontawesome$solid$star)
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
  # cat's row order ("c", "a", "b") deliberately doesn't match vals' order,
  # to check values are matched against the *sorted* levels ("a", "b", "c"),
  # not named lookup (icon vectors don't support names) or row order.
  df <- data.frame(x = 1:3, y = 1:3, cat = c("c", "a", "b"))
  vals <- c(
    icons::fontawesome$solid$rocket,
    icons::fontawesome$solid$star,
    icons::fontawesome$solid$heart
  )
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, icon = cat)) +
    geom_icon() +
    scale_icon_manual(values = vals)

  expect_no_error(b <- ggplot2::ggplot_build(p))
  # vals[1:3] map to sorted levels "a", "b", "c"; rows are "c", "a", "b".
  expected <- unname(icons::icon_path(vals))[c(3, 1, 2)]
  expect_identical(unname(icons::icon_path(b$data[[1]]$icon)), expected)
  expect_no_error(grid::grid.draw(ggplot2::ggplotGrob(p)))
})
