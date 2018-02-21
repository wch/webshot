#' Take a screenshot of a Shiny app
#'
#' @inheritParams webshot
#' @param app A Shiny app object, or a string naming an app directory.
#' @param port Port that Shiny will listen on.
#' @param envvars A named character vector or named list of environment
#'   variables and values to set for the Shiny app's R process. These will be
#'   unset after the process exits. This can be used to pass configuration
#'   information to a Shiny app.
#' @param env Environment to export all R objects for the Shiny app object.
#' @param packages Character vector of R packages required for the Shiny app execution.  Defaults to use the currently attached packages.
#' @param save_file File used to temporarily save the Shiny app object.
#' @param env_file File used to temporarily save the Shiny app object server context to execute the app.
#'
#' @param ... Other arguments to pass on to \code{\link{webshot}}.
#'
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

#' @export
appshot.shiny.appobj <- function(
  app,
  file = "webshot.png", ...,
  port = getOption("shiny.port"),
  envvars = NULL,
  env = NULL,
  packages = NULL,
  save_file = tempfile(fileext = ".RData"),
  env_file = tempfile(fileext = ".RData")
) {
  # if the app has a specified port, use it
  if (is.null(port)) {
    port <- app$options$port
  }
  port <- available_port(port)

  if (is.null(env)) {
    env <- environment(app$serverFuncSource())
  }
  if (is.null(packages)) {
    packages <- {
      pkgs <- loadedNamespaces()
      attached <- paste0("package:", pkgs) %in% search()
      pkgs[attached]
    }
  }

  ## save the app to a file to be reloaded
  # save to (hopefully) non matching names
  .appshot.app <- app
  # get the currently loaded packages
  .appshot.packages <- packages
  # save all the items in the server env
  save(list = ls(envir = env), envir = env, file = env_file, eval.promises = FALSE)
  # save the app and loaded package names
  save(.appshot.app, .appshot.packages, file = save_file, eval.promises = FALSE)

  # load env
  # load .appshot.*
  # library package
  # run app
  cmd <- sprintf(
    "load('%s'); load('%s'); lapply(.appshot.packages, base::library, character.only = TRUE); shiny::runApp(.appshot.app, port=%d, display.mode='normal')",
    env_file, save_file, port
  )

  # take the screen shot
  appshot_webshot(file, port, cmd, envvars, ...)
}

#' @export
appshot.character <- function(app, file = "webshot.png", ...,
                              port = getOption("shiny.port"), envvars = NULL) {
  port <- available_port(port)
  cmd <- sprintf("shiny::runApp('%s', port=%d, display.mode='normal')", app, port)

  appshot_webshot(file, port, cmd, envvars, ...)
}


appshot_webshot <- function(file, port, cmd, envvars, ...) {
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
