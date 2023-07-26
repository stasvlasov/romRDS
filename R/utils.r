obj_size <-  function(obj) {
    bytes <- utils::object.size(obj)
        format(bytes, units = "auto")
}


dur_from <- function(start_time) {
    seconds <-
        (Sys.time() - start_time) |> as.numeric()
    minutes <- seconds %/% 60
    hours <- minutes %/% 60
    minutes <- if(minutes > 0) paste0(minutes %% 60, "m ")
    hours <- if(hours > 0) paste0(hours, "h ")
    paste0(hours
         , minutes
         , round(seconds) %% 60, "s")
}

get_dir_vector <- function(ext, dir_map, dir_root = NULL) {
    dir_names <- names(dir_map)
    ## use simply as directory to put everything in
    if(is.character(dir_map) && length(dir_map) == 1 && is.null(dir_names)) {
        return(dir_map)
    }
    ## ensure dir_names are not zero length to use in mapply
    if(is.null(dir_names)) dir_names <- rep("", length(dir_map))
    mapply(\(exts, dir_name) {
        ## if list element is unnamed then use ext as dir
        if(dir_name == "") dir_name <- exts[[1]]
        if(is.character(exts)) {
            if(ext %in% exts) c(dir_root, dir_name) else NULL
        } else if(is.list(exts)) {
            get_dir_vector(ext, exts, c(dir_root, dir_name))
        } else {
            stop("get_dir_vector -- Wrong specification of `dir_map`. It should be either list of character")
        }
    }
  , exts = dir_map
  , dir_name = dir_names
  , SIMPLIFY = FALSE
  , USE.NAMES = FALSE) |>
      unlist()
}

##' Makes path from file_name using directory to extention mappings specified in dir_map
##' @param file_names File names. Could also be a paths but only file's base name will be used
##' @param dir_map A specification of mapping between file extention and directory. Can be a named list where names used as directory names and values if it is character are corresponding extentions that should go to the directory name or if it is list futher mappings of extentions to subdirectories in recursive manner
##' @param dir_only return dir path only
##' @param dir_terminate_with_sep if only dir path is returned whether to therminate it with dir separator (e.g. if it set then 'path/to/dor/' note separator '/' at the end)
##' @param make_dir Whether to create dir recursively if it does not exists
##' @return A path as a string
get_path <- function(file_names
                   , dir_map = get_dir_map()
                   , dir_only = FALSE
                   , dir_terminate_with_sep = TRUE
                   , make_dir = TRUE) {
    if(any(duplicated(unlist(dir_map)))) {
        stop("get_path -- Extentions can be mapped only to one directory. Check for duplicated values in `dir_map`")
    }
    file_names <- basename(file_names)
    file_exts <- tools::file_ext(file_names)
    mapply(\(file_name, file_ext) {
        file_path <- get_dir_vector(file_ext, dir_map)
        if(is.null(file_path)) {
            stop("get_path -- Do not know where to deploy the files with '", file_ext
               , "' extention. Please, advice specification of `dir_map`")
        } else {
            file_path <- do.call(file.path, as.list(file_path))
            if(make_dir && !dir.exists(file_path)) {
                dir.create(file_path, recursive = TRUE)
            }
            if(!dir_only) {
                file_path <- file.path(file_path, file_name)
            } else if(dir_terminate_with_sep) {
                file_path <- file.path(file_path, "")
            }
            return(file_path)
        }
    }
  , file_name = file_names
  , file_ext = file_exts
  , SIMPLIFY = FALSE
  , USE.NAMES = FALSE) |>
      unlist()
}

is_url <- function(str) {
    if(is.null(str)) return(FALSE)
    grepl(pattern = "^http[s]?://", str)
}

is_ext <- function(ext, file_name) {
    if(is.null(file_name)) return(FALSE)
    grepl(pattern = paste0("\\.", ext, "$"), file_name)
}
