expect_equal(
    ## call to test
    ## ------------------------------------------------------------
    dir_for_ext("csv"
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
    dir_for_ext("docx"
              , list("data" = list("csv", "tsv", "txt", "dta", "rds", "zip", "rar")
                   , "docs" = c("pdf", "doc", "docx", "md")
                   , "scripts" = c("r", "do", "py", "sh", "perl")))
    ## expected value
    ## ------------------------------------------------------------
  , "docs")


expect_equal(
    ## call to test
    ## ------------------------------------------------------------
    dir_for_ext("csv"
              , list("csv", "tsv", "txt", "dta", "rds", "zip", "rar"))
    ## expected value
    ## ------------------------------------------------------------
  , "csv")
