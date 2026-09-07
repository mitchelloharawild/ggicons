test_that("nice_ceiling rounds up to 1/2/5 x a power of ten", {
  expect_identical(nice_ceiling(0.37), 0.5)
  expect_identical(nice_ceiling(1), 1)
  expect_identical(nice_ceiling(1.15), 2)
  expect_identical(nice_ceiling(5), 5)
  expect_identical(nice_ceiling(6.15), 10)
  expect_identical(nice_ceiling(61.5), 100)
  expect_identical(nice_ceiling(235), 500)
  expect_identical(nice_ceiling(999), 1000)

  # non-positive/non-finite input has no sensible "nicer" answer - fall back to 1 rather than error
  expect_identical(nice_ceiling(0), 1)
  expect_identical(nice_ceiling(-5), 1)
  expect_identical(nice_ceiling(NA_real_), 1)
})

test_that("format_symbol_value shows decimals for a fraction instead of truncating to 0", {
  expect_identical(format_symbol_value(0.5), "0.5")
  expect_identical(format_symbol_value(0.05), "0.05")
  expect_identical(format_symbol_value(0.005), "0.005")

  # whole numbers are untouched (no spurious ".0")
  expect_identical(format_symbol_value(1), "1")
  expect_identical(format_symbol_value(100), "100")
})

test_that("automatic symbol_value never goes below 1, even for a small largest value", {
  expect_identical(pictogram_auto_symbol_value(0.9, target = 20), 1)
  expect_identical(pictogram_auto_symbol_value(c(23, 15), target = 100), 1)
})

test_that("symbol_value defaults to 1 in fixed-grid mode, even for large values", {
  df <- data.frame(x = "a", value = 8700)

  by_n <- ggplot2::ggplot_build(
    ggplot2::ggplot(df, ggplot2::aes(x, value = value)) +
      geom_pictogram(icon = icons::fontawesome$solid$square, n = 100)
  )
  expect_identical(by_n$plot$layers[[1]]$computed_stat_params$symbol_value, 1)

  by_nrow_ncol <- ggplot2::ggplot_build(
    ggplot2::ggplot(df, ggplot2::aes(x, value = value)) +
      geom_pictogram(icon = icons::fontawesome$solid$square, nrow = 10, ncol = 10)
  )
  expect_identical(by_nrow_ncol$plot$layers[[1]]$computed_stat_params$symbol_value, 1)
})

test_that("symbol_value is auto-picked as a nice number in growing-grid mode", {
  df <- data.frame(animal = c("Cat", "Dog"), count = c(1230, 890))
  p <- ggplot2::ggplot(df, ggplot2::aes(animal, value = count)) +
    geom_pictogram(icon = icons::fontawesome$solid$paw)

  b <- ggplot2::ggplot_build(p)
  # target 20 icons for the largest value (1230): nice_ceiling(1230 / 20) == 100
  expect_identical(b$plot$layers[[1]]$computed_stat_params$symbol_value, 100)
  expect_true(all(table(b$data[[1]]$group) <= ceiling(1230 / 100)))
})

test_that("n_target tunes how many icons the auto-picked symbol_value aims for", {
  df <- data.frame(x = "a", value = 1230)

  denser <- ggplot2::ggplot_build(
    ggplot2::ggplot(df, ggplot2::aes(x, value = value)) +
      geom_pictogram(icon = icons::fontawesome$solid$square, n_target = 50)
  )
  expect_identical(denser$plot$layers[[1]]$computed_stat_params$symbol_value, 50)

  coarser <- ggplot2::ggplot_build(
    ggplot2::ggplot(df, ggplot2::aes(x, value = value)) +
      geom_pictogram(icon = icons::fontawesome$solid$square, n_target = 5)
  )
  expect_identical(coarser$plot$layers[[1]]$computed_stat_params$symbol_value, 500)
})

test_that("an explicitly fixed nrow/ncol scales the auto-picked target, not the total", {
  df <- data.frame(x = "a", value = 1230)

  # ncol fixed: the target is icons *deep* (rows), i.e. ncol * n_target = 5 * 20 = 100 -
  # nice_ceiling(1230 / 100) == 20, finer than the flat (target = 20) value of 100 above.
  by_ncol <- ggplot2::ggplot_build(
    ggplot2::ggplot(df, ggplot2::aes(x, value = value)) +
      geom_pictogram(icon = icons::fontawesome$solid$square, ncol = 5)
  )
  expect_identical(by_ncol$plot$layers[[1]]$computed_stat_params$symbol_value, 20)

  # nrow fixed instead: same reasoning, this time bounding the resulting ncol.
  by_nrow <- ggplot2::ggplot_build(
    ggplot2::ggplot(df, ggplot2::aes(x, value = value)) +
      geom_pictogram(icon = icons::fontawesome$solid$square, nrow = 5)
  )
  expect_identical(by_nrow$plot$layers[[1]]$computed_stat_params$symbol_value, 20)
})

test_that("an explicit symbol_value always overrides auto-picking", {
  df <- data.frame(x = "a", value = 1230)
  p <- ggplot2::ggplot(df, ggplot2::aes(x, value = value)) +
    geom_pictogram(icon = icons::fontawesome$solid$square, symbol_value = 7)

  b <- ggplot2::ggplot_build(p)
  expect_identical(b$plot$layers[[1]]$computed_stat_params$symbol_value, 7)
})
