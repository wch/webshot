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
#'   rmdshot("doc.rmd", "doc.png")
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
    render <- rmarkdown::render
    do.call("render", c(list(doc, output_file = outfile), rmd_args),
            envir = parent.frame())
    webshot(outfile, file = file, ...)
  }
}


rmdshot_shiny <- function(doc, file, ..., rmd_args, port, envvars) {

  port <- available_port(port)
  arg_string <- list_to_arg_string(rmd_args)
  if (nzchar(arg_string)) {
    arg_string <- paste0(", ", arg_string)
  }
  cmd <- sprintf(
    "rmarkdown::run('%s', shiny_args=list(port=%d)%s)",
    doc, port, arg_string
  )

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


# Convert a list of args like list(a=1, b="xyz") to a string like 'a=1, b="xyz"'
list_to_arg_string <- function(x) {

  item_to_arg_string <- function(name, val) {
    if (is.numeric(val))
      as.character(val)
    else if (is.character(val))
      paste0('"', val, '"')
    else
      stop("Only know how to handle numbers and strings arguments to rmarkdown::render. ",
        "Don't know how to handle argument `", val, "`.")
  }

  strings <- vapply(seq_along(x), function(n) item_to_arg_string(names(x)[n], x[[n]]), "")

  # Convert to a vector like c("a=1", "b=2")
  strings <- mapply(names(x), strings,
    FUN = function(name, val) paste(name, val, sep ="="),
    USE.NAMES = FALSE
  )

  paste(strings, collapse = ", ")
}


# Borrowed from rmarkdown
is_shiny <- function (runtime) {
  !is.null(runtime) && grepl("^shiny", runtime)
}
