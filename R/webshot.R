#' Take a screenshot of a URL
#'
#' @param url A URL to visit.
#' @param file Name of output file. Should end with \code{.png}.
#' @param vwidth Viewport width. This is the width of the browser "window".
#' @param vheight Viewport height This is the height of the browser "window".
#' @param cliprect Clipping rectangle. If \code{cliprect} and \code{selector}
#'   are both unspecified, the clipping rectangle will contain the entire page.
#'   This can be the string \code{"viewport"}, in which case the clipping
#'   rectangle matches the viewport size, or it can be a four-element numeric
#'   vector specifying the top, left, width, and height. This option is not
#'   compatible with \code{selector}.
#' @param selector A CSS selector specifying a DOM element to set the clipping
#'   rectangle to. A screenshot of just this DOM element will be taken. If the
#'   selector has more than one match, only the first one will be used. This
#'   option is not compatible with \code{cliprect}.
#' @param delay Time to wait before taking screenshot, in seconds. Sometimes a
#'   longer delay is needed for all assets to display properly.
#'
#' @examples
#' \donttest{
#' # Whole web page
#' webshot("http://www.rstudio.com/")
#'
#' # Might need a longer delay for all assets to display
#' webshot("http://www.rstudio.com/", delay = 500)
#'
#' # Clip to the viewport
#' webshot("http://www.rstudio.com/", "rstudio-viewport.png",
#'         cliprect = "viewport")
#'
#' # Manual clipping rectangle
#' webshot("http://www.rstudio.com/", "rstudio-clip.png",
#'         cliprect = c(510, 5, 290, 350))
#'
#' # Using CSS selectors to pick out regions
#' webshot("http://www.rstudio.com/", "rstudio-header.png", selector = "#header")
#'
#' # If multiple matches for a selector, it uses the first match
#' webshot("http://www.rstudio.com/", "rstudio-block.png", selector = "article.col")
#' webshot("https://github.com/rstudio/shiny/", "shiny-stats.png",
#'          selector = "ul.numbers-summary")
#' }
#'
#' @seealso \code{\link{webshot}} for taking screenshots of Shiny applications.
#' @export
webshot <- function(
  url = NULL,
  file = "webshot.png",
  vwidth = 992,
  vheight = 744,
  cliprect = NULL,
  selector = NULL,
  delay = 0.2
) {

  if (is.null(url)) {
    stop("Need url.")
  }

  if (!is.null(cliprect) && !is.null(selector)) {
    stop("Can't specify both cliprect and selector.")

  } else if (is.null(selector) && !is.null(cliprect)) {
    if (is.character(cliprect)) {
      if (cliprect == "viewport") {
        cliprect <- c(0, 0, vwidth, vheight)
      } else {
        stop("Invalid value for cliprect: ", cliprect)
      }
    } else {
      if (!is.numeric(cliprect) || length(cliprect) != 4) {
        stop("cliprect must be a 4-element numeric vector")
      }
    }
  }

  args <- dropNulls(list(
    system.file("webshot.js", package = "webshot"),
    url,
    file,
    paste0("--vwidth=", vwidth),
    paste0("--vheight=", vheight),
    if (!is.null(cliprect)) paste0("--cliprect=", paste(cliprect, collapse=",")),
    if (!is.null(selector)) paste0("--selector=", selector),
    if (!is.null(delay)) paste0("--delay=", delay)
  ))

  phantom_run(args)
}
