class TailwindExtractor {
	static extract(content) {
		return content.match(/[A-z0-9-:\/]+/g)
	}
}

module.exports = {
  plugins: [
    require('postcss-import')({
      path: ["static/css"],
    }),
    require('tailwindcss')('./static/css/tailwind.js'),
    require('autoprefixer')({
      grid: true,
      browsers: ['>1%']
    }),
  ]
}