<script lang="ts">
	import { browser } from '$app/environment';
	import { themes } from '$lib/consts/consts';
	let className: string;

	export { className as class };
	let theme: string | null = '';
	if (browser) {
		theme = localStorage.getItem('theme');
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

<select
	class={`input input-primary input-sm ${className}`}
	bind:value={selectedTheme}
	on:change={() => {
		if (selectedTheme) onThemeSelect(selectedTheme);
	}}
>
	{#each themes as themeName}
		<option class="bg-base-100" value={themeName}>{themeName}</option>
	{/each}
</select>
