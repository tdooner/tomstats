const webpack = require('webpack');
const AssetsPlugin = require('assets-webpack-plugin');

module.exports = {
  context: __dirname,
  entry: {
    DateHistogram: './web/DateHistogram.js',
    Notifier: './web/Notifier.js',
    NotifierServiceWorker: './web/Notifier-ServiceWorker.js'
  },
  output: {
    path: __dirname + '/build/js',
    filename: "[name]-[chunkhash].bundle.js",
  },
  plugins: [
    new webpack.DefinePlugin({
      // TODO: extract this somewhere common
      'process.env.VAPID_PUBLIC_KEY_BYTES': JSON.stringify([
        4, 128, 19, 128, 115, 112, 130, 150, 99, 59, 240, 229, 79, 127, 229,
        236, 8, 140, 121, 245, 227, 15, 185, 223, 207, 167, 92, 106, 27, 251,
        46, 243, 142, 4, 209, 161, 47, 249, 226, 124, 85, 224, 167, 201, 134,
        126, 111, 230, 19, 19, 221, 64, 60, 248, 123, 73, 82, 97, 192, 141, 0,
        211, 177, 243, 68
      ]),
    }),
    new AssetsPlugin({ filename: 'build/assets.json' }),
  ],
};
