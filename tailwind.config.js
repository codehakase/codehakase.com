/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./content/**/*.{html,md}",
    "./layouts/**/*.html",
    "./themes/clean/layouts/**/*.html",
    "./themes/clean/layouts/partials/**/*.html"
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['"Anonymous Pro"', 'monospace'],
      },
      fontSize: {
        base: ['1em', { lineHeight: '2' }],
        'h1': ['2em', { lineHeight: '1.4' }],
        'h2': ['1.75em', { lineHeight: '1.5' }],
        'h3': ['1.5em', { lineHeight: '1.5' }],
        'h4': ['1.17em', { lineHeight: '1.5' }],
        'h5': ['1.1em', { lineHeight: '1.5' }],
      },
      colors: {
        'code-bg': '#f7f6eb',
        'code-text': '#689d6a',
      },
      padding: {
        'code': '1.25rem',
      },
      lineHeight: {
        'code': '1.75',
      },
    },
  },
  plugins: [
    require('@tailwindcss/typography'),
    require('@tailwindcss/line-clamp')
  ],
}
