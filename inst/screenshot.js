
// This must be executed with phantomjs
// Take a screenshot of a URL and saves it to a .png file
// phantomjs screenshot.js <url> <filename> [options]

var utils = require('./utils');
var system = require('system');

var opt_defaults = {
  delay: 200
};

// =====================================================================
// Command line arguments
// =====================================================================
var args = system.args;

if (args.length < 3) {
  console.log('Usage:\n' +
    '  phantomjs screenshot.js <url> <name>.png [options]');
}

var url = args[1];
var filename = args[2];
var opts = utils.parseArgs(args.slice(3));
opts = utils.merge(opt_defaults, opts);

// This should be four numbers separated by ","
if (opts.cliprect) {
  opts.cliprect = opts.cliprect.split(",");
}


// =====================================================================
// Screenshot
// =====================================================================
var page = require('webpage').create();

page.viewportSize = {
  width: opts.vwidth,
  height: opts.vheight
};

page.open(url, function() {
  // Delay before taking screenshot
  window.setTimeout(function () {
    page.clipRect = findClipRect(opts, page);
    page.render(filename);
    console.log("Wrote " + filename);
    phantom.exit();
  }, opts.delay);
});


// =====================================================================
// Utility functions
// =====================================================================

// Given the options object, return an object representing the clipping
// rectangle.
function findClipRect(opts, page) {
  if (opts.cliprect) {
    return {
      top:    opts.cliprect[0],
      left:   opts.cliprect[1],
      width:  opts.cliprect[2],
      height: opts.cliprect[3]
    };
  } else if (opts.selector) {
    var cr = page.evaluate(function (s) {
      return document.querySelector(s).getBoundingClientRect();
    }, opts.selector);

    return {
      top:    cr.top,
      left:   cr.left,
      width:  cr.width,
      height: cr.height
    };
  } else {
    return {
      top:    0,
      left:   0,
      width:  opts.vwidth,
      height: opts.vheight
    };
  }
}
