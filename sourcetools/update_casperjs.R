#!/usr/bin/env Rscript

# This script copies resources from casperjs to this project's inst
# directory. The casperjs/ project directory should be on the same level
# as the webshot/ project directory.

# This script can be sourced from RStudio, or run with Rscript.

# Returns the file currently being sourced or run with Rscript
thisFile <- function() {
  cmdArgs <- commandArgs(trailingOnly = FALSE)
  needle <- "--file="
  match <- grep(needle, cmdArgs)
  if (length(match) > 0) {
    # Rscript
    return(normalizePath(sub(needle, "", cmdArgs[match])))
  } else {
    # 'source'd via R console
    return(normalizePath(sys.frames()[[1]]$ofile))
  }
}

srcdir <- file.path(dirname(thisFile()), "../../casperjs")
destdir <- file.path(dirname(thisFile()), "../inst/casperjs")

file.copy(file.path(srcdir, "package.json"), destdir)
file.copy(file.path(srcdir, "bin/bootstrap.js"), file.path(destdir, "bin"))
file.copy(file.path(srcdir, "modules"), destdir, recursive = TRUE)
