#' @import magrittr
dur_from <- function(start_time) {
    Sys.time() |> 
        subtract(start_time) |>
        as.numeric() |>
        humanFormat::formatSeconds()
}

#' @import magrittr
obj_size <-  function(obj_name) {
    obj_name |> 
        get() |> 
        object.size() |> 
        humanFormat::formatBytes()
}

#' @title  Read or Make RDS
#'
#' @description
#' Reads or makes .rds if file is not available
#' @param dir Directory where to look for or save to .rds. Default is "./rds"
#' @param file_name_sufix e.g., date or version. Default is ""
#' @param file_name_sufix_sep Default is "."
#' @param file_name_extention Default is ".rds"
#' @param obj_name_has_extention Default is FALSE
#' @param return_obj_name Default is FALSE
#' @param do_not_make Default is FALSE
#' @param quietly Default is FALSE
#' @param compress_rds Default is FALSE. It is faster to read and write if rds is not compressed.
#' @return Nothing or name of the obj. Loads object into memory..
#' @import magrittr stringr
#' @export
#' @md
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
                 , quietly = FALSE) {
    ## Experiments with utilizing name of the object as file name...
    ## get.object.name <- function(x) deparse(substitute(x))
    ## this does not work with pipes %>%
    ## TODO: I can check what tipe of argument
    file_name_sufix %<>% {ifelse(. != "", paste0(file_name_sufix_sep, .), "")}
    file_name_extention %<>% ifelse(obj_name_has_extention
                                  , str_extract(obj_name, "\\.[^\\.]+$"), .)
    obj_name %<>% ifelse(obj_name_has_extention, str_remove(., "\\.[^\\.]+$"), .)
    dir %<>% path.expand
    file.path <- file.path(dir
                         , paste0(obj_name
                                , file_name_sufix
                                , file_name_extention))
    if(file.path %>% file.exists) {
        if(quietly) {
            readRDS(file.path) %>% assign(obj_name, ., 1)
        } else {
            time.started <- Sys.time()
            message("Loading file ", file.path)
            readRDS(file.path) %>%
                assign(obj_name, ., 1)
            message("Loaded ", obj_name, " - ", obj_size(obj_name), " in ", dur_from(time.started))
        }
        if(return_obj_name) obj_name
    } else if(!do_not_make) {
        if(quietly) {
            eval(...) %T>% saveRDS(file.path, compress = compress_rds) %>% assign(obj_name, ., 1)
        } else {
            time.started <- Sys.time()
            message("File ", file.path, " does not exist. Making one...")
            eval(...) %T>% saveRDS(file.path, compress = compress_rds) %>% assign(obj_name, ., 1)
            message("Done! Made ", obj_name, " and saved - ", obj_size(obj_name), " in ", dur_from(time.started))
        }
        if(return_obj_name) obj_name
    } else if(!quietly) {
        message("Can not find ", file.path, " file.")
    }}


#' @title Read or Make RDS
#'
#' @description
#' A shorthand for romRDS. Reads or makes .rds if file is not available
#' @param ... Parameters passed to 'romRDS'
#' @return Nothing or name of the obj. Loads object into memory..
#' @export
#' @md
rom <- function(...) romRDS(...)



`%<-%` <- function(obj_name, ...) {

}
