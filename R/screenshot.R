#' Take a screenshot of a URL
#'
#' @param url A URL to visit.
#' @param file Name of output file. Should end with \code{.png}.
#' @param vwidth Viewport width. This is the width of the browser "window".
#' @param vheight Viewport height This is the height of the browser "window".
#' @param cliprect Clipping rectangle. If unspecified, the clipping rectangle
#'   matches the viewport size. Otherwise, it should be a four-element numeric
#'   vector specifying the top, left, width, and height. This option is not
#'   compatible with \code{selector}.
#' @param selector A CSS selector specifying a DOM element to set the clipping
#'   rectangle to. A screenshot of just this DOM element will be taken. If the
#'   selector has more than one match, only the first one will be used. This
#'   option is not compatible with \code{cliprect}.
#'
#' @examples
#' url_shot("http://www.rstudio.com/", "rstudio-header.png", selector = "#header")
#' url_shot("https://github.com/rstudio/shiny/", "shiny-stats.png",
#'          selector = "ul.numbers-summary")
#'
#' @export
url_shot <- function(
  url = NULL,
  file = "appshot.png",
  vwidth = 920,
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

  } else if (is.null(cliprect) && is.null(selector)) {
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
