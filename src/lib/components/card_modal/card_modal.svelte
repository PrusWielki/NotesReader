<script lang="ts">
	export let text: string;
	export let open: boolean;

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

<dialog class="backdrop:backdrop-blur-sm" bind:this={dialogRef}>
	<div class="w-full h-full bg-base-300 p-10 max-w-md">
		<p>
			{text}
		</p>
	</div>
</dialog>
