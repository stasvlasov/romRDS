expect_true({
    zip_url <- "https://files-example-com.github.io/uploads/zip_5MB.zip"
    ## download to tmp dir for testing
    dir_map <- list(list("zip", "pdf"))
    names(dir_map) <- tempdir()
    ## download
    download_file(zip_url, dir_map)
    ## read it and return check sum
    names(dir_map) |>
        file.path("zip", basename(zip_url)) |>
        unzip_file("zip_10MB/file-example_PDF_1MB.pdf", dir_map)
    names(dir_map) |>
        file.path("pdf", "file-example_PDF_1MB.pdf") |>
        file.exists()
})
