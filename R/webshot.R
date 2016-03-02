#' Take a screenshot of a URL
#'
#' @param url A URL to visit.
#' @param file Name of output file. Should end with \code{.png}, \code{.pdf}, or
#'   \code{.jpeg}.
#' @param vwidth Viewport width. This is the width of the browser "window".
#' @param vheight Viewport height This is the height of the browser "window".
#' @param cliprect Clipping rectangle. If \code{cliprect} and \code{selector}
#'   are both unspecified, the clipping rectangle will contain the entire page.
#'   This can be the string \code{"viewport"}, in which case the clipping
#'   rectangle matches the viewport size, or it can be a four-element numeric
#'   vector specifying the top, left, width, and height. This option is not
#'   compatible with \code{selector}.
#' @param selector One or more CSS selectors specifying a DOM element to set the
#'   clipping rectangle to. The screenshot will contain these DOM elements. For
#'   a given selector, if it has more than one match, only the first one will be
#'   used. This option is not compatible with \code{cliprect}.
#' @param delay Time to wait before taking screenshot, in seconds. Sometimes a
#'   longer delay is needed for all assets to display properly.
#' @param expand A numeric vector specifying how many pixels to expand the
#'   clipping rectangle by. If one number, the rectangle will be expanded by
#'   that many pixels on all sides. If four numbers, they specify the top,
#'   right, bottom, and left, in that order.
#' @param eval An optional string with JavaScript code which will be evaluated
#'   after opening the page and waiting for \code{delay}, but before calculating
#'   the clipping region and taking the screenshot. See the Casper API
#'   (\url{http://docs.casperjs.org/en/latest/modules/casper.html}) for more
#'   information about what commands can be used to control the web page. NOTE:
#'   This is experimental and likely to change!
#'
#' @examples
#' if (interactive()) webshot("https://github.com/rstudio/shiny")
#'
#' # See more examples in the package vignette
#' vignette("intro", package = "webshot")
#' @seealso \code{\link{appshot}} for taking screenshots of Shiny applications.
#' @export
webshot <- function(
  url = NULL,
  file = "webshot.png",
  vwidth = 992,
  vheight = 744,
  cliprect = NULL,
  selector = NULL,
  expand = NULL,
  delay = 0.2,
  eval = NULL
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

  if (!is.null(expand)) {
    if (!(length(expand) %in% c(1, 4))) {
      stop("expand must either have 1 or 4 values");
    }
  }

  args <- dropNulls(list(
    shQuote(system.file("webshot.js", package = "webshot")),
    url,
    file,
    paste0("--vwidth=", vwidth),
    paste0("--vheight=", vheight),
    if (!is.null(cliprect)) paste0("--cliprect=", paste(cliprect, collapse=",")),
    if (!is.null(selector)) paste0("--selector=", paste(shQuote(selector), collapse=",")),
    if (!is.null(delay)) paste0("--delay=", delay),
    if (!is.null(expand)) paste0("--expand=", paste(expand, collapse=",")),
    if (!is.null(eval)) paste0("--eval=", shQuote(eval))
  ))

  res <- phantom_run(args)

  if (res != 0) {
    stop("webshot.js returned failure value: ", res)
  }

  invisible(file)
}
