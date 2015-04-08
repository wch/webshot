phantom_run <- function(args, wait = TRUE) {
  phantom_bin <- find_phantom()
  if (phantom_bin == "")
    stop("phantomjs not found in path. phantomjs must be installed and in path.")

  # Make sure args is a char vector
  args <- as.character(args)

  system2(phantom_bin, args = args, wait = wait)
}


# Try really hard to find bower in Windows
find_phantom <- function(){
  # a slightly more robust finder of bower for windows
  # which does not require PATH environment variable to be set
  phantom_path = if(Sys.which("phantomjs") == "") {
    # if it does not find Sys.which('bower')
    # also check APPDATA to see if found there
    if(identical(.Platform$OS.type,"windows")) {
      Sys.which(file.path(Sys.getenv("APPDATA"),"npm","phantomjs."))
    }
  } else {
    Sys.which("phantomjs")
  }
  return(phantom_path)
}


# Given a vector or list, drop all the NULL items in it
dropNulls <- function(x) {
  x[!vapply(x, is.null, FUN.VALUE=logical(1))]
}
