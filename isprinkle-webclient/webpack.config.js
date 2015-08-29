var webpack = require('webpack');
var config = {
    entry: './src/index.jsx',
    output: {
      // Filled in below based on process.env.DEV
    },
    module: {
        loaders: [
            {test: /\.jsx?$/,   loader: 'jsx-loader?insertPragma=React.DOM&harmony'},
            {test: /\.less$/,   loader: 'style-loader!css-loader!less-loader'},
            {test: /\.css/,     loader: 'style-loader!css-loader'},
            {test: /\.woff(\?v=[0-9]\.[0-9]\.[0-9])?$/, loader: "url-loader?limit=10000&minetype=application/font-woff"},
            {test: /\.woff2?$/, loader: "url-loader?limit=10000&minetype=application/font-woff"},
            {test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/, loader: "file-loader"}
        ]
    },
    resolve: {
        extensions: ['', '.js', '.jsx']
    },
    plugins: [
      new webpack.DefinePlugin({
        '__DEV__': process.env.DEV ? true : false
      })
    ]
}

if (process.env.DEV) {
  console.log("Building in dev mode");

  // Enable source maps, but adds 4MB to the output JS bundle:
  config.devtool = "#inline-source-map";

  // URL to serve the dev bundle:
  config.output.publicPath = 'http://localhost:8090/assets';
} else {
  console.log("Building production bundle...");
  config.output.filename = 'build/main.bundle.js';
}

module.exports = config
