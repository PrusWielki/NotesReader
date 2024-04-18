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
	<div class="w-full fixed top-0 font-montserrat z-10 backdrop-blur-md bg-transparent">
		<div class="navbar max-w-screen-xl mx-auto px-4">
			<div class="navbar-start">
				<div class="dropdown">
					<div tabindex="0" role="button" class="btn btn-ghost lg:hidden">
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
					</div>
					<ul
						tabindex="0"
						class="menu menu-sm dropdown-content mt-3 z-[1] p-2 shadow bg-base-100 rounded-box w-52"
					>
						<li><ThemePicker class="" /></li>
						<li>
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
								class="btn btn-outline btn-secondary btn-sm text-secondary-content">Logout</button
							>
						</li>
						<li><a>Item 3</a></li>
					</ul>
				</div>
				<a href="/" class="btn btn-ghost text-xl font-semibold">Notes Reader</a>
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
								alert('Logout error');
							});
					}}
					class="btn btn-outline btn-secondary btn-sm text-secondary-content">Logout</button
				>
			</div>
		</div>
	</div>
	<slot />
{/if}
