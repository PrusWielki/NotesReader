<script lang="ts">
	import Card from '$lib/components/card/card.svelte';
	import CardModal from '$lib/components/card_modal/card_modal.svelte';
	import PlusButton from '$lib/components/buttons/plus_button.svelte';
	import { collection, getFirestore, onSnapshot, orderBy, query, where } from 'firebase/firestore';
	import type { QueryDocumentSnapshot, QuerySnapshot } from 'firebase/firestore/lite';
	import { session } from '$lib/session';
	import { app } from '$lib/firebase.client';
	import { onDestroy } from 'svelte';

	let uid: string | null | undefined = null;

	session.subscribe((value) => (uid = value?.user?.uid));
	let db = null;
	let collectionRef = null;

	if (app) {
		db = getFirestore();
		collectionRef = collection(db, 'userData');
	}

	let queryResult: QueryDocumentSnapshot[] | null = null;

	let openModal = false;
	let currentText = '';
	let currentImage = '';
	let currentSummary = '';
	let currentId: string|null = null;
	let unsubscribe: any = null;

	const getData = (uid: string | null | undefined) => {
		if (uid && uid !== '' && collectionRef) {
			const q = query(collectionRef, where('userId', '==', uid), orderBy('date'));
			unsubscribe = onSnapshot(q, (snapshot) => {
				queryResult = snapshot.docs.reverse();
			});
		}
	};

	$: {
		getData(uid);
	}

	onDestroy(() => {
		if (unsubscribe) unsubscribe();
	});
</script>

<div class="w-full h-[100dvh]">
	<div class="max-w-screen-xl mx-auto px-4 py-20">
		<div class="flex flex-row flex-wrap gap-2 justify-center">
			<!-- <button class="btn-primary btn">Add a new note</button> -->
			{#if queryResult}
				{#each queryResult as doc}
					{@const { text, summary, imageName } = doc.data()}

					<button
						on:click={() => {
							openModal = false;
							openModal = true;
							currentText = text;
							currentSummary = summary;
							currentImage = imageName;
							currentId = doc.id;
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
			docId={currentId}
		/>
	</div>
	<div class="fixed lg:hidden block right-6 bottom-[5lvh]">
		<PlusButton/>
	</div>
</div>
