webshot 0.4.0.9000
==================


webshot 0.4.0
==================

* `webshot`, `resize`, and `shrink` all now accept a vector of URLs or filenames. (([#32](https://github.com/wch/webshot/pull/32)), [#33](https://github.com/wch/webshot/pull/33))

* Updated to CasperJS 1.1.3.

* Added `zoom` option for higher-resolution screen shots. ([#26](https://github.com/wch/webshot/issues/26))

* `webshot()` now returns objects with class `webshot`. There is also a new `knit_print` method for `webshot` objects. ([#27](https://github.com/wch/webshot/pull/27))

* Fixed problem installing PhantomJS on R 3.3.2 and above. ([#35](https://github.com/wch/webshot/pull/35))

webshot 0.3.2
=============

* Better handling of local paths in Windows. ([#23](https://github.com/wch/webshot/issues/23))

* More robust searching for ImageMagick. ([#13](https://github.com/wch/webshot/issues/13))

webshot 0.3.1
=============

* The leading tilde in the path of PhantomJS is expanded now ([#19](https://github.com/wch/webshot/issues/19)).

* Changed URL for PhantomJS binaries so that `install_phantomjs()` doesn't hit rate limits, and added workaround for downloading problems with R 3.3.0 and 3.3.1.

webshot 0.3
===========

* The first CRAN release. Provided functions `webshot()`/`appshot()` to take screenshots via PhantomJS, and `resize()`/`shrink()` to manipulate images via GraphicsMagick/ImageMagick and OptiPNG.
