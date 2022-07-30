expect_equal(
    ## ------------------------------------------------------------
    romRDS:::get_dir_vector("csv"
              , list("data" = list("csv", "tsv", "txt", "dta", "rds", "zip", "rar")
                   , "docs" = c("pdf", "doc", "docx", "md")
                   , "scripts" = c("r", "do", "py", "sh", "perl")))
    ## ------------------------------------------------------------
  , c("data", "csv")
)


expect_equal(
    ## ------------------------------------------------------------
    romRDS:::get_dir_vector("any_ext", "data")
    ## ------------------------------------------------------------
  , "data")


expect_equal(
    ## ------------------------------------------------------------
    romRDS:::get_dir_vector("ext", list("data" = list("sub_dir" = list("ext"))))
    ## ------------------------------------------------------------
  , c("data", "sub_dir", "ext"))

expect_equal(
    ## ------------------------------------------------------------
    romRDS:::get_dir_vector("docx"
              , list("data" = list("csv", "tsv", "txt", "dta", "rds", "zip", "rar")
                   , "docs" = c("pdf", "doc", "docx", "md")
                   , "scripts" = c("r", "do", "py", "sh", "perl")))
    ## ------------------------------------------------------------
  , "docs")


expect_equal(
    ## ------------------------------------------------------------
    romRDS:::get_dir_vector("csv"
              , list("csv", "tsv", "txt", "dta", "rds", "zip", "rar"))
    ## ------------------------------------------------------------
  , "csv")
