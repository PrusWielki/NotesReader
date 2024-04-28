<script>
	import { fade, fly } from 'svelte/transition';
	import notificationMessage from '$lib/store/notification';
	import { notificationType } from '$lib/store/notification';
	let message = '';
	let messageType = 'Success';
	notificationType.subscribe((value) => {
		messageType = value;
	});
	notificationMessage.subscribe((value) => {
		message = value;
	});
</script>

{#if message}
	<div transition:fade class="toast toast-top toast-center top-12 z-50">
		{#if messageType === 'Success'}
			<div class="alert alert-success px-10">
				<p>{message}</p>
			</div>
		{:else if messageType == 'Failure'}
			<div class="alert alert-error px-10">
				<p>{message}</p>
			</div>
		{:else}
			<div class="alert alert-info px-10">
				<p>{message}</p>
			</div>
		{/if}
	</div>
{/if}
