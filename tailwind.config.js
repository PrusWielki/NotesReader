/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/**/*.{html,ts}"],
  theme: {
    extend: {},
  },
  daisyui: {
    themes: false,
    darkTheme: "forest",
    lightTheme: "fantasy",
  },
  plugins: [require("@tailwindcss/typography"), require("daisyui")],
};
