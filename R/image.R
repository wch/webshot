#' Resize an image
#'
#' This does not change size of the image in pixels, nor does it affect
#' appearance -- it is lossless compression. This requires GraphicsMagick
#' (recommended) or ImageMagick to be installed.
#'
#' @param filename Name of image to resize.
#' @param geometry Scaling specification. Can be a percent, as in \code{"50\%"},
#'   or pixel dimensions like \code{"120x120"}, \code{"120x"}, or \code{"x120"}.
#'   Any valid ImageMagick geometry specifation can be used.
#'
#' @examples
#' if (interactive()) {
#'   # Can be chained with webshot() or appshot()
#'   webshot("http://www.google.com/", "google-small-1.png") %>%
#'     resize("75%")
#'
#'   # Generate image that is 400 pixels wide
#'   webshot("http://www.google.com/", "google-small-2.png") %>%
#'     resize("400x")
#' }
#' @export
resize <- function(filename, geometry) {
  progs <- Sys.which(c("gm", "convert"))
  if (all(progs == ""))
    stop("Neither `gm` nor `convert` were found in path. GraphicsMagick or ImageMagick must be installed and in path.")

  args <- c(filename, "-resize", geometry, filename)

  if (progs["gm"] != "") {
    prog <- progs["gm"]
    args <- c("convert", args)
  } else {
    prog <- progs["convert"]
  }

  res <- system2(prog, args)

  if (res != 0)
    stop ("Resizing with `gm convert` or `convert` failed.")

  invisible(filename)
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
#' @param filename Name of image to shrink. Must be a PNG file.
#'
#' @examples
#' if (interactive()) {
#'   webshot("http://www.google.com/", "google-shrink.png") %>%
#'     shrink()
#' }
#' @export
shrink <- function(filename) {
  optipng <- Sys.which("optipng")
  if (optipng == "")
    stop("optipng not found in path. optipng must be installed and in path.")

  res <- system2('optipng', filename)

  if (res != 0)
    stop ("Shrinking with `optipng` failed.")

  invisible(filename)
}
