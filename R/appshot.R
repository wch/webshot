#' Take a screenshot of a Shiny app
#'
#' @inheritParams web_shot
#' @param app A Shiny app object, or a string naming an app directory.
#' @param port Port that Shiny will listen on.
#' @param ... Other arguments to pass on to \code{\link{web_shot}}.
#'
#' @examples
#' \donttest{
#' appdir <- system.file("examples", "01_hello", package="shiny")
#' app_shot(appdir, "01_hello.png")
#' }
#'
#' @export
app_shot <- function(app, file, ..., port = 9000) UseMethod("app_shot")

#' @export
app_shot.shiny.appobj <- function(app, file,..., port = 9000) {
  stop("app_shot of Shiny app objects is not yet supported.")
  # This would require running the app object in this R process
}

#' @export
app_shot.character <- function(app, file,..., port = 9000) {
  pidfile <- tempfile("pid")
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

  web_shot(sprintf("http://127.0.0.1:%d/", port), file = file, ...)

  # Kill app
  pid <- readLines(pidfile, warn = FALSE)
  res <- system2("kill", pid)

  if (res != 0) {
    warning(sprintf("`kill %s` didn't return success code. Value: %d", pid, res))
  }
}
