<script lang="ts">
	import { CARDS_MOCK_DATA } from '$lib/mock_data/cards';
	import Card from '$lib/components/card/card.svelte';
	import CardModal from '$lib/components/card_modal/card_modal.svelte';
	import PlusButton from '$lib/components/buttons/plus_button.svelte';

	let openModal = false;
	let currentText = '';
	let currentImage = {};
	let currentSummary = '';
</script>

<div class="w-full h-[100dvh]">
	<div class="max-w-screen-xl mx-auto px-4 py-20">
		<div class="flex flex-row flex-wrap gap-2 justify-center">
			<!-- <button class="btn-primary btn">Add a new note</button> -->

			{#each CARDS_MOCK_DATA as card}
				<button
					on:click={() => {
						openModal = true;
						currentText = card.text;
						currentSummary = card.summary;
						currentImage = card.image;
					}}
					class="w-full sm:w-96"
				>
					<Card text={card.text} />
				</button>
			{/each}
		</div>
		<CardModal
			bind:open={openModal}
			summary={currentSummary}
			image={currentImage}
			text={currentText}
		/>
	</div>
	<div class="fixed lg:hidden block right-6 bottom-[5lvh]">
		<PlusButton />
	</div>
</div>
