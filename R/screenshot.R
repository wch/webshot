#' @export
app_shot <- function(
  url = NULL,
  file = "screenshot.png",
  vwidth = 800,
  vheight = 600,
  cliprect = NULL,
  selector = NULL,
  port = NULL
) {

  if (is.null(url)) {
    stop("Need url.")
  }

  if (!is.null(cliprect) && !is.null(selector)) {
    stop("Can't specify both cliprect and selector.")

  } else if (is.null(cliprect)) {
    cliprect <- c(0, 0, vwidth, vheight)
  }

  args <- dropNulls(list(
    system.file("screenshot.js", package = "appshot"),
    url,
    file,
    paste0("--vwidth=", vwidth),
    paste0("--vheight=", vheight),
    if (!is.null(cliprect)) paste0("--cliprect=", paste(cliprect, collapse=",")),
    if (!is.null(selector)) paste0("--selector=", selector)
  ))

  phantom_run(args)
}
