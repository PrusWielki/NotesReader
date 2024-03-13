/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/**/*.{html,ts}"],
  theme: {
    extend: {},
  },
  daisyui: {
    themes: ["dracula", "fantasy"],
    darkTheme: "dracula",
    lightTheme: "fantasy",
  },
  plugins: [require("@tailwindcss/typography"), require("daisyui")],
};
