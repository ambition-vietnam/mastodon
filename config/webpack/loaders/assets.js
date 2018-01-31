const { env, publicPath, version } = require('../configuration.js');

module.exports = {
  test: /\.(jpg|jpeg|png|gif|svg|eot|ttf|woff|woff2)$/i,
  use: [{
    loader: 'file-loader',
    options: {
      publicPath,
      name: env.NODE_ENV === 'production' ? `[name]-${version}.[ext]` : '[name].[ext]',
    },
  }],
};
