#' Take a screenshot of a Shiny app
#'
#' @inheritParams webshot
#' @param app A Shiny app object, or a string naming an app directory.
#' @param port Port that Shiny will listen on.
#' @param ... Other arguments to pass on to \code{\link{webshot}}.
#'
#' @examples
#' \donttest{
#' appdir <- system.file("examples", "01_hello", package="shiny")
#' appshot(appdir, "01_hello.png")
#' }
#'
#' @export
appshot <- function(app, file = "webshot.png", ..., port = 9000) {
  UseMethod("appshot")
}

#' @export
appshot.shiny.appobj <- function(app, file = "webshot.png", ..., port = 9000) {
  stop("appshot of Shiny app objects is not yet supported.")
  # This would require running the app object in this R process
}

#' @export
appshot.character <- function(app, file = "webshot.png", ..., port = 9000) {
  pidfile <- tempfile("pid")
  on.exit(unlink(pidfile))
  cmd <- sprintf(
    "'cat(Sys.getpid(), file=\"%s\"); library(shiny); runApp(\"%s\", port=%d)'",
    pidfile,
    app,
    port
  )

  # Run app in background
  system2("R", args = c("--slave", "-e", cmd), wait = FALSE)

  # Wait for app to start
  Sys.sleep(0.5)

  fileout <- webshot(sprintf("http://127.0.0.1:%d/", port), file = file, ...)

  # Kill app
  pid <- readLines(pidfile, warn = FALSE)
  res <- system2("kill", pid)

  if (res != 0) {
    stop(sprintf("`kill %s` didn't return success code. Value: %d", pid, res))
  }

  invisible(fileout)
}
