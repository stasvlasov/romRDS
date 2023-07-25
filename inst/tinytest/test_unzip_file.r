expect_true({
    zip_url <- "https://files-example-com.github.io/uploads/zip_5MB.zip"
    ## download to tmp dir for testing
    dir_map <- list(list("zip", "pdf", "jpg"))
    names(dir_map) <- tempdir()
    ## download
    romRDS:::download_file(zip_url, dir_map)
    ## read it and return check sum
    names(dir_map) |>
        file.path("zip", basename(zip_url)) |>
        romRDS:::unzip_file(
                     c("zip_10MB/file-example_PDF_1MB.pdf"
                     , "zip_10MB/file_example_PNG_2500kB.jpg"), dir_map)
    names(dir_map) |>
        file.path("pdf", "file-example_PDF_1MB.pdf") |>
        file.exists()
})
