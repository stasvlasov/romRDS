dur_from <- function(start_time) {
    (Sys.time() - start_time) |> 
        as.numeric() |>
        humanFormat::formatSeconds()
}

obj_size <-  function(obj_name) {
    obj_name |> 
        get() |> 
        object.size() |> 
        humanFormat::formatBytes()
}

dir_for_ext <- function(ext, dirs, root = NULL) {
    dir_names <- names(dirs)
    ## ensure dir_names are not zero length to use in mapply
    if(is.null(dir_names)) dir_names <- rep("", length(dirs))
    mapply(\(exts, dir_name) {
        ## if list element is unnamed then use ext as dir
        if(dir_name == "") dir_name <- exts[[1]]
        if(is.character(exts)) {
            if(ext %in% exts) c(root, dir_name) else NULL
        } else if(is.list(exts)) {
            dir_for_ext(ext, exts, dir_name)
        } else {
            stop("Wrong specification of 'dirs'. It should be either list of character")
        }
    }
  , exts = dirs
  , dir_name = dir_names
  , SIMPLIFY = FALSE
  , USE.NAMES = FALSE) |>
      unlist()
}

.onAttach <- function(libname, pkgname) {
    options(
        "romRDS_dirs_to_ext_mapping" =
            list("data" = list("csv", "tsv", "txt", "dta", "rds", "zip", "rar")
               , "docs" = c("pdf", "doc", "docx", "md")
               , "scripts" = c("r", "do", "py", "sh", "perl"))
    )
}

## TODO: dirs should be in options

##' Makes path from file_name using directory to extention mappings specified in dirs
##' @param file_name File name. Could also be a path but only file's base name will be used
##' @param dirs A specification of mapping between file extention and directory. Can be a named list where names used as directory names and values if it is character are corresponding extentions that shoudl go to the directory name or if it is list futher mappings of extentions to subdirectories in recursive manner
##' @return 
make_path_from_file_name <-
    function(file_name
           , dirs = getOption("romRDS_dirs_to_ext_mapping")) {
        ## TODO: check for dublicated elements
        if(any(duplicated(unlist(dirs)))) stop("Extentions can be mapped only to one directory. Check for duplicated values in 'dirs'")
        file_name <- basename(file_name)
        tools::file_ext(file_name) |>
            dir_for_ext(dirs) |>
            (\(path) {do.call(file.path, as.list(path))})() |>
                                                        file.path(file_name)
    }

## TODO: tests
make_path_from_file_name("lala.csv")

"data/csv/lala.csv"

make_path_from_file_name("lala.docx")

"docs/lala.docx"

make_path_from_file_name("oh/yes/lala.py")

"scripts/lala.py"



##' @export
is_url <- function(str) {
    if(is.null(str)) return(FALSE)
    grepl(pattern = "^http", str)
}

##' @export
is_ext <- function(ext, file_name) {
    if(is.null(file_name)) return(FALSE)
    grepl(pattern = paste0("\\.", ext, "$"), file_name)
}

