expect_equal(
    #-------------------------------------------------------------------------
    get_path("lala.csv", make_dir = FALSE)
    #-------------------------------------------------------------------------
  , "data/csv/lala.csv")

expect_equal(
    #-------------------------------------------------------------------------
    get_path("lala.docx", make_dir = FALSE)
    #-------------------------------------------------------------------------
  , "docs/lala.docx")

expect_equal(
    #-------------------------------------------------------------------------
    get_path("oh/yes/lala.py", make_dir = FALSE)
    #-------------------------------------------------------------------------
  , "scripts/lala.py")

expect_equal(
    #-------------------------------------------------------------------------
    get_path("oh/yes/lala.py", make_dir = FALSE, dir_only = TRUE)
    #-------------------------------------------------------------------------
  , "scripts/")

expect_equal(
    #-------------------------------------------------------------------------
    get_path("oh/yes/lala.py", make_dir = FALSE, dir_only = TRUE, dir_terminate_with_sep = FALSE)
    #-------------------------------------------------------------------------
  , "scripts")

## return NULL if it does not know where to put things
expect_error(get_path("oh/yes/lala.wierd_extention"))
