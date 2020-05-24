const purgecss = require("@fullhuman/postcss-purgecss");

module.exports = {
    plugins: [
        require('postcss-import')({
            path: ["assets/css"],
        }),
        require('tailwindcss')('./assets/css/tailwind.config.js'),
        require('autoprefixer')({
            grid: true,
            overrideBrowserslist: ['>1%']
        }),
        purgecss({
            content: [
                "./layouts/**/*.html"
            ],
            defaultExtractor: content => content.match(/[\w-/.:]+(?<!:)/g) || []
            // defaultExtractor: content => content.match(/[\w-/:]+(?<!:)/g) || []
        }),
        require("postcss-preset-env")
    ]
}
