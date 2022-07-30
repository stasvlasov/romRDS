expect_equal({
    #-------------------------------------------------------------------------
    rds_dir <-
        tempdir(check = TRUE) |>
        file.path("data/rds")
    rom_rds("lala", 1 + 2/3
          , rds_dir = rds_dir)
    ## should read from existing rds
    rom_rds("lala", 100 - 1
          , rds_dir = rds_dir)
    #-------------------------------------------------------------------------
}, 1.66666666666667)


expect_equal({
    #-------------------------------------------------------------------------
    rds_dir <-
        tempdir(check = TRUE) |>
        file.path("data/rds")
    rom_rds("lala", 1 + 2/3
          , rds_dir = rds_dir)
    ## should read from existing rds
    rom_rds("lala", 100 - 1
          , rds_dir = rds_dir
          , assign_to_name = TRUE)
    lala
    #-------------------------------------------------------------------------
}, 1.66666666666667)


expect_equal(
    #-------------------------------------------------------------------------
    rom_rds("lala", 1 + 2/3
          , do_not_make = TRUE
          , return_name = TRUE)
    #-------------------------------------------------------------------------
  , "lala")


expect_message(
    rom_rds("lala", 1 + 2/3
          , do_not_make = TRUE)
)
