
// This must be executed with phantomjs
// Take a screenshot of a URL and saves it to a .png file
// phantomjs webshot.js <url> <filename> [options]

var utils = require('./utils');
var system = require('system');

phantom.casperPath = phantom.libraryPath + '/casperjs';
phantom.injectJs(phantom.casperPath + '/bin/bootstrap.js');
var casper = require('casper').create();

var opt_defaults = {
  delay: 0.2,
  vwidth: 992,
  vheight: 744
};

// =====================================================================
// Command line arguments
// =====================================================================
var args = system.args;

if (args.length < 3) {
  console.log('Usage:\n' +
    '  phantomjs webshot.js <url> <name>.png [options]');
  phantom.exit(1);
}

var url = args[1];
var filename = args[2];
var opts = utils.parseArgs(args.slice(3));
opts = utils.merge(opt_defaults, opts);

// These should be numbers
if (opts.vwidth)  opts.vwidth  = +opts.vwidth;
if (opts.vheight) opts.vheight = +opts.vheight;
if (opts.delay)   opts.delay = +opts.delay;

// This should be four numbers separated by ","
if (opts.cliprect) {
  opts.cliprect = opts.cliprect.split(",");
  opts.cliprect = opts.cliprect.map(function(x) { return +x; });
}

// Can be 1 or 4 numbers separated by ","
if (opts.expand) {
  opts.expand = opts.expand.split(",");
  opts.expand = opts.expand.map(function(x) { return +x; });
  if (opts.expand.length !== 1 && opts.expand.length !== 4) {
    console.log("'expand' must have either 1 or 4 values.");
    phantom.exit(1);
  }
}

// Can have multiple selectors
if (opts.selector) {
  opts.selector = opts.selector.split(",");
}

// =====================================================================
// Screenshot
// =====================================================================
casper.start(url).viewport(opts.vwidth, opts.vheight);

if (opts.delay > 0)
  casper.wait(opts.delay * 1000);

if (opts.eval) {
  eval(opts.eval);
}

casper.then(function() {
  var cr = findClipRect(opts, this);
  this.capture(filename, cr);
});

casper.run();


// =====================================================================
// Utility functions
// =====================================================================

// Given the options object, return an object representing the clipping
// rectangle. If opts.cliprect and opts.selector are both not present,
// return null.
function findClipRect(opts, casper) {
  // Convert top,right,bottom,left object to top,left,width,height
  function rel2abs(r) {
    return {
      top:    r.top,
      left:   r.left,
      bottom: r.top + r.height,
      right:  r.left + r.width
    };
  }
  // Convert top,left,width,height object to top,right,bottom,left
  function abs2rel(r) {
    return {
      top:    r.top,
      left:   r.left,
      width:  r.right - r.left,
      height: r.bottom - r.top
    };
  }

  var rect;

  if (opts.cliprect) {
    rect = {
      top:    opts.cliprect[0],
      left:   opts.cliprect[1],
      width:  opts.cliprect[2],
      height: opts.cliprect[3]
    };

  } else if (opts.selector) {
    var selector = opts.selector;

    // Get bounds, in absolute coordinates so that we can find a bounding
    // rectangle around multiple items.
    var bounds = selector.map(function(s) {
      var b = casper.getElementBounds(s);
      return rel2abs(b);
    });

    // Get bounding rectangle around multiple
    bounds = bounds.reduce(function(a, b) {
      return {
        top:    Math.min(a.top, b.top),
        left:   Math.min(a.left, b.left),
        bottom: Math.max(a.bottom, b.bottom),
        right:  Math.max(a.right, b.right)
      };
    });

    // Convert back to width + height format
    rect = abs2rel(bounds);

  } else {
    return null;
  }

  // Expand clipping rectangle
  if (opts.expand) {
    var expand = opts.expand;
    if (expand.length === 1) {
      expand = [expand[0], expand[0], expand[0], expand[0]];
    }

    rect = rel2abs(rect);
    rect.top    -= expand[0];
    rect.right  += expand[1];
    rect.bottom += expand[2];
    rect.left   -= expand[3];
    rect = abs2rel(rect);
  }

  return rect;
}


// Exit on error, instead of just hanging
phantom.onError = function(msg, trace) {
  var msgStack = ['PHANTOM ERROR: ' + msg];
  if (trace && trace.length) {
    msgStack.push('TRACE:');
    trace.forEach(function(t) {
      msgStack.push(' -> ' + (t.file || t.sourceURL) + ': ' + t.line + (t.function ? ' (in function ' + t.function +')' : ''));
    });
  }
  console.log(msgStack.join('\n'));
  phantom.exit(1);
};
