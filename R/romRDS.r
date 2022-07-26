#' @title  Read or Make RDS
#'
#' @description
#' Reads or makes .rds if file is not available and loads the object into memory.
#' @param obj_name 
#' @param ... 
#' @param dir Directory where to look for or save to .rds. Default is "data/rds"
#' @param file_name_sufix e.g., date or version.
#' @param file_name_sufix_sep Default is "."
#' @param file_name_extention Default is ".rds"
#' @param obj_name_has_extention Default is FALSE
#' @param compress_rds Default is FALSE. It is faster to read and write if rds is not compressed.
#' @param return_obj_name Default is FALSE
#' @param do_not_make Default is FALSE
#' @param quietly Default is FALSE
#' @param assign_to_obj_name 
#' @return Returns the object or name of the obj (if return_obj_name is TRUE).
#' @export
romRDS <- function(obj_name
                 , ...  # How to construct the object if it is not on disk
                 , dir = "data/rds"
                 , dir_create_if_not_exist = TRUE
                 , file_name_sufix = character(0)
                 , file_name_sufix_gen = NULL
                 , file_name_sufix_sep = "."
                 , file_name_extention = ".rds"
                 , obj_name_has_extention = FALSE
                 , compress_rds = FALSE
                 , return_obj_name = FALSE
                 , do_not_make = FALSE
                 , quietly = FALSE
                 , assign_to_obj_name = TRUE) {
    ## check arguments with checkmate (optionally)
    if (requireNamespace("checkmate", quietly = TRUE)) {
        checkmate::assert_character(obj_name, null.ok = FALSE)
        checkmate::assert_character(dir, null.ok = FALSE)
        checkmate::assert_character(file_name_sufix, null.ok = FALSE)
        checkmate::assert_choice(file_name_sufix_gen
                               , c("date", "time", "count", "cache")
                               , null.ok = FALSE)
        checkmate::assert_character(file_name_sufix_sep, null.ok = FALSE)
        checkmate::assert_character(file_name_extention, null.ok = FALSE)
        checkmate::assert_flag(dir_create_if_not_exist)
        checkmate::assert_flag(obj_name_has_extention)
        checkmate::assert_flag(compress_rds)
        checkmate::assert_flag(return_obj_name)
        checkmate::assert_flag(do_not_make)
        checkmate::assert_flag(quietly)
        checkmate::assert_flag(assign_to_obj_name)
    }

    ## make file_name and file_name_regex
    if (length(file_name_sufix) == 0 &&
        length(file_name_sufix_gen) == 0) {
        file_name_sufix_sep <- NULL
    }

    file_name_sufix_gen <-
        switch(file_name_sufix_gen
             , "date" = Sys.Date()
             , "time" = format(Sys.time(), "%Y-%d-%dT%H-%M-%S")
             , "counter" = ""
             , "cache" = ""
             , NULL)

    file_name_extention <-
        if(obj_name_has_extention) {
            file_name_extention <- tools::file_ext(obj_name)
        }

    file_name <- paste0(file_name_sufix_sep
                      , file_name_sufix
                      , file_name_sufix_gen
                      , file_name_extention)

    file_name_sufix_gen_regex <- 
        switch(file_name_sufix_gen
             , "date" = "\d\d\d\d-[0-1]\d-[0-3]\d"
             , "time" = "\d\d\d\d-\d\d-\d\dT[0-2]\d-[0-6]\d-[0-6]\d"
             , "counter" = "\d+" 
             , "cache" = ""
             , NULL)

    file_name <-
        paste0(file_name_sufix_sep
             , file_name_sufix
             , file_name_sufix_gen
             , file_name_extention)

    if(length(file_name_sufix_gen_regex) == 0) {
        file_name_regex <- NULL
    } else {
        escape_regex <- \(str) gsub("([.|()\\^{}+$*?]|\\[|\\])", "\\\\\\1", str)
        file_name_regex <- 
            paste0(escape_regex(file_name_sufix_sep)
                 , escape_regex(file_name_sufix)
                 , file_name_sufix_gen_regex
                 , escape_regex(file_name_extention))
    }

    ## handle directory
    dir <- path.expand(dir)
    if(!file.exists(dir)) {
        if(dir_create_if_not_exist) {
            dir.create(dir, recursive = TRUE)
        } else {
            stop("The directory '", dir, "' does not exist and auto creating is disabled (see `dir_create_if_not_exist`)")
        }
    }

    file_exist <-
        if (lenght(file_name_regex) == 0) {
            file.exists(file_path)
        } else {
            files_matched <-
                list.files(dir, pattern = file_name_regex) |>
                sort(decreasing = TRUE)
            if(length(files_matched) != 0) {
                file_name <- files_matched[1]
                TRUE
            } else {
                FALSE
            }
        }

    file_path <- file.path(dir, file_name)

    if(file_exist) {
        if(quietly) {
            assign(obj_name, readRDS(file_path), pos = 1)
        } else {
            time_started <- Sys.time()
            message("romRDS -- Loading file ", file_path)
            val <- readRDS(file_path)
            if(assign_to_obj_name) assign(obj_name, val, pos = 1)
            message("romRDS -- Loaded ", obj_name, " - ", obj_size(obj_name), " in ", dur_from(time_started))
        }

        if(return_obj_name) {
            return(obj_name)
        } else {
            return(invisible(val))
        }

    } else if(!do_not_make) {
        if(quietly) {
            val <- eval(...)
            saveRDS(val, file_path, compress = compress_rds)
            if(assign_to_obj_name) assign(obj_name, val, pos = 1)
        } else {
            time_started <- Sys.time()
            message("romRDS -- File ", file_path, " does not exist. Making one...")
            val <- eval(...)
            saveRDS(val, file_path, compress = compress_rds)
            if(assign_to_obj_name) assign(obj_name, val, pos = 1)
            message("romRDS -- Done! Made ", obj_name, " and saved - ", obj_size(obj_name), " in ", dur_from(time_started))
        }

        if(return_obj_name) {
            return(obj_name)
        } else {
            return(invisible(val))
        }

    } else if(!quietly) {
        message("romRDS -- Can not find ", file_path, " file to load.")
    }
}


#' @title Read or Make RDS
#'
#' @inherit romRDS
#' @export
#' @aliases romRDS
rom_rds <- romRDS


#' @title A wrapper around romRDS
#'
#' @param obj obj to assign to (also serves as .rds file name to make or search and load)
#' @param ... what to assign (make)
#' @export
`%<-%` <- function(obj, ...) {
    object_name <- deparse(substitute(obj))
    romRDS(object_name, ...)
}

## ok testing
lala %<-% 1 + 2/3
## nice works
