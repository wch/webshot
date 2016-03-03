#' Take a screenshot of a Shiny app
#'
#' @inheritParams webshot
#' @param app A Shiny app object, or a string naming an app directory.
#' @param port Port that Shiny will listen on.
#' @param envvars A named character vector or named list of environment
#'   variables and values to set for the Shiny app's R process. These will be
#'   unset after the process exits. This can be used to pass configuration
#'   information to a Shiny app.
#'
#' @param ... Other arguments to pass on to \code{\link{webshot}}.
#'
#' @examples
#' if (interactive()) {
#'   appdir <- system.file("examples", "01_hello", package="shiny")
#'   appshot(appdir, "01_hello.png")
#' }
#'
#' @export
appshot <- function(app, file = "webshot.png", ...,
                    port = getOption("shiny.port"), envvars = NULL) {
  UseMethod("appshot")
}

#' @export
appshot.shiny.appobj <- function(app, file = "webshot.png", ...,
                                 port = getOption("shiny.port"), envvars = NULL) {
  stop("appshot of Shiny app objects is not yet supported.")
  # This would require running the app object in this R process
}

#' @export
appshot.character <- function(app, file = "webshot.png", ...,
                              port = getOption("shiny.port"), envvars = NULL) {
  pidfile <- normalizePath(tempfile("pid"), winslash = '/', mustWork = FALSE)
  on.exit(unlink(pidfile))
  port <- available_port(port)
  cmd <- "cat(Sys.getpid(), file='%s'); shiny::runApp('%s', port=%d, display.mode='normal')"
  cmd <- shQuote(sprintf(cmd, pidfile, app, port))

  # Save existing env vars and set new ones
  old_unset_vars <- NULL
  old_set_vars <- NULL
  if (length(envvars) != 0) {
    old_vars <- Sys.getenv(names(envvars), unset = NA, names = TRUE)
    # Char vector of variables that weren't set
    old_unset_vars <- names(old_vars)[is.na(old_vars)]
    # Named list of variables that were set
    old_set_vars <- as.list(old_vars[!is.na(old_vars)])

    do.call(Sys.setenv, as.list(envvars))
  }

  # Run app in background
  system2("R", args = c("--slave", "-e", cmd), wait = FALSE)

  on.exit({
    # Restore old env vars
    if (length(old_set_vars) != 0 )
      do.call(Sys.setenv, old_set_vars)
    if (length(old_unset_vars) != 0)
      Sys.unsetenv(old_unset_vars)

    # Kill app on exit
    pid <- readLines(pidfile, warn = FALSE)
    file.remove(pidfile)
    res <- if (is_windows()) {
      system2("taskkill", c("/pid", pid, "/f"))
    } else {
      system2("kill", pid)
    }
    if (res != 0) {
      stop(sprintf("`kill %s` didn't return success code. Value: %d", pid, res))
    }
  })

  # Wait for app to start
  Sys.sleep(0.5)

  fileout <- webshot(sprintf("http://127.0.0.1:%d/", port), file = file, ...)

  invisible(fileout)
}
