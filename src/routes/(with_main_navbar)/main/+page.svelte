<script lang="ts">
	import Card from '$lib/components/card/card.svelte';
	import CardModal from '$lib/components/card_modal/card_modal.svelte';
	import PlusButton from '$lib/components/buttons/plus_button.svelte';
	import { collection, getFirestore, onSnapshot, query, where } from 'firebase/firestore';
	import type { QuerySnapshot } from 'firebase/firestore/lite';
	import type { PageData } from './$types';
	import type { User } from 'firebase/auth';

	export let data: PageData;

	let uid: string = '';

	data.getAuthUser().then((result) => (uid = (result as User).uid));

	const db = getFirestore();
	const collectionRef = collection(db, 'userData');

	let queryResult: QuerySnapshot | null = null;

	let openModal = false;
	let currentText = '';
	let currentImage = '';
	let currentSummary = '';

	const getData = (uid: string) => {
		if (uid !== '') {
			const q = query(collectionRef, where('userId', '==', uid));
			const unsubscribe = onSnapshot(q, (snapshot) => {
				queryResult = snapshot;
			});
		}
	};

	$: {
		getData(uid);
	}
</script>

<div class="w-full h-[100dvh]">
	<div class="max-w-screen-xl mx-auto px-4 py-20">
		<div class="flex flex-row flex-wrap gap-2 justify-center">
			<!-- <button class="btn-primary btn">Add a new note</button> -->
			{#if queryResult}
				{#each queryResult.docs as doc}
					{@const { text, summary, imageName } = doc.data()}

					<button
						on:click={() => {
							openModal = true;
							currentText = text;
							currentSummary = summary;
							currentImage = imageName;
						}}
						class="w-full sm:w-96"
					>
						<Card {text} />
					</button>
				{/each}
			{/if}
		</div>
		<CardModal
			bind:open={openModal}
			summary={currentSummary}
			image={currentImage}
			text={currentText}
		/>
	</div>
	<div class="fixed lg:hidden block right-6 bottom-[5lvh]">
		<PlusButton {uid} />
	</div>
</div>
