test_that("geom_icon() requires the icon aesthetic", {
  df <- data.frame(x = 1:2, y = 1:2)
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y)) + geom_icon()
  expect_error(ggplot2::ggplot_build(p), "icon")
})

test_that("geom_icon() builds and draws without error for icon vectors", {
  df <- data.frame(x = 1:3, y = c(1, 3, 2))
  df$icon <- c(shapes$square, shapes$circle, shapes$triangle)
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, icon = icon)) + geom_icon(size = 10)

  expect_no_error(b <- ggplot2::ggplot_build(p))
  expect_no_error(grid::grid.draw(ggplot2::ggplotGrob(p)))

  # Icon vectors are resolved to SVG paths at draw time, not baked into the built layer data.
  expect_s3_class(b$data[[1]]$icon, "icons")
})

test_that("geom_icon() sees icons after scale mapping, not before", {
  df <- data.frame(x = 1:3, y = c(1, 3, 2), cat = c("a", "b", "c"))
  # Positional, not named: icon vectors don't support names, so values match sorted levels in order.
  vals <- c(shapes$square, shapes$circle, shapes$triangle)
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, icon = cat)) +
    geom_icon(size = 10) +
    scale_icon_manual(values = vals)

  expect_no_error(b <- ggplot2::ggplot_build(p))
  expect_s3_class(b$data[[1]]$icon, "icons")
  expect_no_error(grid::grid.draw(ggplot2::ggplotGrob(p)))
})

test_that("geom_icon() skips NA icons rather than failing the whole plot", {
  df <- data.frame(x = 1:3, y = 1:3)
  icon <- c(shapes$square, shapes$circle, shapes$triangle)
  icon[2] <- NA
  df$icon <- icon
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, icon = icon)) + geom_icon(size = 10)

  expect_no_error(g <- ggplot2::ggplotGrob(p))
  expect_no_error(grid::grid.draw(g))
})

test_that("geom_icon() gives a helpful error for an unmapped icon aesthetic", {
  # No default icon palette exists, so the raw character column must be caught with a clear error at ggplot_build().
  df <- data.frame(x = 1:3, y = c(1, 3, 2), type = c("a", "b", "c"))
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, icon = type)) + geom_icon()

  expect_error(
    ggplot2::ggplot_build(p),
    "scale_icon_manual"
  )
})

test_that("check_icon_aes() passes through icon vectors, icons and NULL", {
  expect_no_error(check_icon_aes(NULL))
  expect_no_error(check_icon_aes(shapes$square))
  # icon_find() searches every registered icon set, including custom ones like `shapes`
  expect_no_error(check_icon_aes(icons::icon_find("square")))
})

test_that("check_icon_aes() errors with a hint for non-icon values", {
  expect_error(check_icon_aes(c("a", "b")), "scale_icon_manual")
  expect_error(check_icon_aes(1:2), "scale_icon_manual")
})

test_that("draw_key_icon() returns a grob for a legend key row", {
  data <- data.frame(colour = "black", fill = NA, size = 6, alpha = NA, angle = 0)
  data$icon <- c(shapes$square)
  expect_no_error(g <- draw_key_icon(data, list(size.unit = "mm"), 1))
  expect_true(grid::is.grob(g))
})

test_that("draw_key_icon() copes with a borrowed key glyph with no icon column", {
  data <- data.frame(colour = "black", fill = NA, size = 6, alpha = NA, angle = 0)
  expect_no_error(g <- draw_key_icon(data, list(size.unit = "mm"), 1))
  expect_true(grid::is.grob(g))
})

test_that("icons keep equal x/y physical extents in a non-square viewport", {
  # size_npc must be computed per-axis; a shared factor would stretch icons to match the panel's aspect ratio.
  grid::grid.newpage()
  grid::pushViewport(grid::viewport(width = grid::unit(200, "mm"), height = grid::unit(50, "mm")))
  on.exit(grid::popViewport())

  ip <- iconpath_grob(
    local_x = c(-0.5, 0.5, 0.5, -0.5),
    local_y = c(-0.5, -0.5, 0.5, 0.5),
    pos_x = rep(0.5, 4), pos_y = rep(0.5, 4),
    size = rep(10, 4), size.unit = "mm",
    id.lengths = 4, pathId.lengths = 4, rule = "winding",
    gp = grid::gpar(fill = "black")
  )

  path <- grid::makeContent(ip)$children[[1]]
  width_in <- diff(range(grid::convertX(grid::unit(path$x, "npc"), "in", valueOnly = TRUE)))
  height_in <- diff(range(grid::convertY(grid::unit(path$y, "npc"), "in", valueOnly = TRUE)))

  expect_equal(width_in, height_in, tolerance = 1e-6)
})
