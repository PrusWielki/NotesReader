<script lang="ts">
	export let text: string;
	export let open: boolean;
	export let summary: string = '';
	export let image: any = {};

	let dialogRef: HTMLDialogElement;
	$: {
		if (open && dialogRef) {
			document.getElementsByTagName('body')[0].style.overflow = 'hidden';
			dialogRef.showModal();
		} else if (!open && dialogRef) {
			document.getElementsByTagName('body')[0].style.overflow = 'auto';
			dialogRef.close();
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
					document.getElementsByTagName('body')[0].style.overflow = 'auto';
					dialogRef.close();
				}
			});
		}
	}
</script>

<dialog class=" backdrop:backdrop-blur-sm bg-base-300" bind:this={dialogRef}>
	<div class="w-full prose overflow-auto h-3/4 h-full p-10 max-w-md sm:max-w-xl">
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
