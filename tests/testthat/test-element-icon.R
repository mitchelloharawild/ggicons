cyl_icons <- list(
  `4` = shapes$circle,
  `6` = shapes$square,
  `8` = shapes$triangle
)

test_that("element_icon() constructs an element_text-derived object", {
  el <- element_icon(icons = cyl_icons, size = 12)

  # Elements are S7 objects with extra class entries, so check with inherits() and
  # confirm element_icon is the most derived class for S3 dispatch.
  expect_s3_class(el, "element_icon")
  expect_s3_class(el, "element_text")
  expect_s3_class(el, "element")
  expect_identical(class(el)[[1]], "element_icon")
})

test_that("element_icon(icons = NULL) is a legal degenerate case", {
  expect_no_error(el <- element_icon())
  expect_null(attr(el, "icons"))
  expect_s3_class(el, "element_icon")
})

test_that("element_icon() validates the icons lookup", {
  expect_error(element_icon(icons = unname(cyl_icons)), "named")
  expect_error(element_icon(icons = c(a = 1, b = 2)), "named")
  expect_error(element_icon(icons = list(a = "not-an-icon")), "icon")
})

test_that("theme(axis.text.x = element_icon()) builds and draws when labels match", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(factor(cyl), mpg)) +
    ggplot2::geom_boxplot() +
    ggplot2::theme(axis.text.x = element_icon(icons = cyl_icons, size = 12))

  expect_no_error(ggplot2::ggplot_build(p))
  expect_no_error(grid::grid.draw(ggplot2::ggplotGrob(p)))
})

test_that("theme(axis.text.x = element_icon()) falls back to text for unmatched labels", {
  # Only two of the three cyl levels are in the lookup; the unmatched one falls back to text.
  partial <- cyl_icons[c("4", "6")]
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(factor(cyl), mpg)) +
    ggplot2::geom_boxplot() +
    ggplot2::theme(axis.text.x = element_icon(icons = partial, size = 12))

  expect_no_error(ggplot2::ggplot_build(p))
  expect_no_error(grid::grid.draw(ggplot2::ggplotGrob(p)))
})

test_that("theme(axis.text.x = element_icon()) falls back to text entirely when no labels match", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(factor(am), mpg)) +
    ggplot2::geom_boxplot() +
    ggplot2::theme(axis.text.x = element_icon(icons = cyl_icons, size = 12))

  expect_no_error(ggplot2::ggplot_build(p))
  expect_no_error(grid::grid.draw(ggplot2::ggplotGrob(p)))
})

test_that("theme(axis.text.x = element_icon(icons = NULL)) behaves like element_text()", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(factor(cyl), mpg)) +
    ggplot2::geom_boxplot() +
    ggplot2::theme(axis.text.x = element_icon())

  expect_no_error(ggplot2::ggplot_build(p))
  expect_no_error(grid::grid.draw(ggplot2::ggplotGrob(p)))
})

test_that("theme(strip.text = element_icon()) builds and draws", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
    ggplot2::geom_point() +
    ggplot2::facet_wrap(~cyl) +
    ggplot2::theme(strip.text = element_icon(icons = cyl_icons, size = 12))

  expect_no_error(ggplot2::ggplot_build(p))
  expect_no_error(grid::grid.draw(ggplot2::ggplotGrob(p)))
})

test_that("theme(legend.text = element_icon()) builds and draws", {
  df <- mtcars
  df$cyl <- factor(df$cyl)
  p <- ggplot2::ggplot(df, ggplot2::aes(wt, mpg, colour = cyl)) +
    ggplot2::geom_point() +
    ggplot2::theme(legend.text = element_icon(icons = cyl_icons, size = 12))

  expect_no_error(ggplot2::ggplot_build(p))
  expect_no_error(grid::grid.draw(ggplot2::ggplotGrob(p)))
})

test_that("coord_flip() with element_icon() on axis.text.y builds and draws", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(factor(cyl), mpg)) +
    ggplot2::geom_boxplot() +
    ggplot2::coord_flip() +
    ggplot2::theme(axis.text.y = element_icon(icons = cyl_icons, size = 12))

  expect_no_error(ggplot2::ggplot_build(p))
  expect_no_error(grid::grid.draw(ggplot2::ggplotGrob(p)))
})

