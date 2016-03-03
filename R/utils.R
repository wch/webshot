phantom_run <- function(args, wait = TRUE) {
  phantom_bin <- find_phantom()
  if (phantom_bin == "") {
    stop("phantomjs not found. phantomjs must be installed and in PATH. ",
         if (is_windows()) "You may use install_phantomjs() to install it.")
  }

  # Make sure args is a char vector
  args <- as.character(args)

  system2(phantom_bin, args = args, wait = wait)
}


# Try really hard to find bower in Windows
find_phantom <- function() {
  # a slightly more robust finder of bower for windows
  # which does not require PATH environment variable to be set
  phantom_path <-  if (Sys.which( "phantomjs" ) == "") {
    # if it does not find Sys.which('bower')
    # also check APPDATA to see if found there
    if (is_windows()) {
      appdata <- Sys.getenv('APPDATA', NA)
      if (is.na(appdata)) "" else {
        path <- file.path(appdata, "PhantomJS", "phantomjs.exe")
        if (utils::file_test('-x', path)) path else {
          Sys.which(file.path(appdata, "npm", "phantomjs.cmd"))
        }
      }
    }
  } else {
    Sys.which( "phantomjs" )
  }

  phantom_path
}

#' Install PhantomJS
#'
#' Download the zip package, unzip it, and copy the executable to a system
#' directory in which \pkg{webshot} can look for the PhantomJS executable.
#' Currently this function only works for Windows. Mac OS X users are
#' recommended to install PhantomJS via Homebrew. If you download the package
#' from the PhantomJS website instead, please make sure the executable can be
#' found via the \code{PATH} variable.
#' @param version The version number of PhantomJS.
#' @return \code{NULL} (the executable is written to a system directory).
#' @export
install_phantomjs <- function(version = '2.1.1') {
  if (!is_windows()) {
    warning('This function is currently for Windows only')
    return()
  }

  appdata <- Sys.getenv('APPDATA', NA)
  if (is.na(appdata)) stop('The environment variable APPDATA is not set')
  destdir <- file.path(appdata, 'PhantomJS')
  dir.create(destdir, showWarnings = FALSE)

  owd <- setwd(tempdir())
  on.exit(setwd(owd), add = TRUE)
  zipfile <- sprintf('phantomjs-%s-windows.zip', version)
  link <- paste0('https://bitbucket.org/ariya/phantomjs/downloads/', zipfile)
  download.file(link, zipfile, mode = 'wb')
  utils::unzip(zipfile)
  zipdir <- sub('.zip$', '', zipfile)
  file.copy(file.path(zipdir, 'bin', 'phantomjs.exe'), destdir, overwrite = TRUE)
  message('phantomjs.exe has been installed to ', normalizePath(destdir))
  unlink(c(zipdir, zipfile), recursive = TRUE)
  invisible()
}

# Given a vector or list, drop all the NULL items in it
dropNulls <- function(x) {
  x[!vapply(x, is.null, FUN.VALUE=logical(1))]
}

is_windows <- function() .Platform$OS.type == "windows"

# Find an available TCP port (to launch Shiny apps)
available_port <- function(port) {
  if (!is.null(port)) return(port)
  for (p in sample(3000:8000, 20)) {
    tmp <- try(httpuv::startServer('127.0.0.1', p, list()), silent = TRUE)
    if (!inherits(tmp, 'try-error')) {
      httpuv::stopServer(tmp)
      port <- p
      break
    }
  }
  if (is.null(port)) stop("Cannot find an available port")
  port
}
