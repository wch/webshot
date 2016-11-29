#' Resize an image
#'
#' This does not change size of the image in pixels, nor does it affect
#' appearance -- it is lossless compression. This requires GraphicsMagick
#' (recommended) or ImageMagick to be installed.
#'
#' @param filename Character vector containing the path of images to resize.
#' @param geometry Scaling specification. Can be a percent, as in \code{"50\%"},
#'   or pixel dimensions like \code{"120x120"}, \code{"120x"}, or \code{"x120"}.
#'   Any valid ImageMagick geometry specifation can be used. If \code{filename}
#'   contains multiple images, this can be a vector to specify distinct sizes
#'   for each image.
#'
#' @examples
#' if (interactive()) {
#'   # Can be chained with webshot() or appshot()
#'   webshot("https://www.r-project.org/", "r-small-1.png") %>%
#'     resize("75%")
#'
#'   # Generate image that is 400 pixels wide
#'   webshot("https://www.r-project.org/", "r-small-2.png") %>%
#'     resize("400x")
#' }
#' @export
resize <- function(filename, geometry) {
  mapply(resize_one, filename = filename, geometry = geometry,
         SIMPLIFY = FALSE, USE.NAMES = FALSE)
  structure(filename, class = "webshot")
}

resize_one <- function(filename, geometry) {
  # Handle missing phantomjs
  if (is.null(filename)) return(NULL)

  # First look for graphicsmagick, then imagemagick
  prog <- Sys.which("gm")

  if (prog == "") {
    # ImageMagick 7 has a "magick" binary
    prog <- Sys.which("magick")
  }

  if (prog == "") {
    if (is_windows()) {
      prog <- find_magic()
    } else {
      prog <- Sys.which("convert")
    }
  }

  if (prog == "")
    stop("None of `gm`, `magick`, or `convert` were found in path. GraphicsMagick or ImageMagick must be installed and in path.")

  args <- c(filename, "-resize", geometry, filename)

  if (names(prog) %in% c("gm", "magick")) {
    args <- c("convert", args)
  }

  res <- system2(prog, args)

  if (res != 0)
    stop ("Resizing with `gm convert`, `magick convert` or `convert` failed.")

  filename
}

#' Shrink file size of a PNG
#'
#' This does not change size of the image in pixels, nor does it affect
#' appearance -- it is lossless compression. This requires the program
#' \code{optipng} to be installed.
#'
#' If other operations like resizing are performed, shrinking should occur as
#' the last step. Otherwise, if the resizing happens after file shrinking, it
#' will be as if the shrinking didn't happen at all.
#'
#' @param filename Character vector containing the path of images to resize.
#'   Must be PNG files.
#'
#' @examples
#' if (interactive()) {
#'   webshot("https://www.r-project.org/", "r-shrink.png") %>%
#'     shrink()
#' }
#' @export
shrink <- function(filename) {
  mapply(shrink_one, filename = filename, SIMPLIFY = FALSE, USE.NAMES = FALSE)
  structure(filename, class = "webshot")
}

shrink_one <- function(filename) {
  # Handle missing phantomjs
  if (is.null(filename)) return(NULL)

  optipng <- Sys.which("optipng")
  if (optipng == "")
    stop("optipng not found in path. optipng must be installed and in path.")

  res <- system2('optipng', filename)

  if (res != 0)
    stop ("Shrinking with `optipng` failed.")

  filename
}
