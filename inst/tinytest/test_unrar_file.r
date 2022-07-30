expect_true({
    rar_url <- "https://getsamplefiles.com/download/rar/sample.rar"
    ## download to tmp dir for testing
    dir_map <- list(list("rar", "doc" = "docx"))
    names(dir_map) <- tempdir()
    ## download and extract
    download_file(rar_url, dir_map) |>
        unrar_file("word/sample.docx", dir_map)
    names(dir_map) |>
        file.path("doc", "sample.docx") |>
        file.exists()
})
