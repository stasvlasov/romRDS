##' Reads file file_name available from file_url and makes .rds for it for futher reuse
##' 
##' @param file_url Files location. Can be a url link (should start with http[s]) or path to archive file (zip or rar)
##' @param file_name Name of the file. If omited the base name of `file_url` is used
##' @param dir_map Where to put the file. Mapping between destination directories and file's extention.
##' @param read_txt_as How to read txt files.
##' @param file_url_globs_expantion Whether to expand (expect) globs in file_url. If so (default) then try expand url with 'Sys.glob'
##' @return path to rds file
##' 
##' @export 
rom_rds_read <- function(file_url
                       , file_name = NULL
                       , dir_map = get_dir_map()
                       , read_txt_as = "csv"
                       , file_url_globs_expantion = TRUE
                       , copy_local_files = FALSE) {
    if(file_url_globs_expantion) {
        ## expand globs in url
        file_url <- Sys.glob(file_url)
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
            if(all(is_url(file_url))) {
                file_url <- download_file(file_url, dir_map)
            }
            ## try to unarchive or just set file_url as path
            switch(tools::file_ext(file_url)[1]
                 , zip = unzip_file(file_url, file_name, dir_map)
                 , rar = unrar_file(file_url, file_name, dir_map)
                 , if(copy_local_files) {
                       file_path <- get_path(file_name, dir_map
                                           , dir_only = TRUE
                                           , dir_terminate_with_sep = FALSE)
                       file.copy(file_url, file_path)
                       file_path <- file.path(file_path, basename(file_url))
                   } else{
                       file_path <- file_url
                   })
        }
        ## by now we should have the file
        if(all(file.exists(file_path))) {
            file_ext <- tools::file_ext(file_name)
            if(file_ext == "txt") {
                file_ext <- read_txt_as
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
                                         lapply(read.csv
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
                                         lapply(read.table
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
                                 read.csv(file_path, as.is = TRUE, row.names = NULL)

                             }
                     , tsv = if(requireNamespace("data.table", quietly = TRUE)) {
                                 data.table::fread(file_path)
                             } else {
                                 read.table(file_path, as.is = TRUE, sep = "\t", header = TRUE, row.names = NULL)
                             }
                     , dta = if(requireNamespace("haven", quietly = TRUE)) {
                                 haven::read_dta(file_path)
                             } else {
                                 message("Can not read dta file", file_path
                                       , "because package 'haven' is not available."
                                       , "Consider installing it with `install.packages('haven')`")
                             }
                     , rds = readRDS(file_path))
            } 
        } else {
            stop("Can not find/download/unzip data file to read")
        }
    }, rds_dir = do.call(file.path, as.list(get_dir_vector("rds", dir_map))))
}

##' Downloads file to a dir according to dir_map (see `` for details)
##'
##' @param file_url url
##' @param dir_map map ext to dir
##' @return file name
##' 
##' @export 
download_file <- function(file_url
                        , dir_map = get_dir_map()) {
    if(is_url(file_url)) {
        file_path <- get_path(file_url, dir_map)
        if(file.exists(file_path)) {
            message("File ", file_path, " already exists. Skipping downloading.")
            return(file_path)
        } else {
            message("Downloading to ", file_path)
            if(download.file(file_url, file_path) == 0) {
                message("File ", file_path, " is downloaded.")
                return(file_path)
            } else {
                stop("Failed to download the ", file_url)
            }
        }
    } else {
        stop("url is not valid url")
    }
}

unzip_file <- function(file_url
                     , file_name
                     , dir_map = get_dir_map()
                     , junk_paths = TRUE) {
    if(is_ext("zip", file_url)) {
        file_path <- get_path(file_name, dir_map)
        if(!file.exists(file_path)) {
            utils::unzip(file_url
                       , files = file_name
                       , exdir = dirname(file_path)
                       , junkpaths = junk_paths)
        } else {
            message("File is already unziped. Skipping unzipping.")
        }
        return(file_path)
    } else {
        stop("The input file is not zip")
    }
}

unrar_file <- function(file_url
                     , file_name
                     , dir_map = get_dir_map()) {
    if(is_ext("rar", file_url)) {
        if(Sys.which("unrar") == "") {
            stop("unrar_file -- 'unrar' command is not installed.")
        }
        file_path <- get_path(file_name
                                       , dir_map)
        if(!file.exists(file_path)) {
            system(paste("unrar e"
                       , file_url
                       , file_name
                       , file.path(dirname(file_path), ""))
                 , intern = TRUE)
        } else {
            message("File is already unrared. Skipping unraring.")
        }
        return(file_path)
    } else {
        stop("The input file is not rar")
    }
}
