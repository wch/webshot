webshot
=======

[![Travis-CI Build Status](https://travis-ci.org/wch/webshot.svg?branch=master)](https://travis-ci.org/wch/webshot)

**Webshot** makes it easy to take screenshots of web pages from R. It can also run Shiny applications locally and take screenshots of the app.


## Installation

It requires an installation of the external program [PhantomJS](http://phantomjs.org/). Please make sure you have PhantomJS version 2 or higher installed. Previous versions may have trouble rendering some fonts. You may either download PhantomJS from its website, or use the function `webshot::install_phantomjs()` to install it automatically.

Once PhantomJS is installed you can install webshot with:

```R
devtools::install_github("wch/webshot")
```


## Usage

By default, `webshot` will use a 992x744 pixel viewport (a virtual browser window) and take a screenshot of the entire page, even the portion outside the viewport.

```R
library(webshot)
webshot("https://www.r-project.org/", "r.png")
webshot("https://www.r-project.org/", "r.pdf") # Can also output to PDF
```

You can clip it to just the viewport region:

```R
webshot("https://www.r-project.org/", "r-viewport.png", cliprect = "viewport")
```

You can also get screenshots of a portion of a web page using CSS selectors. If there are multiple matches for the CSS selector, it will use the first match.

```R
webshot("https://www.r-project.org/", "r-sidebar.png", selector = ".sidebar")
```

If you supply multiple CSS selectors, it will take a screenshot containing all of the selected items.

```R
webshot("https://www.r-project.org/", "r-selectors.png",
        selector = c("#getting-started", "#news"))
```

The clipping rectangle can be expanded to capture some area outside the selected items:

```R
webshot("https://www.r-project.org/", "r-expand.png",
        selector = "#getting-started",
        expand = c(40, 20, 40, 20))
```


### Screenshots of Shiny applications

The `appshot()` function will run a Shiny app locally in a separate R process, and take a screenshot of it. After taking the screenshot, it will kill the R process that is running the Shiny app.

```R
# Get the directory of one of the Shiny examples
appdir <- system.file("examples", "01_hello", package="shiny")
appshot(appdir, "01_hello.png")
```

### Manipulating images

If you have GraphicsMagick (recommended) or ImageMagick installed, you can pass the result to `resize()` to resize the image after taking the screenshot. This can take any valid ImageMagick geometry specifictaion, like `"75%"`, or `"400x"` (for an image 400 pixels wide).

You can also call `shrink()` function, which runs [OptiPNG](http://optipng.sourceforge.net/) to shrink the PNG file losslessly.

```R
webshot("http://www.google.com/", "google-small.png") %>%
 resize("75%") %>%
 shrink()

webshot("http://www.google.com/", "google-small.png") %>%
 resize("400x") %>%
 shrink()
```
