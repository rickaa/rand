const purgecss = require("@fullhuman/postcss-purgecss");

module.exports = {
    plugins: [
        require('postcss-import')({
            path: ["assets/css"],
        }),
        require('tailwindcss')('./assets/css/tailwind.config.js'),
        require('autoprefixer')({
            overrideBrowserslist: ['>1%']
        }),
        require('postcss-preset-env')({stage: 1}),
        require('postcss-nested'),
    ]
}
