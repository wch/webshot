#' Take a screenshot of a Shiny app
#'
#' \code{appshot} performs a \code{\link{webshot}} using two different
#' methods depending upon the object provided.  If a 'character' is provided
#' (pointing to an app.R file or app directory) an isolated background R
#' process is launched to run the Shiny application.  The current R process
#' then captures the \code{\link{webshot}}.  When a Shiny application object
#' is supplied to \code{appshot}, the Shiny application is run in the current
#' R process and an isolated background R process is launched to capture a
#' \code{\link{webshot}}.  Keeping the Shiny application in a different process
#' is ideal, shiny application objects are launched in the current R process to
#' avoid scoping errors.
#'
#' @inheritParams webshot
#' @param app A Shiny app object, or a string naming an app directory.
#' @param port Port that Shiny will listen on.
#' @param envvars A named character vector or named list of environment
#'   variables and values to set for the Shiny app's R process. These will be
#'   unset after the process exits. This can be used to pass configuration
#'   information to a Shiny app.
#' @param webshot_timeout The maximum number of seconds the phantom application
#' is allowed to run before killing the process. If a delay argument is supplied (in
#' \code{...}), the delay value is added to the timeout value.
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
                    port = getOption("shiny.port"), envvars = callr::rcmd_safe_env()) {
  UseMethod("appshot")
}


#' @rdname appshot
#' @export
appshot.character <- function(
  app,
  file = "webshot.png", ...,
  port = getOption("shiny.port"),
  envvars = callr::rcmd_safe_env()
) {

  port <- available_port(port)

  # Run app in background with envvars
  p <- callr::r_bg(
    function(...) {
      shiny::runApp(...)
    },
    args = list(
      appDir = app,
      port = port,
      display.mode = "normal"
    ),
    env = envvars
  )

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
appshot.shiny.appobj <- function(
  app,
  file = "webshot.png", ...,
  port = getOption("shiny.port"),
  envvars = callr::rcmd_safe_env(),
  webshot_timeout = 60
) {


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

  # add a delay to the webshot_timeout if it exists
  if(!is.null(args$delay)) {
    webshot_timeout <- webshot_timeout + args$delay
  }
  start_time <- as.numeric(Sys.time())

  # Add a shiny app observer which checks every 200ms to see if the background r session is alive
  shiny::observe({
    # check the r session rather than the file to avoid race cases or random issues
    if (r_session$is_alive()) {
      if ((as.numeric(Sys.time()) - start_time) <= webshot_timeout) {
        # try again later
        shiny::invalidateLater(200)
      } else {
        # timeout has occured. close the app and R session
        message("webshot timed out")
        r_session$kill()
        shiny::stopApp()
      }
    } else {
      # r_session has stopped, close the app
      shiny::stopApp()
    }
    return()
  })

  # run the app
  shiny::runApp(app, port = port, display.mode = "normal")

  # return webshot::webshot file value
  invisible(r_session$get_result()) # safe to call as the r_session must have ended
}
