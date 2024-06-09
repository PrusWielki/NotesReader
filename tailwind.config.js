/** @type {import('tailwindcss').Config} */
module.exports = {
	
	content: ['./src/**/*.{html,js,svelte,ts}'],
	theme: {
		extend: {
			fontFamily: {
				manrope: 'Manrope',
				inter: 'Inter',
				montserrat: 'Montserrat',
				poppins: 'Poppins'
			}
		}
	},
	daisyui: {
		themes: [
			'light',
			'dark',
			'cupcake',
			'bumblebee',
			'emerald',
			'corporate',
			'synthwave',
			'retro',
			'cyberpunk',
			'valentine',
			'halloween',
			'garden',
			'forest',
			'aqua',
			'lofi',
			'pastel',
			'fantasy',
			'wireframe',
			'black',
			'luxury',
			'dracula',
			'cmyk',
			'autumn',
			'business',
			'acid',
			'lemonade',
			'night',
			'coffee',
			'winter',
			'dim',
			'nord',
			'sunset'
		],
		darkTheme: 'dracula',
		lightTheme: 'fantasy'
	},
	plugins: [require('@tailwindcss/typography'), require('daisyui')]
};
