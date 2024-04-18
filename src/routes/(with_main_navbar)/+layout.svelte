<script lang="ts">
	import { goto } from '$app/navigation';
	import ThemePicker from '$lib/components/theme_picker/theme_picker.svelte';
	import { getAuth, signOut } from 'firebase/auth';
	import { onMount } from 'svelte';

	import type { LayoutData } from './$types';
	export let data: LayoutData;
	let loggedIn = false;

	onMount(async () => {
		const user: any = await data.getAuthUser();

		loggedIn = !!user && user?.emailVerified;

		if (!loggedIn) {
			goto('/');
		}
	});
</script>

{#if loggedIn === true}
	<nav class="w-full fixed top-0 font-montserrat z-10 backdrop-blur-md bg-transparent">
		<div class="navbar max-w-screen-xl mx-auto px-4">
			<div class="navbar-start">
				<a href="/" class="btn btn-ghost text-xl font-semibold">Notes Reader</a>
			</div>

			<div class="navbar-end gap-4">
				<ThemePicker class="" />
				<button
					on:click={() => {
						const auth = getAuth();
						signOut(auth)
							.then(() => {
								goto('/');
							})
							.catch((error) => {
								alert('Logout error');
							});
					}}
					class="btn btn-outline btn-secondary btn-sm text-primary-content">Logout</button
				>
			</div>
		</div>
	</nav>
	<slot />
{/if}
