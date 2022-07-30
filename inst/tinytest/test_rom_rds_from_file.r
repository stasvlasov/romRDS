zip_url <- "https://files-example-com.github.io/uploads/zip_5MB.zip"
doc_url <- "https://file-examples.com/wp-content/uploads/2017/02/file-sample_100kB.docx"
csv_url <- "https://filesamples.com/samples/document/csv/sample4.csv"

dir_map <- list(list("data" = list("zip", "csv", "rds")
                          , "doc" = c("docx", "pdf")))
names(dir_map) <- tempdir()

## example of deployment
mapply(rom_rds_from_file
     , file_url = list(zip_url, doc_url, csv_url)
     , file_name = list("zip_10MB/file-example_PDF_1MB.pdf", NULL, NULL)
     , dir_map = rep(dir_map, 3))
