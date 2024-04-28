<script lang="ts">
	import '../app.css';
	import { onMount } from 'svelte';
	import { session } from '$lib/session';
	import { goto } from '$app/navigation';
	import Toast from '$lib/components/toast/toast.svelte';

	import type { LayoutData } from './$types';
	export let data: LayoutData;

	let loading: boolean = true;
	let loggedIn: boolean = false;
	let uid: string | null = null;

	session.subscribe((cur: any) => {
		loading = cur?.loading;
		loggedIn = cur?.loggedIn;
		uid = cur?.user.uid;
	});

	onMount(async () => {
		const user: any = await data.getAuthUser();

		const loggedIn = !!user; //&& user?.emailVerified;
		session.update((cur: any) => {
			loading = false;
			return {
				...cur,
				user,
				loggedIn,
				loading: false
			};
		});

		if (loggedIn && uid) {
			goto('/main');
		}
	});
</script>

<Toast />
<slot />
