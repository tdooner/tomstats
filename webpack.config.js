module.exports = {
  context: __dirname,
  entry: {
    DateHistogram: './web/DateHistogram.js'
  },
  output: {
    path: __dirname + '/build/js',
    filename: "[name].bundle.js",
  },
};
