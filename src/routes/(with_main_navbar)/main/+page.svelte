<script lang="ts">
	import { CARDS_MOCK_DATA } from '$lib/mock_data/cards';
	import Card from '$lib/components/card/card.svelte';
</script>

<div class="w-full h-[100dvh]">
	<div class="max-w-screen-xl mx-auto px-4 py-20">
		<div class="flex flex-row flex-wrap gap-8 justify-center sm:justify-start">
			{#each CARDS_MOCK_DATA as card}
				<div class="w-full sm:w-96">
					<Card text={card.text} />
				</div>
			{/each}
		</div>
	</div>
</div>
