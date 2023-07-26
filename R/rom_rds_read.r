##' Reads file file_name available from file_url and makes .rds for it for futher reuse
##' 
##' @param file_url Files location. Can be a url link (should start with http[s]) or path to archive file (zip or rar)
##' @param file_name Name of the file. If omited the base name of `file_url` is used
##' @param dir_map Where to put the file. Mapping between destination directories and file's extention.
##' @param read_as_ext Named character vertor that specifies how to read different file extentions. Names are supported methods ('csv', 'tsv', 'dta'), values are file expentions that should be processed with these methods.
##' @param file_url_globs_expantion Whether to expand (expect) globs in file_url. If so (default) then try expand url with 'Sys.glob'
##' @param copy_local_files Whether to copy locally available `file_url` to dir specified by dir_map
##' @return path to rds file
##' 
##' @export 
rom_rds_read <- function(file_url
                       , file_name = NULL
                       , dir_map = get_dir_map()
                       , read_as_ext = c("csv" = "txt")
                       , file_url_globs_expantion = TRUE
                       , copy_local_files = FALSE
                         ) {
    ## check if url is archive and has description of files to extract
    file_zip <- NULL
    if(grepl(".+\\.(zip|rar)//.+", file_url)) {
        file_url_in_zip <- sub("^.+\\.(zip|rar)//", "", file_url)
        file_zip <- sub(paste0("//", file_url_in_zip, "$"), "", file_url)
        file_url <- file_url_in_zip
    }
    ## expand globs in url
    if(file_url_globs_expantion &&
       length(file_url_try_glob <- Sys.glob(file_url)) != 0) {
        file_url <- file_url_try_glob
    }
    ## if rds does not yet exist
    if(is.null(file_name)) {
        ## ensure that if we have globs then file name is not null
        if(length(file_url) > 1) {
            stop("rom_rds_read -- 'file_name' should be provided if file_url expands globs (see 'file_url_globs_expantion' option)")
        }
        ## assume file_url's basename without archive ext as file_name
        file_name <- basename(file_url)
        file_name <- sub("\\.zip$|\\.rar$", "", file_name, ignore.case = TRUE)
    }
    rom_rds(file_name, {
        file_path <- get_path(file_name, dir_map)
        if(!file.exists(file_path)) {
            ## try to download
            if(!is.null(file_zip) && is_url(file_zip)) {
                file_zip <- download_file(file_zip, dir_map)
                copy_local_files <- FALSE
            } else if(length(file_url) == 1 &&
                      is_url(file_url)) {
                file_url <- download_file(file_url, dir_map)
            }
            ## try to unarchive...
            if(!is.null(file_zip)) {
                switch(tools::file_ext(file_zip)
                     , zip = unzip_file(file_zip, file_url, dir_map)
                     , rar = unrar_file(file_zip, file_url, dir_map))
                file_path <- get_path(file_url, dir_map)
            }
            if(length(file_url) == 1) {
                switch(tools::file_ext(file_url) 
                     , zip = unzip_file(file_url, file_name, dir_map)
                     , rar = unrar_file(file_url, file_name, dir_map))
            }
            ## set file_url as path
            if(copy_local_files) {
                file_path <- get_path(file_name, dir_map
                                    , dir_only = TRUE
                                    , dir_terminate_with_sep = FALSE)
                file.copy(file_url, file_path)
                file_path <- file.path(file_path, basename(file_url))
            } else{
                file_path <- file_url
            }
        }
        ## by now we should have the file(s) downloaded and extracted
        if(all(file.exists(file_path))) {
            file_ext <- tools::file_ext(file_name)
            if(file_ext %in% read_as_ext) {
                ## read_as_ext should have names
                file_ext <- names(read_as_ext[read_as_ext == file_ext])[1]
            }
            if(length(file_path) > 1) {
                switch(file_ext
                     , csv = if(requireNamespace("data.table", quietly = TRUE)) {
                                 file_path |>
                                     lapply(data.table::fread) |>
                                     data.table::rbindlist()
                             } else {
                                 do.call(rbind, 
                                         file_path |>
                                         lapply(utils::read.csv
                                              , as.is = TRUE
                                              , row.names = NULL))
                             }
                     , tsv = if(requireNamespace("data.table", quietly = TRUE)) {
                                 file_path |>
                                     lapply(data.table::fread) |>
                                     data.table::rbindlist()
                             } else {
                                 do.call(rbind, 
                                         file_path |>
                                         lapply(utils::read.table
                                              , as.is = TRUE
                                              , sep = "\t"
                                              , header = TRUE
                                              , row.names = NULL))
                             })
            } else {
                switch(file_ext
                     , csv = if(requireNamespace("data.table", quietly = TRUE)) {
                                 data.table::fread(file_path)
                             } else {
                                 utils::read.csv(file_path, as.is = TRUE, row.names = NULL)

                             }
                     , tsv = if(requireNamespace("data.table", quietly = TRUE)) {
                                 data.table::fread(file_path)
                             } else {
                                 utils::read.table(file_path, as.is = TRUE, sep = "\t", header = TRUE, row.names = NULL)
                             }
                     , dta = if(requireNamespace("haven", quietly = TRUE)) {
                                 if(requireNamespace("data.table", quietly = TRUE)) {
                                     haven::read_dta(file_path) |> data.table::as.data.table()
                                 } else {
                                     haven::read_dta(file_path)
                                 }
                             } else {
                                 message("rom_rds_read -- Can not read dta file - '", file_path, "' "
                                       , "because package 'haven' is not available.", " "
                                       , "Consider installing it with `install.packages('haven')`")
                             }
                     , rds = readRDS(file_path))
            } 
        } else {
            stop("rom_rds_read -- Can not find/download/unzip data file to read")
        }
    }, rds_dir = do.call(file.path, as.list(get_dir_vector("rds", dir_map))))
}

