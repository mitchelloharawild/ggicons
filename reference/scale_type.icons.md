# Discrete scale for the icon aesthetic

Tells ggplot2's scale machinery that an icon vector from the
[icons](https://github.com/mitchelloharawild/icons) package is discrete,
the same way a bare `factor`/`character` column already is. Without
this, `scale_type.default()` warns and defaults to continuous, which is
wrong for icons.

## Usage

``` r
# S3 method for class 'icons'
scale_type(x)
```

## Arguments

- x:

  A vector mapped to an aesthetic.

## Value

`"discrete"`.

## Details

This purely silences that warning: `icon` has no automatic discrete
palette (see
[`scale_icon_manual()`](https://pkg.mitchelloharawild.com/ggicons/reference/scale_icon_manual.md)).
