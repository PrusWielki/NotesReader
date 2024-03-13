/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/**/*.{html,ts}"],
  theme: {
    extend: {},
  },
  daisyui: {
    themes: ["forest", "fantasy"],
  },
  plugins: [require("@tailwindcss/typography"), require("daisyui")],
};
