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
#' @rdname appshot
#' @examples
#' if (interactive()) {
#'   appdir <- system.file("examples", "01_hello", package="shiny")
#'
#'   # With a Shiny directory
#'   appshot(appdir, "01_hello.png")
#'
#'   # With a Shiny App object
#'   shinyapp <- shiny::shinyAppDir(appdir)
#'   appshot(shinyapp, "01_hello_app.png")
#' }
#'
#' @export
appshot <- function(app, file = "webshot.png", ...,
                    port = getOption("shiny.port"), envvars = NULL) {
  UseMethod("appshot")
}


#' @rdname appshot
#' @export
appshot.character <- function(app, file = "webshot.png", ...,
                              port = getOption("shiny.port"), envvars = NULL) {
  port <- available_port(port)
  cmd <- sprintf("shiny::runApp('%s', port=%d, display.mode='normal')", app, port)

  # Run app in background with envvars
  withr::with_envvar(envvars, {
    p <- processx::process$new("R", args = c("--slave", "-e", cmd))
  })

  # Make sure app is killed on exit
  on.exit({
    p$kill()
  })

  # Wait for app to start
  Sys.sleep(0.5)

  # Get screenshot
  fileout <- webshot(sprintf("http://127.0.0.1:%d/", port), file = file, ...)

  invisible(fileout)
}


#' @rdname appshot
#' @export
appshot.shiny.appobj <- function(app, file = "webshot.png", ...,
                              port = getOption("shiny.port"), envvars = NULL) {


  port <- available_port(port)

  args <- list(
    url = sprintf("http://127.0.0.1:%d/", port),
    file = file,
    ...
  )
  r_session <- callr::r_bg(
    function(...) {
      # Wait for app to start
      Sys.sleep(0.5)
      webshot::webshot(...)
    },
    args
  )

  # Add a shiny app observer which checks every 200ms to see if the background r session is alive
  shiny::observe({
    # check the r session rather than the file to avoid race cases or random issues
    if (r_session$is_alive()) {
      # try again later
      shiny::invalidateLater(200)
    } else {
      # r_session has stopped, close the app
      shiny::stopApp()
    }
    return()
  })

  # run the app
  shiny::runApp(app, port = port, display.mode = "normal")

  # return webshot::webshot file value
  r_session$get_result() # safe to call as the r_session must have ended
}
