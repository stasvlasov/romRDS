# `romRDS` an Read or Make RDS

[![R-CMD-check](https://github.com/stasvlasov/romRDS/workflows/R-CMD-check/badge.svg)](https://github.com/stasvlasov/romRDS/actions)
[![codecov](https://codecov.io/gh/stasvlasov/romRDS/branch/master/graph/badge.svg?token=DIUS28A7US)](https://codecov.io/gh/stasvlasov/romRDS)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/stasvlasov/romRDS)

The `romRDS` package provides a wrapper that handles assignment of the
code's resulting value to an object. The wrapper automatically saves the
value in .rds and for later invocations can use this file to skip
evaluation. Basically the wrapper either Reads from the disk Or Makes
RDS files for later reuse (hence `romRDS` name). The main motivation is
to avoid unnecessary reevaluation of some computationally expensive code
chunks (e.g., when your R session crashed and you lost all the objects)
and free up from frequent snapshots of the entire environment to the
.Rdata.

## Usage

``` r
## consider some evaluation with subsequent assignment to object
my_object_name <- Sys.sleep(5)

## the above will take 5 sec every time

## the romRDS package provides the romRDS function (its infix equivalent is %<--%)
romRDS("my_object_name", Sys.sleep(5))

## the equivalent of the above in infix form
my_object_name %<--% Sys.sleep(5)

## multiple commands can be wrapped in {} as usual
my_object_name %<--% {
    Sys.sleep(5)
    data.frame(1:10, runif(10))
}

## or you can use R pipes introduced since R v4.0
## note that maggritr pipes probably won't work
my_object_name %<--%
    Sys.sleep(5) |>
    paste0("Sys.sleep returns NULL so prepending it to this string does not change it.")
```

## Installation

``` r
devtools::install_github("nil")
```

By default the package installation does not rely on any dependencies.
However, if you need to some additional features (e.g., robust
parameters checking and working with STATA's dta files) you need to
install it with extra suggested dependencies.

``` r
devtools::install_github("nil", dependencies = TRUE)
```

## Dependencies

| name                            | version | comment                                   |
|---------------------------------|---------|-------------------------------------------|
| [R](https://www.r-project.org/) | 4.2.0   | minimum R version to enable native piping |

Hard dependencies (`Depends` field in `DESCRIPTION` file)

### Suggested packages

| name                                                                            | version | comment                                       |
|---------------------------------------------------------------------------------|---------|-----------------------------------------------|
| [tinytest](https://github.com/markvanderloo/tinytest/blob/master/pkg/README.md) |         | for testing                                   |
| humanFormat                                                                     |         | for formatting messages                       |
| [checkmate](https://mllg.github.io/checkmate/)                                  |         | function arguments checker, ensures stability |
| haven                                                                           |         | reads STATA .dta files                        |

Suggested packages (`Suggests` field in the `DESCRIPTION` file)

| name                             | version | comment              |
|----------------------------------|---------|----------------------|
| [unrar](https://www.rarlab.com/) | 6.12    | RAR archives utility |

Suggested system packages

### Development dependencies and tools

These packages are used for developing and building `romRDS`

| name                                                               | version | comment                       |
|--------------------------------------------------------------------|---------|-------------------------------|
| [devtools](https://devtools.r-lib.org/)                            |         | builds the package            |
| [roxygen2](https://roxygen2.r-lib.org/)                            |         | makes docs                    |
| [languageserver](https://github.com/REditorSupport/languageserver) |         | provides some IDE consistency |
| [usethis](https://usethis.r-lib.org/)                              |         | repo utils                    |

Useful packages for development
