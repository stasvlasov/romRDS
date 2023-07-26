expect_equal(
      #-------------------------------------------------------------------------
  {
      csv_url <- "https://filesamples.com/samples/document/csv/sample4.csv"
      ## download to tmp dir for testing
      dir_map <- list(list("csv"))
      names(dir_map) <- tempdir()
      ## download
      romRDS:::download_file(csv_url, dir_map)
      ## read it and return check sum
      names(dir_map) |>
          file.path("csv", basename(csv_url)) |>
          utils::read.csv() |>
          lapply(sum)
  }
  #-------------------------------------------------------------------------
  , list(Game.Number = 500500L, Game.Length = 35411L))

  expect_error("file-name.zip" |> romRDS:::download_file())
