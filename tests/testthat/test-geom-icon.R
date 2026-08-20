test_that("geom_icon() requires the icon aesthetic", {
  df <- data.frame(x = 1:2, y = 1:2)
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y)) + geom_icon()
  expect_error(ggplot2::ggplot_build(p), "icon")
})

test_that("geom_icon() builds and draws without error for icon vectors", {
  df <- data.frame(x = 1:3, y = c(1, 3, 2))
  df$icon <- c(
    icons::fontawesome$solid$rocket,
    icons::fontawesome$solid$star,
    icons::fontawesome$solid$heart
  )
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, icon = icon)) + geom_icon(size = 10)

  expect_no_error(b <- ggplot2::ggplot_build(p))
  expect_no_error(grid::grid.draw(ggplot2::ggplotGrob(p)))

  # Icon vectors are resolved to SVG paths at draw time (see draw_panel),
  # not baked into the built layer data.
  expect_s3_class(b$data[[1]]$icon, "icon_vec")
})

test_that("geom_icon() sees icons after scale mapping, not before", {
  df <- data.frame(x = 1:3, y = c(1, 3, 2), cat = c("a", "b", "c"))
  # Positional, not named: icon vectors don't support names, so values are
  # matched against the sorted data levels ("a", "b", "c") in order.
  vals <- c(
    icons::fontawesome$solid$rocket,
    icons::fontawesome$solid$star,
    icons::fontawesome$solid$heart
  )
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, icon = cat)) +
    geom_icon(size = 10) +
    scale_icon_manual(values = vals)

  expect_no_error(b <- ggplot2::ggplot_build(p))
  expect_s3_class(b$data[[1]]$icon, "icon_vec")
  expect_no_error(grid::grid.draw(ggplot2::ggplotGrob(p)))
})

test_that("geom_icon() skips NA icons rather than failing the whole plot", {
  df <- data.frame(x = 1:3, y = 1:3)
  icon <- c(
    icons::fontawesome$solid$rocket,
    icons::fontawesome$solid$star,
    icons::fontawesome$solid$heart
  )
  icon[2] <- NA
  df$icon <- icon
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, icon = icon)) + geom_icon(size = 10)

  expect_no_error(g <- ggplot2::ggplotGrob(p))
  expect_no_error(grid::grid.draw(g))
})

test_that("geom_icon() gives a helpful error for an unmapped icon aesthetic", {
  # No scale converts `type` into icons (no default icon palette exists),
  # so `data$icon` is still the raw character column by draw time -- this
  # should be caught (and explained) at ggplot_build(), not left to surface
  # as icons::icon_path()'s opaque error inside grob conversion.
  df <- data.frame(x = 1:3, y = c(1, 3, 2), type = c("a", "b", "c"))
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, icon = type)) + geom_icon()

  expect_error(
    ggplot2::ggplot_build(p),
    "scale_icon_manual"
  )
})

test_that("check_icon_aes() passes through icon vectors, icons and NULL", {
  expect_no_error(check_icon_aes(NULL))
  expect_no_error(check_icon_aes(icons::fontawesome$solid$rocket))
  expect_no_error(check_icon_aes(icons::icon_find("rocket")))
})

test_that("check_icon_aes() errors with a hint for non-icon values", {
  expect_error(check_icon_aes(c("a", "b")), "scale_icon_manual")
  expect_error(check_icon_aes(1:2), "scale_icon_manual")
})

test_that("draw_key_icon() returns a grob for a legend key row", {
  data <- data.frame(colour = "black", fill = NA, size = 6, alpha = NA, angle = 0)
  data$icon <- c(icons::fontawesome$solid$rocket)
  expect_no_error(g <- draw_key_icon(data, list(size.unit = "mm"), 1))
  expect_true(grid::is.grob(g))
})

test_that("draw_key_icon() copes with a borrowed key glyph with no icon column", {
  data <- data.frame(colour = "black", fill = NA, size = 6, alpha = NA, angle = 0)
  expect_no_error(g <- draw_key_icon(data, list(size.unit = "mm"), 1))
  expect_true(grid::is.grob(g))
})

test_that("icons keep equal x/y physical extents in a non-square viewport", {
  # size_npc must be computed per-axis (convertWidth for x, convertHeight
  # for y): a single npc factor shared between axes only matches physical
  # length on both when the viewport happens to be square, and stretches
  # icons to match the panel's aspect ratio otherwise (the reported bug).
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
