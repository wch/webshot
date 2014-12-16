phantom_run <- function(args, wait = TRUE) {
  phantom_bin <- Sys.which("phantomjs")
  if (phantom_bin == "")
    stop("phantomjs not found in path. phantomjs must be installed and in path.")

  # Make sure args is a char vector
  args <- as.character(args)

  system2(phantom_bin, args = args, wait = wait)
}

# Given a vector or list, drop all the NULL items in it
dropNulls <- function(x) {
  x[!vapply(x, is.null, FUN.VALUE=logical(1))]
}
