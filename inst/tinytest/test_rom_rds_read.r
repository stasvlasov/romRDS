expect_true({
    ## example links
    zip_url <- "https://files-example-com.github.io/uploads/zip_5MB.zip"
    doc_url <- "https://file-examples.com/wp-content/uploads/2017/02/file-sample_100kB.docx"
    csv_url <- "https://filesamples.com/samples/document/csv/sample4.csv"
    ## make temp dir mappings
    dir_map <- list(list("data" = list("zip", "csv", "rds")
                       , "doc" = c("docx", "pdf")))
    tmp_dir <- tempdir()
    names(dir_map) <- tmp_dir
    ## example of deployment
    mapply(romRDS::rom_rds_read
         , file_url = list(zip_url, doc_url, csv_url)
         , file_name = list("zip_10MB/file-example_PDF_1MB.pdf", NULL, NULL)
         , dir_map = list(dir_map, dir_map, dir_map))
    ## check that all files are there
    file.path(tmp_dir, c("data/csv/sample4.csv"
                       , "data/rds/sample4.csv.rds"
                       , "data/zip/zip_5MB.zip"
                       , "doc/file-example_PDF_1MB.pdf"
                       , "doc/file-sample_100kB.docx")) |>
        file.exists() |>
        all()
})


## test globbing
expect_true({
    csv_url <-
        find.package(package = "romRDS") |>
        file.path("testdata/csv*/test*.csv")
    ## make temp dir mappings
    dir_map <- list(list("data" = list("zip", "csv", "rds")
                       , "doc" = c("docx", "pdf")))
    tmp_dir <- tempdir()
    names(dir_map) <- tmp_dir
    ## example of deployment
    dt <- romRDS:::rom_rds_read(
                     , file_url = csv_url
                     , file_name = "test.csv"
                     , dir_map = dir_map
                     , copy_local_files = TRUE)
    nrow(dt) == 6 &&
        file.path(tmp_dir, "data/csv/test1.csv") |>
        file.exists()
})
