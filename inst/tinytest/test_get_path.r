expect_equal(
    #-------------------------------------------------------------------------
    romRDS:::get_path("lala.csv", make_dir = FALSE)
    #-------------------------------------------------------------------------
  , "data/csv/lala.csv")

expect_equal(
    #-------------------------------------------------------------------------
    romRDS:::get_path("lala.docx", make_dir = FALSE)
    #-------------------------------------------------------------------------
  , "docs/lala.docx")

expect_equal(
    #-------------------------------------------------------------------------
    romRDS:::get_path("oh/yes/lala.py", make_dir = FALSE)
    #-------------------------------------------------------------------------
  , "scripts/lala.py")

expect_equal(
    #-------------------------------------------------------------------------
    romRDS:::get_path("oh/yes/lala.py", make_dir = FALSE, dir_only = TRUE)
    #-------------------------------------------------------------------------
  , "scripts/")

expect_equal(
    #-------------------------------------------------------------------------
    romRDS:::get_path("oh/yes/lala.py", make_dir = FALSE, dir_only = TRUE, dir_terminate_with_sep = FALSE)
    #-------------------------------------------------------------------------
  , "scripts")

## return NULL if it does not know where to put things
expect_error(romRDS:::get_path("oh/yes/lala.wierdextention"))


## check vectorization
expect_equal(
    #-------------------------------------------------------------------------
    c("lala.csv"
    , "lala.txt"
    , "lala.pdf"
    , "lala.dta") |>
    romRDS:::get_path(
                 dir_map = list("csv", "dta", docs = c("pdf", "txt"))
               , make_dir = FALSE)
    #-------------------------------------------------------------------------
  , c("csv/lala.csv", "docs/lala.txt", "docs/lala.pdf", "dta/lala.dta"))
