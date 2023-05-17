/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./src/**/*.{html,svelte}'],
  theme: {
    extend: {
      colors: {
        red: '#00b2ff',
        'warning-red': '#f70f0f',
      },
      fontSize: {
        '2xs': '10px',
      },
    },
  },
  plugins: [],
};
