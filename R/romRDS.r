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

#' @title  Read or Make RDS
#'
#' @description
#' Reads or makes .rds if file is not available and loads the object into memory.
#' @param obj_name 
#' @param ... 
#' @param dir Directory where to look for or save to .rds. Default is "./rds"
#' @param file_name_sufix e.g., date or version. Default is ""
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
                 , dir = "rds"
                 , file_name_sufix = "" # e.g., date or version
                 , file_name_sufix_sep = "."
                 , file_name_extention = ".rds"
                 , obj_name_has_extention = FALSE
                 , compress_rds = FALSE
                 , return_obj_name = FALSE
                 , do_not_make = FALSE
                 , quietly = FALSE
                 , assign_to_obj_name = TRUE) {
    ## Experiments with utilizing name of the object as file name...
    ## get.object.name <- function(x) deparse(substitute(x))
    ## this does not work with pipes %>%
    ## TODO: I can check what tipe of argument
    file_name_sufix <-
        ifelse(file_name_sufix != ""
             , paste0(file_name_sufix_sep, file_name_sufix)
             , "")
    file_name_extention <-
        ifelse(obj_name_has_extention
             , tools::file_ext(obj_name)
             , file_name_extention)
    obj_name <-
        ifelse(obj_name_has_extention
             , tools::file_path_sans_ext(obj_name)
             , obj_name)
    dir <- path.expand(dir)
    file_path <- file.path(dir
                         , paste0(obj_name
                                , file_name_sufix
                                , ".", file_name_extention))
    if(file.exists(file_path)) {
        if(quietly) {
            assign(obj_name, readRDS(file_path), pos = 1)
        } else {
            time_started <- Sys.time()
            message("romRDS -- Loading file ", file_path)
            val <- readRDS(file_path)
            if(assign_to_obj_name) assign(obj_name, val, pos = 1)
            message("romRDS -- Loaded ", obj_name, " - ", obj_size(obj_name), " in ", dur_from(time_started))
        }
        if(return_obj_name) return(obj_name)
        else return(invisible(val))
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
        if(return_obj_name) return(obj_name)
        else return(invisible(val))
    } else if(!quietly) {
        message("romRDS -- Can not find ", file_path, " file to load.")
    }
}


#' @title Read or Make RDS
#'
#' @inherit romRDS
#' @export
#' @aliases romRDS
rom <- romRDS


#' @title A wrapper around romRDS
#'
#' @param obj obj to assign to (also serves as .rds file name to make or search and load)
#' @param ... what to assign (make)
#' @export
`%<-%` <- function(obj, ...) {
    object_name <- deparse(substitute(obj))    
    romRDS(object_name, ...)
}
