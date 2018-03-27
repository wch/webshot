#' Take a screenshot of a URL
#'
#' @param url A vector of URLs to visit.
#' @param file A vector of names of output files. Should end with \code{.png},
#'   \code{.pdf}, or \code{.jpeg}. If several screenshots have to be taken and
#'   only one filename is provided, then the function appends the index number
#'   of the screenshot to the file name.
#' @param vwidth Viewport width. This is the width of the browser "window".
#' @param vheight Viewport height This is the height of the browser "window".
#' @param cliprect Clipping rectangle. If \code{cliprect} and \code{selector}
#'   are both unspecified, the clipping rectangle will contain the entire page.
#'   This can be the string \code{"viewport"}, in which case the clipping
#'   rectangle matches the viewport size, or it can be a four-element numeric
#'   vector specifying the top, left, width, and height. When taking screenshots
#'   of multiple URLs, this parameter can also be a list with same length as
#'   \code{url} with each element of the list being "viewport" or a
#'   four-elements numeric vector. This option is not compatible with
#'   \code{selector}.
#' @param selector One or more CSS selectors specifying a DOM element to set the
#'   clipping rectangle to. The screenshot will contain these DOM elements. For
#'   a given selector, if it has more than one match, only the first one will be
#'   used. This option is not compatible with \code{cliprect}. When taking
#'   screenshots of multiple URLs, this parameter can also be a list with same
#'   length as \code{url} with each element of the list containing a vector of
#'   CSS selectors to use for the corresponding URL.
#' @param delay Time to wait before taking screenshot, in seconds. Sometimes a
#'   longer delay is needed for all assets to display properly.
#' @param expand A numeric vector specifying how many pixels to expand the
#'   clipping rectangle by. If one number, the rectangle will be expanded by
#'   that many pixels on all sides. If four numbers, they specify the top,
#'   right, bottom, and left, in that order. When taking screenshots of multiple
#'   URLs, this parameter can also be a list with same length as \code{url} with
#'   each element of the list containing a single number or four numbers to use
#'   for the corresponding URL.
#' @param zoom A number specifying the zoom factor. A zoom factor of 2 will
#'   result in twice as many pixels vertically and horizontally. Note that using
#'   2 is not exactly the same as taking a screenshot on a HiDPI (Retina)
#'   device: it is like increasing the zoom to 200% in a desktop browser and
#'   doubling the height and width of the browser window. This differs from
#'   using a HiDPI device because some web pages load different,
#'   higher-resolution images when they know they will be displayed on a HiDPI
#'   device (but using zoom will not report that there is a HiDPI device).
#' @param eval An optional string with JavaScript code which will be evaluated
#'   after opening the page and waiting for \code{delay}, but before calculating
#'   the clipping region and taking the screenshot. See the Casper API
#'   (\url{http://docs.casperjs.org/en/latest/modules/casper.html}) for more
#'   information about what commands can be used to control the web page. NOTE:
#'   This is experimental and likely to change!
#' @param debug Print out debugging messages from PhantomJS and CasperJS. This can help to
#'   diagnose problems.
#' @param useragent The User-Agent header used to request the URL. Changing the
#'   User-Agent can mitigate rendering issues for some websites.
#'
#' @examples
#' if (interactive()) {
#'
#' # Whole web page
#' webshot("https://github.com/rstudio/shiny")
#'
#' # Might need a longer delay for all assets to display
#' webshot("http://rstudio.github.io/leaflet", delay = 0.5)
#'
#' # One can also take screenshots of several URLs with only one command.
#' # This is more efficient than calling 'webshot' multiple times.
#' webshot(c("https://github.com/rstudio/shiny",
#'           "http://rstudio.github.io/leaflet"),
#'         delay = 0.5)
#'
#' # Clip to the viewport
#' webshot("http://rstudio.github.io/leaflet", "leaflet-viewport.png",
#'         cliprect = "viewport")
#'
#' # Manual clipping rectangle
#' webshot("http://rstudio.github.io/leaflet", "leaflet-clip.png",
#'         cliprect = c(200, 5, 400, 300))
#'
#' # Using CSS selectors to pick out regions
#' webshot("http://rstudio.github.io/leaflet", "leaflet-menu.png", selector = ".list-group")
#' webshot("http://reddit.com/", "reddit-top.png",
#'         selector = c("input[type='text']", "#header-bottom-left"))
#'
#' # Expand selection region
#' webshot("http://rstudio.github.io/leaflet", "leaflet-boxes.png",
#'         selector = "#installation", expand = c(10, 50, 0, 50))
#'
#' # If multiple matches for a given selector, it uses the first match
#' webshot("http://rstudio.github.io/leaflet", "leaflet-p.png", selector = "p")
#' webshot("https://github.com/rstudio/shiny/", "shiny-stats.png",
#'          selector = "ul.numbers-summary")
#'
#' # Send commands to eval
#' webshot("http://www.reddit.com/", "reddit-input.png",
#'   selector = c("#search", "#login_login-main"),
#'   eval = "casper.then(function() {
#'     // Check the remember me box
#'     this.click('#rem-login-main');
#'     // Enter username and password
#'     this.sendKeys('#login_login-main input[type=\"text\"]', 'my_username');
#'     this.sendKeys('#login_login-main input[type=\"password\"]', 'password');
#'
#'     // Now click in the search box. This results in a box expanding below
#'     this.click('#search input[type=\"text\"]');
#'     // Wait 500ms
#'     this.wait(500);
#'   });"
#' )
#'
#' # Result can be piped to other commands like resize() and shrink()
#' webshot("https://www.r-project.org/", "r-small.png") %>%
#'  resize("75%") %>%
#'  shrink()
#'
#' # Requests can change the User-Agent header
#' webshot(
#'   "https://www.rstudio.com/products/rstudio/download/",
#'   "rstudio.png",
#'   useragent = "Mozilla/5.0 (Macintosh; Intel Mac OS X)"
#' )
#'
#' # See more examples in the package vignette
# vignette("intro", package = "webshot")
#' }
#'
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
  zoom = 1,
  eval = NULL,
  debug = FALSE,
  useragent = NULL
) {

  if (is.null(url)) {
    stop("Need url.")
  }

  # Convert params cliprect, selector and expand to list if necessary
  if(!is.null(cliprect) && !is.list(cliprect)) cliprect <- list(cliprect)
  if(!is.null(selector) && !is.list(selector)) selector <- list(selector)
  if(!is.null(expand) && !is.list(expand)) expand <- list(expand)

  # Check length of arguments
  arg_list <- list(
    url = url,
    file = file,
    vwidth = vwidth,
    vheight = vheight,
    cliprect = cliprect,
    selector = selector,
    expand = expand,
    delay = delay,
    zoom = zoom,
    eval = eval,
    debug = debug,
    options = options
  )
  arg_length <- vapply(arg_list, length, numeric(1))
  max_arg_length <- max(arg_length)
  if (any(! arg_length %in% c(0, 1, max_arg_length))) {
    stop("All arguments should have same length or be single elements or NULL")
  }

  # If url is of length one replicate it to match the maximal length of arguments
  if (length(url) < max_arg_length) url <- rep(url, max_arg_length)

  # If user provides only one file name but wants several screenshots, then the
  # below code generates as many file names as URLs following the pattern
  # "filename001.png", "filename002.png", ... (or whatever extension it is)
  if (length(url) > 1 && length(file) == 1) {
    file <- vapply(1:length(url), FUN.VALUE = character(1), function(i) {
      replacement <- sprintf("%03d.\\1", i)
      gsub("\\.(.{3,4})$", replacement, file)
    })
  }

  if (is_windows()) {
    url <- fix_windows_url(url)
  }

  if (!is.null(cliprect) && !is.null(selector)) {
    stop("Can't specify both cliprect and selector.")

  } else if (is.null(selector) && !is.null(cliprect)) {
    cliprect <- lapply(cliprect, function(x) {
      if (is.character(x)) {
        if (x == "viewport") {
          x <- c(0, 0, vwidth, vheight)
        } else {
          stop("Invalid value for cliprect: ", x)
        }
      } else {
        if (!is.numeric(x) || length(x) != 4) {
          stop("'cliprect' must be a 4-element numeric vector or a list of such vectors")
        }
      }
      x
    })
  }

  # check that expand is a vector of length 1 or 4 or a list of such vectors
  if (!is.null(expand)) {
    lengths <- vapply(expand, length, numeric(1))
    if (any(!lengths %in% c(1, 4))) {
      stop("'expand' must be a vector with one or four numbers, or a list of such vectors.")
    }
  }

  # Create the table that contains all options for each screenshot
  optsList <- data.frame(url = url, file = file, vwidth = vwidth, vheight = vheight)

  # Params selector, cliprect and expand can be either a vector that need to be
  # concatenated or a list of such vectors. This function can be used to convert
  # them into a character vector with the desired format.
  argToVec <- function(arg) {
    vapply(arg, FUN.VALUE = character(1), function(x) {
      if (is.null(x) || is.na(x)) NA_character_
      else paste(x, collapse = ",")
    })
  }

  if (!is.null(cliprect)) optsList$cliprect <- argToVec(cliprect)
  if (!is.null(selector)) optsList$selector <- argToVec(selector)
  if (!is.null(expand)) optsList$expand <- argToVec(expand)
  if (!is.null(delay)) optsList$delay <- delay
  if (!is.null(zoom)) optsList$zoom <- zoom
  if (!is.null(eval)) optsList$eval <- eval
  if (!is.null(useragent)) optsList$options <- jsonlite::toJSON(
    list(pageSettings = list(userAgent = useragent)),
    auto_unbox = TRUE
  )
  optsList$debug <- debug

  args <- list(
    # Workaround for SSL problem: https://github.com/wch/webshot/issues/51
    # https://stackoverflow.com/questions/22461345/casperjs-status-fail-on-a-webpage
    "--ignore-ssl-errors=true",
    system.file("webshot.js", package = "webshot"),
    jsonlite::toJSON(optsList)
  )

  res <- phantom_run(args)

  # Handle missing phantomjs
  if (is.null(res)) return(NULL)

  if (res != 0) {
    stop("webshot.js returned failure value: ", res)
  }

  structure(file, class = "webshot")
}

knit_print.webshot <- function(x, ...) {
  lapply(x, function(filename) {
    res <- readBin(filename, "raw", file.size(filename))
    ext <- gsub(".*[.]", "", basename(filename))
    structure(list(image = res, extension = ext), class = "html_screenshot")
  })
}

#' @export
print.webshot <- function(x, ...) {
   invisible(x)
}
