## TODO: rename 'dits' param
rom_rds_from_file <- function(file_url
                            , file_name = NULL
                            , dir_map = getOption("romRDS_dir_map")
                            , read_txt_as = "csv") {
    ## if rds does not yet exist
    if(is.null(file_name)) {
        ## assume file_url's basename without archive ext as file_name
        file_name <- basename(file_url)
        file_name <- sub("\\.zip$|\\.rar$", "", file_name, ignore.case = TRUE)
    }
    rom_rds(file_name, {
        file_path <- get_path(file_name, dir_map)
        if(!file.exists(file_path)) {
            ## try to download
            if(is_url(file_url)) {
                file_url <- download_file(file_url, dir_map)
            }
            ## try to unarchive 
            switch(tools::file_ext(file_url)
                 , zip = unzip_file(file_url, file_name, dir_map)
                 , rar = unrar_file(file_url, file_name, dir_map))
        }
        ## by now we should have the file
        if(file.exists(file_path)) {
            file_ext <- tools::file_ext(file_name)
            if(file_ext == "txt") {
                file_ext <- read_txt_as
            }
            switch(file_ext
                 , csv = read.csv(file_path, as.is = TRUE)
                 , tsv = read.table(file_path, as.is = TRUE, sep = "\t", header = TRUE)
                 , dta = if(requireNamespace("heaven", quietly = TRUE)) {
                             haven::read_dta(file_path)
                         } else {
                             message("Can not read dta file", file_path
                                   , "because package 'heaven' is not available."
                                   , "Consider installing it with `install.packages('heaven')`")
                         }
                 , rds = readRDS(file_path))
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
                        , dir_map = getOption("romRDS_dir_map")) {
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
                     , dir_map = getOption("romRDS_dir_map")
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
                     , dir_map = getOption("romRDS_dir_map")) {
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
