/** @type {import('tailwindcss').Config} */
module.exports = {
	content: ['./src/**/*.{html,js,svelte,ts}'],
	theme: {
		extend: {}
	},
	daisyui: {
		themes: ['light', 'dark', 'emerald', 'dim', 'nord', 'dracula', 'fantasy'],
		darkTheme: 'dracula',
		lightTheme: 'fantasy'
	},
	plugins: [require('@tailwindcss/typography'), require('daisyui')]
};
