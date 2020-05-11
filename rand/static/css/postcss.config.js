

module.exports = {
  plugins: [
    require('postcss-import')({
      path: ["static/css"],
    }),
    require('tailwindcss')('./static/css/tailwind.config.js'),
    require('autoprefixer')({
      grid: true,
      overrideBrowserslist: ['>1%']
    }),
  ]
}
