<script lang="ts">
	import { goto } from '$app/navigation';
	import ThemePicker from '$lib/components/theme_picker/theme_picker.svelte';
	import { getAuth, signOut } from 'firebase/auth';
	import { session } from '$lib/session';

	import ThemePickerSelect from '$lib/components/theme_picker_select/theme_picker_select.svelte';
	import { showNotification } from '$lib/hooks/show-notification';
	import { browser } from '$app/environment';

	let loggedIn = false;
	if (browser)
		session.subscribe((value) => {
			if (value?.loggedIn === false) goto('/');
			else if (value && value.loggedIn === true) loggedIn = true;
		});
	let resultsMenu: HTMLDetailsElement;
	if (browser)
		document.addEventListener('click', function (e) {
			if (resultsMenu && resultsMenu.removeAttribute) resultsMenu.removeAttribute('open');
		});
</script>

{#if loggedIn}
	<div class="w-full fixed top-0 font-montserrat z-10 backdrop-blur-md bg-transparent">
		<div class="navbar max-w-screen-xl mx-auto px-4">
			<div class="navbar-start">
				<details
					class="dropdown"
					on:click={(e) => {
						if (resultsMenu.open) {
							e.stopPropagation();
						}
					}}
					on:keydown={(e) => {
						if (resultsMenu.open) {
							e.stopPropagation();
						}
					}}
					bind:this={resultsMenu}
				>
					<summary tabindex="0" class="btn btn-ghost lg:hidden">
						<svg
							xmlns="http://www.w3.org/2000/svg"
							class="h-5 w-5"
							fill="none"
							viewBox="0 0 24 24"
							stroke="currentColor"
							><path
								stroke-linecap="round"
								stroke-linejoin="round"
								stroke-width="2"
								d="M4 6h16M4 12h8m-8 6h16"
							/></svg
						>
					</summary>
					<ul
						tabindex="0"
						class="menu menu-sm dropdown-content mt-3 z-[1] p-2 shadow gap-4 bg-base-200 rounded-box w-52"
					>
						<li>
							<ThemePickerSelect class="" />
						</li>
						<li>
							<button
								on:click={() => {
									const auth = getAuth();
									signOut(auth)
										.then(() => {
											goto('/');
										})
										.catch((error) => {
											showNotification('Logout Error!', 2000, 'Failure');
										});
								}}
								class="btn btn-ghost btn-secondary btn-sm">Logout</button
							>
						</li>
					</ul>
				</details>
				<a href="/main" class="btn btn-ghost text-xl font-semibold">Notes Reader</a>
				<!-- 				<input
					class="input input-bordered input-secondary block lg:hidden"
					placeholder="search..."
				/> -->
			</div>
			<div class="navbar-center">
				<button
					on:click={() => {
						const element = document.getElementById('fileInput');
						if (element) element.click();
					}}
					class="btn btn-primary hidden lg:block mx-auto">Add a new note</button
				>
			</div>

			<div class="navbar-end hidden lg:flex gap-4">
				<ThemePicker class="" />
				<button
					on:click={() => {
						const auth = getAuth();
						signOut(auth)
							.then(() => {
								goto('/');
							})
							.catch((error) => {
								showNotification('Logout Error!', 2000, 'Failure');
							});
					}}
					class="btn btn-ghost btn-secondary btn-sm">Logout</button
				>
			</div>
		</div>
	</div>
	<slot />
{/if}
