<script lang="ts">
	import { CARDS_MOCK_DATA } from '$lib/mock_data/cards';
	import Card from '$lib/components/card/card.svelte';
	import CardModal from '$lib/components/card_modal/card_modal.svelte';
	import { text } from '@sveltejs/kit';
	let openModal = false;
	let currentText = '';
</script>

<div class="w-full h-[100dvh]">
	<div class="max-w-screen-xl mx-auto px-4 py-20">
		<div class="flex flex-row flex-wrap gap-8 justify-center sm:justify-start">
			{#each CARDS_MOCK_DATA as card}
				<button
					on:click={() => {
						openModal = true;
						currentText = card.text;
					}}
					class="w-full sm:w-96"
				>
					<Card text={card.text} />
				</button>
			{/each}
		</div>
		<CardModal bind:open={openModal} text={currentText} />
	</div>
</div>
