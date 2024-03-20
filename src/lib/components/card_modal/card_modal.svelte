<script lang="ts">
	export let text: string;
	export let open: boolean;
	export let summary: string = '';
	export let image: any = {};

	let dialogRef: HTMLDialogElement;
	const handleOpenDialog = () => {
		document.getElementsByTagName('body')[0].style.overflow = 'hidden';
		dialogRef.showModal();
	};
	const handleCloseDialog = () => {
		document.getElementsByTagName('body')[0].style.overflow = 'auto';
		dialogRef.close();
	};

	$: {
		if (open && dialogRef) {
			handleOpenDialog();
		} else if (!open && dialogRef) {
			handleCloseDialog();
		}
	}
	$: {
		if (dialogRef) {
			dialogRef.addEventListener('click', function (event) {
				var rect = dialogRef.getBoundingClientRect();
				var isInDialog =
					rect.top <= event.clientY &&
					event.clientY <= rect.top + rect.height &&
					rect.left <= event.clientX &&
					event.clientX <= rect.left + rect.width;
				if (!isInDialog) {
					open = false;
					handleCloseDialog();
				}
			});
		}
	}
</script>

<dialog class="backdrop:backdrop-blur-sm bg-base-300" bind:this={dialogRef}>
	<div class="relative w-full prose overflow-auto h-3/4 h-full p-10 max-w-md sm:max-w-xl">
		<button
			on:click={() => {
				handleCloseDialog();
			}}
			class="absolute cursor-pointer fill-accent w-8 h-8 right-4 top-4"
		>
			<svg role="button" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"
				><g id="SVGRepo_bgCarrier" stroke-width="0"></g><g
					id="SVGRepo_tracerCarrier"
					stroke-linecap="round"
					stroke-linejoin="round"
				></g><g id="SVGRepo_iconCarrier">
					<path
						fill-rule="evenodd"
						clip-rule="evenodd"
						d="M5.29289 5.29289C5.68342 4.90237 6.31658 4.90237 6.70711 5.29289L12 10.5858L17.2929 5.29289C17.6834 4.90237 18.3166 4.90237 18.7071 5.29289C19.0976 5.68342 19.0976 6.31658 18.7071 6.70711L13.4142 12L18.7071 17.2929C19.0976 17.6834 19.0976 18.3166 18.7071 18.7071C18.3166 19.0976 17.6834 19.0976 17.2929 18.7071L12 13.4142L6.70711 18.7071C6.31658 19.0976 5.68342 19.0976 5.29289 18.7071C4.90237 18.3166 4.90237 17.6834 5.29289 17.2929L10.5858 12L5.29289 6.70711C4.90237 6.31658 4.90237 5.68342 5.29289 5.29289Z"
					></path>
				</g></svg
			>
		</button>

		<h2>Summary</h2>
		<p>{summary}</p>
		<h2>Content</h2>
		<p>
			{text}
		</p>
		<h2>Source Image</h2>
		<img src={image} alt="source" />
	</div>
</dialog>
