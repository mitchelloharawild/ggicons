# Exercises ggicons against a real, downloaded icon pack (Font Awesome), rather than the
# bundled `shapes` set the other test files use. Most behaviour doesn't depend on which icon
# pack backs an icon vector, so this file is deliberately thin: it just checks that a real
# multi-style pack (icon_find() searching across libraries, a pack requiring download before
# `$style$name` resolves, etc.) plugs into the same code paths.
#
# Font Awesome is never available on CRAN, so this always skips there; R-CMD-check.yaml
# downloads it in CI so this file actually runs there, rather than always skipping.
skip_on_cran()
skip_if_not(
  icons::icon_installed(icons::fontawesome),
  "fontawesome icon pack is not installed (see icons::download_fontawesome())"
)

test_that("a real icon pack builds and draws like the bundled shapes do", {
  df <- data.frame(x = 1:3, y = c(1, 3, 2))
  df$icon <- c(
    icons::fontawesome$solid$rocket,
    icons::fontawesome$solid$star,
    icons::fontawesome$solid$heart
  )
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, icon = icon)) + geom_icon(size = 10)

  expect_no_error(b <- ggplot2::ggplot_build(p))
  expect_s3_class(b$data[[1]]$icon, "icons")
  expect_no_error(grid::grid.draw(ggplot2::ggplotGrob(p)))
})

test_that("icon_find() locates an icon that only exists in an installed pack", {
  found <- icons::icon_find("rocket")
  expect_s3_class(found, "icons")
  expect_true(length(found) >= 1)
  expect_no_error(check_icon_aes(found))
})

test_that("scale_type.icons() reports discrete for a real pack's icons", {
  expect_identical(scale_type.icons(icons::fontawesome$solid$rocket), "discrete")
})

test_that("element_icon() substitutes real icon-pack icons for matching labels", {
  battery <- list(
    `4` = icons::fontawesome$solid$`battery-quarter`,
    `6` = icons::fontawesome$solid$`battery-half`,
    `8` = icons::fontawesome$solid$`battery-full`
  )
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(factor(cyl), mpg)) +
    ggplot2::geom_boxplot() +
    ggplot2::theme(axis.text.x = element_icon(icons = battery, size = 12))

  expect_no_error(ggplot2::ggplot_build(p))
  expect_no_error(grid::grid.draw(ggplot2::ggplotGrob(p)))
})

test_that("geom_pictogram() draws an isotype chart with per-category real-pack icons", {
  pets <- data.frame(animal = c("Cat", "Dog"), count = c(23, 15))
  p <- ggplot2::ggplot(
    pets,
    ggplot2::aes(animal, y = "Pet", value = count, icon = animal, colour = animal)
  ) +
    geom_pictogram(nrow = 5) +
    scale_icon_manual(values = c(icons::fontawesome$solid$cat, icons::fontawesome$solid$dog))

  expect_no_error(grid::grid.draw(ggplot2::ggplotGrob(p)))
})
