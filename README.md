webshot
=======

**Webshot** makes it easy to take screenshots of web pages from R. It can also run Shiny applications locally and take screenshots of the app.


## Installation

It requires an installation of the external program [PhantomJS](http://phantomjs.org/). If you're on a Mac, the widely used Font Awesome icons [may not render properly](https://github.com/ariya/phantomjs/issues/12132) unless you install the .ttf font [from here](http://fortawesome.github.io/Font-Awesome/).

Once PhantomJS is installed you can install webshot with:

```R
devtools::install_github("wch/webshot")
```


## Usage

By default, `webshot` will use a 920x600 pixel viewport (a virtual browser window) and take a screenshot of the entire page, even the portion outside the viewport:

```R
library(webshot)
webshot("http://www.rstudio.com/", "rstudio.png")
```

You can also clip it to just the viewport region:

```R
webshot("http://www.rstudio.com/", "rstudio-viewport.png", cliprect = "viewport")
```

You can also get screenshots of a portion of a web page using CSS selectors. If there are multiple matches for the CSS selector, it will use the first match.

```R
webshot("http://www.rstudio.com/", "rstudio-header.png", selector = "#header")
```

The `appshot()` function will run a Shiny app locally in a separate R process, and take a screenshot of it. After taking the screenshot, it will kill the R process that is running the Shiny app.

```R
# Get the directory of one of the Shiny examples
appdir <- system.file("examples", "01_hello", package="shiny")
appshot(appdir, "01_hello.png")
```
