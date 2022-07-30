expect_equal(
    ## call to test
    ## ------------------------------------------------------------
    get_dir_vector("csv"
              , list("data" = list("csv", "tsv", "txt", "dta", "rds", "zip", "rar")
                   , "docs" = c("pdf", "doc", "docx", "md")
                   , "scripts" = c("r", "do", "py", "sh", "perl")))
    ## expected value
    ## ------------------------------------------------------------
  , c("data", "csv")
)


expect_equal(
    ## call to test
    ## ------------------------------------------------------------
    get_dir_vector("any_ext", "data")
    ## expected value
    ## ------------------------------------------------------------
  , "data")

expect_equal(
    ## call to test
    ## ------------------------------------------------------------
    get_dir_vector("docx"
              , list("data" = list("csv", "tsv", "txt", "dta", "rds", "zip", "rar")
                   , "docs" = c("pdf", "doc", "docx", "md")
                   , "scripts" = c("r", "do", "py", "sh", "perl")))
    ## expected value
    ## ------------------------------------------------------------
  , "docs")


expect_equal(
    ## call to test
    ## ------------------------------------------------------------
    get_dir_vector("csv"
              , list("csv", "tsv", "txt", "dta", "rds", "zip", "rar"))
    ## expected value
    ## ------------------------------------------------------------
  , "csv")
