<script lang="ts">
	import { browser } from '$app/environment';
	let className: string;

	export { className as class };
	let theme: string | null;
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
	const themes = ['light', 'dark', 'emerald', 'dim', 'nord', 'dracula', 'fantasy'];
</script>

<div class={`dropdown dropdown-hover ${className}`}>
	<button class="btn btn-neutral btn-xs btn-outline font-bold">Theme</button>
	<ul class="dropdown-content z-30 menu p-2 shadow bg-base-200 rounded-box w-fit">
		{#each themes as themeName}
			<li>
				<button
					class={`${theme === themeName ? 'btn-active' : ''}`}
					on:click={() => onThemeSelect(themeName)}>{themeName}</button
				>
			</li>
		{/each}
	</ul>
</div>
