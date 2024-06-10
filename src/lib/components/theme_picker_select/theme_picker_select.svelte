<script lang="ts">
	import { browser } from '$app/environment';
	import { themes } from '$lib/consts/consts';
	let className: string;

	export { className as class };
	let theme: string | null = 'theme';
	if (browser) {
		const tempTheme = localStorage.getItem('theme');
		if (tempTheme) theme = tempTheme;
	}
	const onThemeSelect = (selected: string) => {
		theme = selected;
		localStorage.setItem('theme', theme);
	};
	$: if (browser && theme) {
		let documentHtml = document.querySelector('html');
		if (documentHtml) documentHtml.setAttribute('data-theme', theme);
	}
	let selectedTheme = theme;
</script>

<div class="relative w-full h-full btn btn-neutral btn-ghost btn-sm active:focus:scale-100  active:hover:scale-100">
	<select
		class={`appearance-none absolute btn w-full h-full  btn-neutral btn-ghost btn-sm active:focus:scale-100  active:hover:scale-100 ${className}`}
		bind:value={selectedTheme}
		on:change={() => {
			if (selectedTheme) onThemeSelect(selectedTheme);
		}}
	>
		<option class="bg-base-100" disabled value="theme">Theme</option>

		{#each themes as themeName}
			<option class="bg-base-100" value={themeName}>{themeName}</option>
		{/each}
	</select>
	<div class="absolute right-2 fill-neutral-content">
		<svg
			height="8px"
			width="8px"
			version="1.1"
			id="Layer_1"
			xmlns="http://www.w3.org/2000/svg"
			xmlns:xlink="http://www.w3.org/1999/xlink"
			viewBox="0 0 407.437 407.437"
			xml:space="preserve"
			><g id="SVGRepo_bgCarrier" stroke-width="0"></g><g
				id="SVGRepo_tracerCarrier"
				stroke-linecap="round"
				stroke-linejoin="round"
			></g><g id="SVGRepo_iconCarrier">
				<polygon
					points="386.258,91.567 203.718,273.512 21.179,91.567 0,112.815 203.718,315.87 407.437,112.815 "
				></polygon>
			</g></svg
		>
	</div>
</div>
