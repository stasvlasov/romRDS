##' Returns default options for mapping file extentions to directories (used mainly by `rom_rds_read`)
##' 
##' @return list with mappings
get_dir_map_defaults <- function() {
    list("data" = list("csv", "tsv", "txt", "dta", "rds", "zip", "rar")
       , "docs" = c("pdf", "doc", "docx", "md")
       , "scripts" = c("r", "do", "py", "sh", "perl"))
}


.onAttach <- function(libname, pkgname) {
    options(
        "romRDS_dir_map" = get_dir_map_defaults()
    )
}

##' Returns list of mappings of file extentions to directories (used mainly by `rom_rds_read`). If options 'romRDS_dir_map' is set gets its values otherwise returns defauls from `get_dir_map_defaults()`
##' 
##' @return list with mappings
get_dir_map <- function() {
    romRDS_dir_map <- getOption("romRDS_dir_map")
    if(is.null(romRDS_dir_map)) romRDS_dir_map <- get_dir_map_defaults()
    return(romRDS_dir_map)
}

##' @title  Read or Make RDS
##'
##' @description
##' Reads or makes .rds if file is not available and loads the object into memory.
##' 
##' @param name Name of file or object
##' @param ... How to construct the object if it is not on disk
##' @param rds_dir Directory where to look for or save to .rds. Default is "data/rds"
##' @param rds_dir_ensure Make `rds_dir` direcory if it does not exist
##' @param file_name_sufix e.g., date or version.
##' @param file_name_sufix_var Either "date" or "time" for current date and time or NULL (default)
##' @param file_name_sufix_sep Default is "."
##' @param file_name_extention Default is ".rds"
##' @param name_has_extention Default is FALSE
##' @param rds_compress Default is FALSE. It is faster to read and write if rds is not compressed.
##' @param return_name Default is FALSE
##' @param do_not_make Default is FALSE
##' @param do_not_save Default is FALSE
##' @param quietly Default is FALSE
##' @param assign_to_name Default is FALSE
##' @return Returns the object or name of the obj (if return_name is TRUE).
##' @export
rom_rds <- function(name
                  , ...  # How to construct the object if it is not on disk
                  , rds_dir = "data/rds"
                  , rds_dir_ensure = TRUE
                  , file_name_sufix = character(0)
                  , file_name_sufix_var = NULL
                  , file_name_sufix_sep = "."
                  , file_name_extention = "rds"
                  , name_has_extention = FALSE
                  , rds_compress = FALSE
                  , return_name = FALSE
                  , do_not_make = FALSE
                  , do_not_save = FALSE
                  , quietly = FALSE
                  , assign_to_name = FALSE) {
    ## check arguments with checkmate (optionally)
    if (requireNamespace("checkmate", quietly = TRUE)) {
        checkmate::assert_character(name, null.ok = FALSE)
        checkmate::assert_character(rds_dir, null.ok = FALSE)
        checkmate::assert_character(file_name_sufix, null.ok = FALSE)
        checkmate::assert_choice(file_name_sufix_var
                               , c("date", "time")
                               , null.ok = TRUE)
        checkmate::assert_character(file_name_sufix_sep, null.ok = FALSE)
        checkmate::assert_character(file_name_extention, null.ok = FALSE)
        checkmate::assert_flag(rds_dir_ensure)
        checkmate::assert_flag(name_has_extention)
        checkmate::assert_flag(rds_compress)
        checkmate::assert_flag(return_name)
        checkmate::assert_flag(do_not_make)
        checkmate::assert_flag(do_not_save)
        checkmate::assert_flag(quietly)
        checkmate::assert_flag(assign_to_name)
    }
    ## make file_name and file_name_regex
    ## remove suffix sep if there is no suffix
    if (length(file_name_sufix) == 0 &&
        length(file_name_sufix_var) == 0) {
        file_name_sufix_sep <- NULL
    }
    ## generate suffix variable and its regex
    if(length(file_name_sufix_var) != 0) {
        file_name_sufix_var <-
            switch(file_name_sufix_var
                 , "date" = format(Sys.time(), "%Y-%d-%d")
                 , "time" = format(Sys.time(), "%Y-%d-%dT%H-%M-%S"))
        file_name_sufix_var_regex <-
            switch(file_name_sufix_var
                 , "date" = "\\d\\d\\d\\d-[0-1]\\d-[0-3]\\d"
                 , "time" = "\\d\\d\\d\\d-\\d\\d-\\d\\dT[0-2]\\d-[0-6]\\d-[0-6]\\d"
                 , "counter" = "\\d+")
    } else {
        file_name_sufix_var_regex <- NULL
    }
    ## get name extention if it is already in name
    if(name_has_extention) {
        file_name_extention <- tools::file_ext(name)
        name <- tools::file_path_sans_ext(name)
    }
    ## handle file extention
    if(!is.null(file_name_extention) && !(file_name_extention == "")) {
        file_name_extention <- paste0(".", file_name_extention)
    }
    ## make file name
    file_name <- paste0(name
                      , file_name_sufix_sep
                      , file_name_sufix
                      , file_name_sufix_var
                      , file_name_extention)
    ## make file name regex to match against suffix var
    if(length(file_name_sufix_var_regex) == 0) {
        file_name_regex <- NULL
    } else {
        escape_regex <- \(str) gsub("([.|()\\^{}+$*?]|\\[|\\])", "\\\\\\1", str)
        file_name_regex <- 
            paste0(escape_regex(name)
                 , escape_regex(file_name_sufix_sep)
                 , escape_regex(file_name_sufix)
                 , file_name_sufix_var_regex
                 , escape_regex(file_name_extention))
    }
    ## handle rds_dir
    rds_dir <- path.expand(rds_dir)
    if(!dir.exists(rds_dir)) {
        if(rds_dir_ensure) {
            dir.create(rds_dir
                     , showWarnings = FALSE
                     , recursive = TRUE)
        } else {
            stop("romRDS -- The directory '"
               , rds_dir
               , "' does not exist and ensuring is disabled (see `rds_dir_ensure`)")
        }
    }
    ## make path
    file_path <- file.path(rds_dir, file_name)
    file_exist <- dir.exists(rds_dir) && 
        if(length(file_name_regex) == 0) {
            file.exists(file_path)
        } else {
            files_matched <-
                list.files(rds_dir, pattern = file_name_regex) |>
                sort(decreasing = TRUE)
            if(length(files_matched) != 0) {
                file_name <- files_matched[1]
                TRUE
            } else {
                FALSE
            }
        }
    val <- NULL
    if(file_exist) {
        if(!quietly) {
            time_started <- Sys.time()
            message("romRDS -- Reading ", file_path, "...")
        }
        val <- readRDS(file_path)
        if(!quietly) {
            message("romRDS -- READ ", name
                  , " - ", obj_size(val), " in ", dur_from(time_started))
        }
    } else if(!do_not_make) {
        if(!quietly) {
            time_started <- Sys.time()
            message("romRDS -- Making ", file_path, "...")
        }
        val <- eval(..., enclos = globalenv())
        ## do not save NULLs (this 'feature' used by rom_rds_read)
        if(!do_not_save && !is.null(val)) {
            saveRDS(val, file_path, compress = rds_compress)
        }
        if(!quietly) {
            message("romRDS -- MADE ", name
                  , " in ", dur_from(time_started)
                  , " and saved - ", obj_size(val))
        }
    } else if(!quietly) {
        message("romRDS -- Can not find ", file_path, " file to load.")
    }
    ## assining
    if(assign_to_name) {
        invisible(assign(name, val, pos = globalenv()))
    }
    ## returning
    if(return_name) {
        return(name)
    } else {
        invisible(val)
    }
}


##' @title Read or Make RDS
##'
##' @inherit rom_rds
##' @export
romRDS <- rom_rds


##' @title A wrapper around romRDS
##'
##' @description
##' Note that ... should be enclosed in {} if it is not a single expression. For example if you do 'var %<-% 1 + 1' var would be 1 not 2 but 'var %<-% {1 + 1}' will work as expected
##'
##' @param obj obj to assign to (also serves as .rds file name to make or search and load)
##' @param ... what to assign (make)
##' @export
`%<-%` <- function(obj, ...) {
    object_name <- deparse(substitute(obj))
    rom_rds(object_name, ... , assign_to_name = TRUE)
}