##' Downloads file to a dir according to dir_map (see `` for details)
##'
##' @param file_url url
##' @param dir_map map ext to dir
##' @param timeout set option `timeout` for download timeout. Default is one hour (3600 sec)
##' @return file name
##' 
##' @export 
download_file <- function(file_url
                        , dir_map = get_dir_map()
                        , timeout = 3600) {
    if(is_url(file_url)) {
        file_path <- get_path(file_url, dir_map)
        if(file.exists(file_path)) {
            message("download_file -- File ", file_path, " already exists. Skipping downloading.")
            return(file_path)
        } else {
            message("download_file -- Downloading to ", file_path)
            timeout_original <- getOption("timeout")
            options(timeout = timeout)
            if(utils::download.file(file_url, file_path) == 0) {
                options(timeout = timeout_original)
                message("download_file -- File ", file_path, " is downloaded.")
                return(file_path)
            } else {
                options(timeout = timeout_original)
                stop("download_file -- Failed to download the ", file_url)
            }
        }
    } else {
        stop("download_file -- url is not valid url")
    }
}

unzip_file <- function(file_url
                     , files_name
                     , dir_map = get_dir_map()
                     , junk_paths = TRUE) {
    if(is_ext("zip", file_url)) {
        files_path <- get_path(files_name, dir_map)
        sapply(files_path, \(file_path) {
            if(!file.exists(file_path)) {
                utils::unzip(file_url
                           , files = files_name
                           , exdir = dirname(file_path)
                           , junkpaths = junk_paths
                           , overwrite = FALSE)
                } else {
                    message("unzip_file -- File is already unziped. Skipping unzipping.")
                }
            })
        return(files_path)
    } else {
        stop("unzip_file -- The input file is not zip")
    }
}

unrar_file <- function(file_url
                     , file_name
                     , dir_map = get_dir_map()) {
    if(is_ext("rar", file_url)) {
        if(Sys.which("unrar") == "") {
            stop("unrar_file -- 'unrar' command is not installed.")
        }
        file_path <- get_path(file_name, dir_map)
        if(!file.exists(file_path)) {
            system(paste("unrar e"
                       , file_url
                       , file_name
                       , file.path(dirname(file_path), ""))
                 , intern = TRUE)
        } else {
            message("unrar_file -- File is already unrared. Skipping unraring.")
        }
        return(file_path)
    } else {
        stop("unrar_file -- The input file is not rar")
    }
}
