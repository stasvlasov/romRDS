##' @export
is.url <- function(str) {
    grepl(pattern = "^http", str)
}

##' @export
is.ext <- function(str, ext) {
    grepl(pattern = paste0("\\.", ext, "$"), str)
}

##' @export
download_file <- function(url, dir = "data", ext_as_sub_dir = TRUE) {
    if(!is.url(url)) return(url)
    file_name <- basename(url)
    ext <- tools::file_ext(file_name)
    if(ext_as_sub_dir && is.character(ext) && ext != "") {
        file_path <- file.path(ext, file_name)
    } else {
        file_path <- file_name
    }
    if(is.null(dir)) {
        file_path <- file_path
    } else {
        file_path <- file.path(dir, file_path)
    }
    if(file.exists(file_path)) {
        return(file_path)
    }
    dir.create(dirname(file_path), showWarnings = FALSE, recursive = TRUE)
    if(download.file(url, file_path) == 0) {
        return(file_path)
    }
    return(NA)
}

##' @export
unzip_file <- function(file_path, dir = "data", ext_as_sub_dir = TRUE) {
    if(!is.ext(file_path, "zip")) return(file_path)
    ziped_files <-  unzip(file_path, list = TRUE)$Name
    ziped_files_ext <- sapply(ziped_files, tools::file_ext)
    mapply(\(ziped_file, ext) {
        if(ext_as_sub_dir && is.character(ext) && ext != "") {
            unziped_file_path <- file.path(ext, basename(ziped_file))
        } else {
            unziped_file_path <- basename(ziped_file)
        }
        if(!is.null(dir)) {
            unziped_file_path <- file.path(dir, unziped_file_path)
        }
        if(file.exists(unziped_file_path)) {
            return(unziped_file_path)
        } else {
            unziped_file_path <- dirname(unziped_file_path)
            dir.create(unziped_file_path, showWarnings = FALSE, recursive = TRUE)
            unzip(file_path, files = ziped_file, exdir = unziped_file_path)
        }
    }
  , ziped_files
  , ziped_files_ext
  , USE.NAMES = FALSE
  , SIMPLIFY = TRUE)
}

##' @export
save_dta_to_rds <- function(file_path, dir = "data/rds", remove_original_ext = FALSE) {
    if(!is.ext(file_path, "dta")) return(file_path)
    file_path_rds <- basename(file_path)
    if(remove_original_ext) {
        file_path_rds <- tools::file_path_sans_ext(file_path_rds)
    }
    file_path_rds <- paste0(file_path_rds, ".rds")
    if(!is.null(dir)) {
        dir.create(dir, showWarnings = FALSE, recursive = TRUE)
        file_path_rds <- file.path(dir, file_path_rds)
    }
    if(file.exists(file_path_rds)) {
        return(file_path_rds)
    } else {
        foreign::read.dta(file_path
                        , convert.dates = FALSE
                        , convert.factors = FALSE) |>
            saveRDS(file_path_rds, compress = FALSE)
        return(file_path_rds)
    }
}

##' @export
deploy_file <- function(file_path) {
    file_path |>
        download_file() |>
        unzip_file() |>
        save_dta_to_rds()
}
