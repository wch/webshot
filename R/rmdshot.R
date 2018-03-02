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
#'   # rmdshot("rmarkdown_file.Rmd", "snapshot.png")
#'
#'   # R Markdown file
#'   input_file <- system.file("examples/knitr-minimal.Rmd", package = "knitr")
#'   rmdshot(input_file, "minimal_rmd.png")
#'
#'   # Shiny R Markdown file
#'   input_file <- system.file("examples/shiny.Rmd", package = "webshot")
#'   rmdshot(input_file, "shiny_rmd.png", delay = 5)
#' }
#'
#' @export
rmdshot <- function(doc, file = "webshot.png", ..., delay = NULL, rmd_args = list(),
                    port = getOption("shiny.port"), envvars = NULL) {

  runtime <- rmarkdown::yaml_front_matter(doc)$runtime

  if (is_shiny(runtime)) {
    if (is.null(delay)) delay <- 3

    rmdshot_shiny(doc, file, ..., delay = delay, rmd_args = rmd_args,
      port = port, envvars = envvars)

  } else {
    if (is.null(delay)) delay <- 0.2

    outfile <- tempfile("webshot", fileext = ".html")
    do.call(rmarkdown::render, c(list(doc, output_file = outfile), rmd_args))
    webshot(outfile, file = file, ...)
  }
}


rmdshot_shiny <- function(doc, file, ..., rmd_args, port, envvars) {

  port <- available_port(port)
  url <- shiny_url(port)

  # Run app in background with envvars
  p <- r_background_process(
    function(...) {
      rmarkdown::run(...)
    },
    args = append(
      list(file = doc, shiny_args = list(port = port)),
      rmd_args
    ),
    envvars = envvars
  )
  on.exit({
    p$kill()
  })

  # Wait for app to start
  wait_until_server_exists(url)

  fileout <- webshot(url, file = file, ...)

  invisible(fileout)
}


# Borrowed from rmarkdown
is_shiny <- function (runtime) {
  !is.null(runtime) && grepl("^shiny", runtime)
}
