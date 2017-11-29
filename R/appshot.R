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
  port <- available_port(port)
  cmd <- sprintf("shiny::runApp('%s', port=%d, display.mode='normal')", app, port)

  # Run app in background with envvars
  withr::with_envvar(envvars, {
    p <- processx::process$new("R", args = c("--slave", "-e", cmd))
  })

  on.exit({
    p$kill()
  })

  # Wait for app to start
  Sys.sleep(0.5)

  fileout <- webshot(sprintf("http://127.0.0.1:%d/", port), file = file, ...)

  invisible(fileout)
}
