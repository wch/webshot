shiny_url <- function(port) {
  sprintf("http://127.0.0.1:%d/", port)
}

server_exists <- function(url) {
  !inherits(
    try({ suppressWarnings(readLines(url, 1)) }, silent = TRUE),
    "try-error"
  )
}

webshot_app_timeout <- function() {
  getOption("webshot.app.timeout", 5)
}

wait_until_server_exists <- function(
  url,
  timeout = webshot_app_timeout()
) {
  cur_time <- function() {
    as.numeric(Sys.time())
  }
  start <- cur_time()
  repeat {
    if (server_exists(url)) {
      cat("Found!\n")
      break
    }
    if (cur_time() - start > timeout) {
      stop(
        'It took more than ', timeout, ' seconds to launch the server. ',
        'There may be something wrong. The process has been killed. ',
        'If the app needs more time to be launched, set ',
        'options(webshot.app.timeout) to a larger value.',
        call. = FALSE
      )
    }
    cat("waiting...\n")
    Sys.sleep(0.25)
  }
  # allow app to finish starting up
  Sys.sleep(0.5)
  TRUE
}
