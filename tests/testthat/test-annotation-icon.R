test_that("annotation_icon() builds and draws without error for a single icon", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = c(1, 3, 2)), ggplot2::aes(x, y)) +
    ggplot2::geom_point() +
    annotation_icon(icon = icons::fontawesome$solid$rocket, x = 2, y = 3, size = 10)

  expect_no_error(b <- ggplot2::ggplot_build(p))
  expect_no_error(grid::grid.draw(ggplot2::ggplotGrob(p)))
  expect_s3_class(b$data[[2]]$icon, "icons")
  # colour/fill/size/alpha/angle are mapped as aesthetics for
  # vectorisation, but must come out *literally* -- not run through
  # ggplot2's default scale for that aesthetic (e.g. size's default
  # continuous area rescaling, which would silently turn a literal 10 into
  # something else).
  expect_identical(unclass(b$data[[2]]$size), 10)
})

test_that("annotation_icon() vectorises/recycles icon, position and style args", {
  vals <- c(icons::fontawesome$solid$rocket, icons::fontawesome$solid$star)
  p <- ggplot2::ggplot() +
    annotation_icon(icon = vals, x = c(1, 2), y = c(1, 1), colour = "steelblue")

  expect_no_error(b <- ggplot2::ggplot_build(p))
  expect_length(b$data[[1]]$icon, 2)
  expect_identical(b$data[[1]]$x, c(1, 2))
  expect_identical(b$data[[1]]$y, c(1, 1))
  expect_identical(unclass(b$data[[1]]$colour), c("steelblue", "steelblue"))
  expect_no_error(grid::grid.draw(ggplot2::ggplotGrob(p)))
})

test_that("annotation_icon() recycles a single icon across multiple positions", {
  p <- ggplot2::ggplot() +
    annotation_icon(icon = icons::fontawesome$solid$heart, x = c(1, 2, 3), y = c(1, 1, 1))

  expect_no_error(b <- ggplot2::ggplot_build(p))
  expect_length(b$data[[1]]$icon, 3)
})

test_that("annotation_icon() errors with a helpful message for a non-icon value", {
  expect_error(
    annotation_icon(icon = "not-an-icon", x = 1, y = 1),
    "icon"
  )
  expect_error(
    annotation_icon(icon = 1:2, x = 1, y = 1),
    "icon"
  )
})

test_that("annotation_icon() never shows a legend", {
  layer <- annotation_icon(icon = icons::fontawesome$solid$rocket, x = 1, y = 1)
  expect_identical(layer$show.legend, FALSE)
})

test_that("annotation_icon() renders to a graphics device without error", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = c(1, 3, 2)), ggplot2::aes(x, y)) +
    ggplot2::geom_point() +
    annotation_icon(icon = icons::fontawesome$solid$rocket, x = 2, y = 3, size = 10)

  path <- tempfile(fileext = ".png")
  on.exit(unlink(path), add = TRUE)
  expect_no_error(ggplot2::ggsave(path, p, width = 4, height = 3))
  expect_true(file.exists(path))
})
