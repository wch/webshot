#' Take a snapshot of an R Markdown document
#'
#' This function can handle both static Rmd documents and Rmd documents with
#' \code{runtime: shiny}.
#'
#' @inheritParams appshot
#' @param doc The path to a Rmd document.
#' @param delay Time to wait before taking screenshot, in seconds. Sometimes a
#'   longer delay is needed for all assets to display properly. If NULL (the
#'   default), then it will use 0.2 seconds for static Rmd documents, and 3
#'   seconds for Rmd documents with runtime:shiny.
#' @param rmd_args A list of additional arguments to pass to either
#'   \code{\link[rmarkdown]{render}} (for static Rmd documents) or
#'   \code{\link[rmarkdown]{run}} (for Rmd documents with runtime:shiny).
#'
#' @examples
#' if (interactive()) {
#'   input_file <- system.file("examples/knitr-minimal.Rmd", package = "knitr")
#'   rmdshot(input_file, "minimal_rmd.png")
#' }
#'
#' @export
rmdshot <- function(doc, file = "webshot.png", ..., delay = NULL, rmd_args = list(),
                    port = getOption("shiny.port"), envvars = callr::rcmd_safe_env()) {

  runtime <- rmarkdown::yaml_front_matter(doc)$runtime

  if (is_shiny(runtime)) {
    if (is.null(delay)) delay <- 3

    rmdshot_shiny(doc, file, ..., delay = delay, rmd_args = rmd_args,
      port = port, envvars = envvars)

  } else {
    if (is.null(delay)) delay <- 0.2

    outfile <- tempfile("webshot", fileext = ".html")
    render <- rmarkdown::render
    do.call("render", c(list(doc, output_file = outfile), rmd_args),
            envir = parent.frame())
    webshot(outfile, file = file, ...)
  }
}


rmdshot_shiny <- function(doc, file, ..., rmd_args, port, envvars) {

  port <- available_port(port)

  # Run app in background with envvars
  p <- callr::process$new(
    function(...) {
      rmarkdown::run(...)
    },
    args = append(
      list(file = doc, shiny_args = list(port = port)),
      rmd_args
    ),
    env = envvars
  )

  on.exit({
    p$kill()
  })

  # Wait for app to start
  Sys.sleep(0.5)

  fileout <- webshot(sprintf("http://127.0.0.1:%d/", port), file = file, ...)

  invisible(fileout)
}


# Borrowed from rmarkdown
is_shiny <- function (runtime) {
  !is.null(runtime) && grepl("^shiny", runtime)
}
