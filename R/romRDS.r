#' @import magrittr
dur.from <- function(start.time) {
  Sys.time() %>% 
    subtract(start.time) %>%
    as.numeric %>%
    humanFormat::formatSeconds()
}

#' @import magrittr
obj.size <-  function(obj.name) {
  obj.name %>% 
    get %>% 
    object.size %>% 
    humanFormat::formatBytes()
}

#' @title  Read or Make RDS
#'
#' @description
#' Reads or makes .rds if file is not available
#' @param dir Directory where to look for or save to .rds. Default is "./rds"
#' @param file.name.sufix e.g., date or version. Default is ""
#' @param file.name.sufix.sep Default is "."
#' @param file.name.extention Default is ".rds"
#' @param obj.name.has.extention Default is FALSE
#' @param return.obj.name Default is FALSE
#' @param do.not.make Default is FALSE
#' @param quietly Default is FALSE
#' @param compress.rds Default is FALSE. It is faster to read and write if rds is not compressed.
#' @return Nothing or name of the obj. Loads object into memory..
#' @import magrittr stringr
#' @export
#' @md
romRDS <- function(obj.name
                           , ...  # How to construct the object if it is not on disk
                           , dir = "rds"
                           , file.name.sufix = "" # e.g., date or version
                           , file.name.sufix.sep = "."
                           , file.name.extention = ".rds"
                           , obj.name.has.extention = FALSE
                           , compress.rds = FALSE
                           , return.obj.name = FALSE
                           , do.not.make = FALSE
                           , quietly = FALSE) {
  ## Experiments with utilizing name of the object as file name...
  ## get.object.name <- function(x) deparse(substitute(x))
  ## this does not work with pipes %>%
  file.name.sufix %<>% {ifelse(. != "", paste0(file.name.sufix.sep, .), "")}
  file.name.extention %<>% ifelse(obj.name.has.extention
                                , str_extract(obj.name, "\\.[^\\.]+$"), .)
  obj.name %<>% ifelse(obj.name.has.extention, str_remove(., "\\.[^\\.]+$"), .)
  dir %<>% path.expand
  file.path <- file.path(dir
                       , paste0(obj.name
                              , file.name.sufix
                              , file.name.extention))
  if(file.path %>% file.exists) {
    if(quietly) {
      readRDS(file.path) %>% assign(obj.name, ., 1)
    } else {
      time.started <- Sys.time()
      message("Loading file ", file.path)
      readRDS(file.path) %>%
        assign(obj.name, ., 1)
      message("Loaded ", obj.name, " - ", obj.size(obj.name), " in ", dur.from(time.started))
    }
    if(return.obj.name) obj.name
  } else if(!do.not.make) {
    if(quietly) {
      eval(...) %T>% saveRDS(file.path, compress = compress.rds) %>% assign(obj.name, ., 1)
    } else {
      time.started <- Sys.time()
      message("File ", file.path, " does not exist. Making one...")
      eval(...) %T>% saveRDS(file.path, compress = compress.rds) %>% assign(obj.name, ., 1)
      message("Done! Made ", obj.name, " and saved - ", obj.size(obj.name), " in ", dur.from(time.started))
    }
    if(return.obj.name) obj.name
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
