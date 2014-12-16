
// This must be executed with phantomjs
// Take a screenshot of a URL and saves it to a .png file
// phantomjs screenshot.js <url> <filename> [options]

var utils = require('./utils');

var system = require('system');
var args = system.args;

if (args.length < 3) {
  console.log('Usage:\n' +
    '  phantomjs screenshot.js <url> <name>.png [options]');
}

var url = args[1];
var filename = args[2];
var opts = utils.parseArgs(args.slice(3));

var page = require('webpage').create();

page.viewportSize = {
  width: opts.vwidth,
  height: opts.vheight
};

page.open(url, function() {
  // Delay 200ms before taking screenshot
  window.setTimeout(function () {
    page.clipRect = findClipRect(opts);
    page.render(filename);
    phantom.exit();
  }, 200);
});


// Given the options object, return an object representing the clipping
// rectangle.
function findClipRect(opts) {
  if (opts.cliprect) {
    return {
      top:    opts.cliprect[0],
      left:   opts.cliprect[1],
      width:  opts.cliprect[2],
      height: opts.cliprect[3]
    };
  } else if (opts.selector) {
    var cr = document.querySelector(opts.selector).getBoundingClientRect();
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