test_that("element_grob.element_icon() returns a grob for icon and text labels alike", {
  # calc_element() resolves hjust/vjust/margin defaults from the theme hierarchy before element_grob() runs.
  th <- ggplot2::theme_grey() +
    ggplot2::theme(axis.text.x = element_icon(icons = cyl_icons, size = 12))
  el <- ggplot2::calc_element("axis.text.x", th)

  g <- ggplot2::element_grob(el, label = c("4", "8", "not-in-lookup"), x = c(0.2, 0.5, 0.8))
  expect_true(grid::is.grob(g))
})

test_that("element_grob.element_icon() returns a nullGrob for an empty label vector", {
  th <- ggplot2::theme_grey() +
    ggplot2::theme(axis.text.x = element_icon(icons = cyl_icons, size = 12))
  el <- ggplot2::calc_element("axis.text.x", th)

  g <- ggplot2::element_grob(el, label = character(0))
  expect_true(grid::is.grob(g))
})

test_that("icon_rotate_just() swaps hjust/vjust by 90-degree quadrant", {
  expect_equal(icon_rotate_just(0, 0.2, 0.8), list(hjust = 0.2, vjust = 0.8))
  expect_equal(icon_rotate_just(90, 0.2, 0.8), list(hjust = 1 - 0.8, vjust = 0.2))
  expect_equal(icon_rotate_just(180, 0.2, 0.8), list(hjust = 1 - 0.2, vjust = 1 - 0.8))
  expect_equal(icon_rotate_just(270, 0.2, 0.8), list(hjust = 0.8, vjust = 1 - 0.2))
  # A full turn (450 == 90) round-trips through `%% 360`.
  expect_equal(icon_rotate_just(450, 0.2, 0.8), icon_rotate_just(90, 0.2, 0.8))
})

test_that("element_icon()'s hjust/vjust/margin/angle position the icon like element_text() would", {
  # Renders through the same makeContent() path a real draw uses, then checks where the icon landed.
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  grid::grid.newpage()
  grid::pushViewport(grid::viewport(width = grid::unit(4, "in"), height = grid::unit(4, "in")))

  path <- icons::icon_path(shapes$triangle)[[1]]

  mean_xy <- function(hjust = 0.5, vjust = 0.5, angle = 0, margin = NULL,
                       margin_x = FALSE, margin_y = FALSE) {
    g <- element_icon_grob(
      path = path, x = 0.5, y = 0.5, size = 20, colour = "black",
      angle = angle, size.unit = "pt", hjust = hjust, vjust = vjust,
      margin = margin, margin_x = margin_x, margin_y = margin_y
    )
    # Two levels of deferred content: the outer gTree, then the per-fill-rule iconpath child.
    resolved <- grid::makeContent(grid::makeContent(g)$children[[1]]$children[[1]])
    p <- resolved$children[[1]]
    c(x = mean(as.numeric(p$x)), y = mean(as.numeric(p$y)))
  }

  # vjust 1 (top-justified) < 0.5 (centred) < 0 (bottom-justified) on the y axis.
  y1 <- mean_xy(vjust = 1)["y"]
  y_mid <- mean_xy(vjust = 0.5)["y"]
  y0 <- mean_xy(vjust = 0)["y"]
  expect_lt(y1, y_mid)
  expect_lt(y_mid, y0)

  # hjust 0 (left-justified) > 0.5 > 1 (right-justified) on the x axis.
  x0 <- mean_xy(hjust = 0)["x"]
  x_mid <- mean_xy(hjust = 0.5)["x"]
  x1 <- mean_xy(hjust = 1)["x"]
  expect_gt(x0, x_mid)
  expect_gt(x_mid, x1)

  # A top margin pushes a top-justified icon further from the anchor.
  y1_margin <- mean_xy(vjust = 1, margin = ggplot2::margin(t = 40, unit = "pt"), margin_y = TRUE)["y"]
  expect_lt(y1_margin, y1)

  # At angle = 90, the hjust offset lands on the y axis instead of x, like rotated text's justification.
  y_hjust1_rot90 <- mean_xy(hjust = 1, vjust = 0.5, angle = 90)["y"]
  expect_lt(y_hjust1_rot90, mean_xy(hjust = 0.5, vjust = 0.5, angle = 90)["y"])
})
