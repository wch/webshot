phantom_run <- function(args, wait = TRUE) {
  phantom_bin <- find_phantom()

  # Make sure args is a char vector
  args <- as.character(args)

  system2(phantom_bin, args = args, wait = wait)
}


# Find PhantomJS from PATH, APPDATA, system.file('webshot'), ~/bin, etc
find_phantom <- function() {
  path <- Sys.which( "phantomjs" )
  if (path != "") return(path)
  for (d in phantom_paths()) {
    exec <- if (is_windows()) "phantomjs.exe" else "phantomjs"
    path <- file.path(d, exec)
    if (utils::file_test("-x", path)) break else path <- ""
  }
  if (path == "") {
    stop("PhantomJS not found. You can install it with webshot::install_phantomjs(). ",
         "If it is installed, please make sure the phantomjs executable ",
         "can be found via the PATH variable.")
  }
  path
}

#' Install PhantomJS
#'
#' Download the zip package, unzip it, and copy the executable to a system
#' directory in which \pkg{webshot} can look for the PhantomJS executable.
#'
#' This function was designed primarily to help Windows users since it is
#' cumbersome to modify the \code{PATH} variable. Mac OS X users may install
#' PhantomJS via Homebrew. If you download the package from the PhantomJS
#' website instead, please make sure the executable can be found via the
#' \code{PATH} variable.
#'
#' On Windows, the directory specified by the environment variable
#' \code{APPDATA} is used to store \file{phantomjs.exe}. On OS X, the directory
#' \file{~/Library/Application Support} is used. On other platforms (such as
#' Linux), the directory \file{~/bin} is used. If these directories are not
#' writable, the directory \file{PhantomJS} under the installation directory of
#' the \pkg{webshot} package will be tried. If this directory still fails, you
#' will have to install PhantomJS by yourself.
#' @param version The version number of PhantomJS.
#' @return \code{NULL} (the executable is written to a system directory).
#' @import utils
#' @export
install_phantomjs <- function(version = '2.1.1') {
  owd <- setwd(tempdir())
  on.exit(setwd(owd), add = TRUE)
  base <- 'https://bitbucket.org/ariya/phantomjs/downloads/'
  if (is_windows()) {
    zipfile <- sprintf('phantomjs-%s-windows.zip', version)
    download.file(paste0(base, zipfile), zipfile, mode = 'wb')
    utils::unzip(zipfile)
    zipdir <- sub('.zip$', '', zipfile)
    exec <- file.path(zipdir, 'bin', 'phantomjs.exe')
  } else if (is_osx()) {
    zipfile <- sprintf('phantomjs-%s-macosx.zip', version)
    download.file(paste0(base, zipfile), zipfile, mode = 'wb')
    utils::unzip(zipfile)
    zipdir <- sub('.zip$', '', zipfile)
    exec <- file.path(zipdir, 'bin', 'phantomjs')
    Sys.chmod(exec, '0755')  # chmod +x
  } else {
    zipfile <- sprintf(
      'phantomjs-%s-linux-%s.tar.bz2', version,
      if (grepl('64', Sys.info()[['machine']])) 'x86_64' else 'i686'
    )
    download.file(paste0(base, zipfile), zipfile, mode = 'wb')
    utils::untar(zipfile)
    zipdir <- sub('.tar.bz2$', '', zipfile)
    exec <- file.path(zipdir, 'bin', 'phantomjs')
    Sys.chmod(exec, '0755')  # chmod +x
  }
  success <- FALSE
  dirs <- phantom_paths()
  for (destdir in dirs) {
    dir.create(destdir, showWarnings = FALSE)
    success <- file.copy(exec, destdir, overwrite = TRUE)
    if (success) break
  }
  unlink(c(zipdir, zipfile), recursive = TRUE)
  if (!success) stop(
    'Unable to install PhantomJS to any of these dirs: ',
    paste(dirs, collapse = ', ')
  )
  message('phantomjs.exe has been installed to ', normalizePath(destdir))
  invisible()
}

# Possible locations of the PhantomJS executable
phantom_paths <- function() {
  if (is_windows()) {
    path <- Sys.getenv('APPDATA', '')
    path <- if (dir_exists(path)) file.path(path, 'PhantomJS')
  } else if (is_osx()) {
    path <- '~/Library/Application Support'
    path <- if (dir_exists(path)) file.path(path, 'PhantomJS')
  } else {
    path <- '~/bin'
  }
  path <- c(path, system.file('PhantomJS', package = 'webshot'))
  path
}

dir_exists <- function(path) utils::file_test('-d', path)

# Given a vector or list, drop all the NULL items in it
dropNulls <- function(x) {
  x[!vapply(x, is.null, FUN.VALUE=logical(1))]
}

is_windows <- function() .Platform$OS.type == "windows"
is_osx <- function() Sys.info()[['sysname']] == 'Darwin'

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
