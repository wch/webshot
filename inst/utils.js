// Given an array of arguments like:
//   [ '--vwidth=800','--vheight=600','--cliprect=0,0,800,600' ]
// return an object like:
// { vwidth: '800', vheight: '600', cliprect: '0,0,800,600' }
exports.parseArgs = function(args) {
  opts = {};

  args.forEach(function(arg) {
    arg = arg.replace(/^--/, "");
    arg = arg.split(/=(.*)/, 2);
    // console.log(arg)
    opts[arg[0]] = arg[1];
  });

  return opts;
};

// Merge properties from object b into object a
exports.merge = function(a, b) {
  var c = {};
  for (var i in b) {
    a[i] = b[i];
  }
  return a;
};