##' @export
download_file <- function(url, dir = "data", ext_as_sub_dir = TRUE) {
    if(!is_url(url)) return(url)
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



##' Unzipts if it is zip file and return filenames
##' 
##' @param file_path file to unzip
##' @param dir output dir
##' @param ext_as_sub_dir use extention as subdirectory
##' @param filter_files_regex Filters filenames. Default is "^_|^\."
##' @export
unzip_file <- function(file_path, dir = "data", ext_as_sub_dir = TRUE, filter_files_regex = "^_|^\\.") {
    if(!is_ext("zip", file_path)) return(file_path)
    ziped_files <- unzip(file_path, list = TRUE)$Name
    ziped_files_ext <- sapply(ziped_files, tools::file_ext)
    ziped_files <- ziped_files[ziped_files_ext != ""]
    ziped_files <- sapply(ziped_files, basename)
    ziped_files <- ziped_files[!grepl(filter_files_regex, ziped_files)]
    if(any(duplicated(ziped_files))) stop("unzip_file -- There are files with the same names in the archive. Do not yet support extraction of files with the same name (need to prefix file path)")
    mapply(\(ziped_file, ext) {
        if(ext_as_sub_dir && is.character(ext) && ext != "") {
            unziped_file_path <- file.path(ext, ziped_file)
        } else {
            unziped_file_path <- ziped_file
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


##' Unrars if it is rar file and unrar is present and return filenames
##' @param file_path file to unrar
##' @param dir output dir
##' @param ext_as_sub_dir use extention as subdirectory
##' @param filter_files_regex Filters filenames. Default is "^_|^\."
##' @export
unrar_file <- function(file_path, dir = "data", ext_as_sub_dir = TRUE, filter_files_regex = "^_|^\\.") {
    if(!is_ext("rar", file_path)) return(file_path)
    if(Sys.which("unrar") == "") stop("unrar_file -- 'unrar' command is not installed.")
    ziped_files <- system(paste("unrar lb", file_path), intern = TRUE)
    ziped_files_ext <- sapply(ziped_files, tools::file_ext)
    ziped_files_name <- sapply(ziped_files, basename)
    ziped_files_filter <- 
        ziped_files_ext != "" &
        !grepl(filter_files_regex, ziped_files_name)
    ziped_files <- ziped_files[ziped_files_filter]
    ziped_files_name <- ziped_files_name[ziped_files_filter]
    if(any(duplicated(ziped_files_name))) stop("unrar_file -- There are files with the same names in the archive. Do not yet support extraction of files with the same name (need to prefix file path)")
    ## filter and unpack
    mapply(\(name, ext, ziped_file) {
        if(ext_as_sub_dir && is.character(ext) && ext != "") {
            unziped_file_path <- file.path(ext, name)
        } else {
            unziped_file_path <- name
        }
        if(!is.null(dir)) {
            unziped_file_path <- file.path(dir, unziped_file_path)
        }
        if(file.exists(unziped_file_path)) {
            return(unziped_file_path)
        } else {
            dir <- dirname(unziped_file_path)
            dir.create(dir, showWarnings = FALSE, recursive = TRUE)
            dir <- paste0(dir, "/")
            system(paste("unrar x", file_path, ziped_file, dir), intern = TRUE)
            return(unziped_file_path)
        }
    }
  , ziped_files_name
  , ziped_files_ext
  , ziped_files
  , USE.NAMES = FALSE
  , SIMPLIFY = TRUE)
}


##' @export
save_txt_to_rds <- function(file_path, dir = "data/rds", remove_original_ext = FALSE) {
    if(!is_ext("txt", file_path)) return(file_path)
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
        return(
            tryCatch({
                read.csv(file_path, as.is = TRUE) |>
                    saveRDS(file_path_rds, compress = FALSE)
                file_path_rds
            }, error = \(e) NULL))
    }
}



##' @export
save_tsv_to_rds <- function(file_path, dir = "data/rds", remove_original_ext = FALSE) {
    if(!is_ext("tsv", file_path)) return(file_path)
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
        return(
            tryCatch({
                read.table(file_path, as.is = TRUE, sep = "\t", header = TRUE) |>
                    saveRDS(file_path_rds, compress = FALSE)
                file_path_rds
            }, error = \(e) NULL))
    }
}



## todo
## use standard file location if file_path is not absolute

##' @export
save_dta_to_rds <- function(file_path, dir = "data/rds", remove_original_ext = FALSE) {
    if(!is_ext("dta", file_path)) return(file_path)
    if(!file.exists(file_path)) {
        return(NULL)
    }
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
        tryCatch({
            ## only supports Stata version 5-12
            ## foreign::read.dta(file_path
                          ## , convert.dates = FALSE
            ## , convert.factors = FALSE) |>
            ## TODO add dependency (or suggest)
            haven::read_dta(file_path) |>
                saveRDS(file_path_rds, compress = FALSE)
            return(file_path_rds)
        }, error = \(e) return(NULL))
    }
}

test_func <- function(x, ...) {
     eval(...)
}





##' @export
deploy_file <- function(file_path) {
    file_path |>
        download_file() |>
        unzip_file() |>
        save_dta_to_rds() |>
        save_txt_to_rds() |>
        save_tsv_to_rds()
}


some_deploy_from_url <- function(url) {
    rds_file_name <- handle_name_here(url)
    romRDS(rds_file_name, {
        ## should be evaled in this envir
    }
  , do_not_assing = TRUE
  , return_value = TRUE)
}
