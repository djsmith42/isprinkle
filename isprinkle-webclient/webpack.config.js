module.exports = {
    entry: './src/index.jsx',
    output: {
        publicPath: 'http://localhost:8090/assets'
    },
    devtool: "#inline-source-map",
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
    }
}
