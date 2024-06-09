<script lang="ts">
	import { browser } from '$app/environment';
	import { themes } from '$lib/consts/consts';
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
</script>

<div class={`dropdown dropdown-hover ${className}`}>
	<button
		class="btn btn-neutral fill-base-content btn-sm btn-ghost font-semibold flex flex-nowrap items-center justify-center"
		>Theme <svg
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
		></button
	>
	<ul
		class="dropdown-content z-30 menu p-2 shadow bg-base-200 rounded-box w-fit overflow-x-hidden overflow-y-auto leanscroll flex-nowrap max-h-[50vh]"
	>
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
