// Given an array of arguments like:
//   [ '--vwidth=800','--vheight=600','--cliprect=0,0,800,600' ]
// return an object like:
// { vwidth: '800', vheight: '600', cliprect: '0,0,800,600' }
exports.parseArgs = function(args) {
  opts = {};

  args.forEach(function(arg) {
    arg = arg.replace(/^--/, "");

    var eq_idx = arg.indexOf("=");
    var argname = arg.substring(0, eq_idx);
    var argvalue = arg.substring(eq_idx + 1);

    opts[argname] = argvalue;
  });

  return opts;
};

// Merge properties from object b into object a
exports.merge = function(a, b) {
  for (var i in b) {
    if (b.hasOwnProperty(i))
      a[i] = b[i];
  }
  return a;
};
