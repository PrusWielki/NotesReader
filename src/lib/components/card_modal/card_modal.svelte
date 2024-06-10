<script lang="ts">
	import { getStorage, ref, getBytes, deleteObject } from 'firebase/storage';
	import { app } from '$lib/firebase.client';
	import { browser } from '$app/environment';
	import { doc, deleteDoc, getFirestore } from 'firebase/firestore';
	import { showNotification } from '$lib/hooks/show-notification';

	let { text = '', open = $bindable(), summary = '', image = '', docId = null } = $props();

	let dialogRef: HTMLDivElement;
	let imageSource: any = $state(null);
	let loading: boolean = $state(true);
	let failed: boolean = $state(false);
	let resultsMenu: HTMLDetailsElement;

	function _arrayBufferToBase64(buffer: ArrayBuffer) {
		var binary = '';
		var bytes = new Uint8Array(buffer);
		var len = bytes.byteLength;
		for (var i = 0; i < len; i++) {
			binary += String.fromCharCode(bytes[i]);
		}
		return window.btoa(binary);
	}
	let storage = null;
	if (app) storage = getStorage();

	const getImage = (image: string) => {
		if (image && storage) {
			const pathReference = ref(storage, image);
			getBytes(pathReference)
				.then((res) => {
					imageSource = 'data:image/jpg;base64, ' + _arrayBufferToBase64(res);
					failed = false;
					loading = false;
				})
				.catch(() => {
					failed = true;
					loading = false;
				});
		}
	};

	const handleOpenDialog = () => {
		document.getElementsByTagName('body')[0].style.overflow = 'hidden';
		open = true;
	};
	const handleCloseDialog = () => {
		document.getElementsByTagName('body')[0].style.overflow = 'auto';
		open = false;
	};
	$effect(() => {
		open;
		imageSource = null;
		loading = true;

		if (image) getImage(image);
	});

	$effect(() => {
		if (open && dialogRef) {
			handleOpenDialog();
		} else if (!open && dialogRef) {
			loading = true;
			handleCloseDialog();
		}
	});

	$effect(() => {
		if (dialogRef) {
			dialogRef.addEventListener('click', function (event) {
				var rect = dialogRef.getBoundingClientRect();
				var isInDialog =
					rect.top <= event.clientY &&
					event.clientY <= rect.top + rect.height &&
					rect.left <= event.clientX &&
					event.clientX <= rect.left + rect.width;
				if (!isInDialog) {
					handleCloseDialog();
				}
			});
		}
	});
	$effect(() => {
		if (browser)
			document.addEventListener('click', function (e) {
				if (resultsMenu && resultsMenu.removeAttribute) resultsMenu.removeAttribute('open');
			});
	});
</script>

<div
	class={`fixed w-[100vw] h-[100vh]  bg-black-200 z-20 left-0 top-0 opacity-60 backdrop-blur-lg ${open ? 'block' : 'hidden'}`}
></div>
<div
	bind:this={dialogRef}
	class={`bg-base-300 sm:h-3/4 h-full sm:max-w-2xl rounded-box w-full sm:w-3/4 h-full sm:h-3/4 fixed left-1/2 top-1/2 -translate-x-1/2 z-30 -translate-y-1/2 ${open ? 'block' : 'hidden'}`}
>
	<div class="relative w-full h-full py-10">
		<button
			on:click={() => {
				handleCloseDialog();
			}}
			class="absolute cursor-pointer fill-primary w-8 h-8 right-3 top-2 btn btn-ghost p-0"
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

		<div class="absolute cursor-pointer w-6 h-6 right-4 top-14">
			<!-- svelte-ignore a11y-no-noninteractive-element-interactions -->
			<details
				class="dropdown dropdown-end w-full h-full"
				on:click={(e) => {
					if (resultsMenu.open) {
						e.stopPropagation();
					}
				}}
				on:keydown={(e) => {
					if (resultsMenu.open) {
						e.stopPropagation();
					}
				}}
				bind:this={resultsMenu}
			>
				<summary tabindex="0" class="w-full fill-primary h-full btn btn-ghost p-0">
					<svg viewBox="0 0 16 16" class="h-5 w-5" xmlns="http://www.w3.org/2000/svg"
						><g id="SVGRepo_bgCarrier" stroke-width="0"></g><g
							id="SVGRepo_tracerCarrier"
							stroke-linecap="round"
							stroke-linejoin="round"
						></g><g id="SVGRepo_iconCarrier">
							<path
								d="M9.5 13a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0zm0-5a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0zm0-5a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0z"
							></path>
						</g></svg
					>
				</summary>
				<ul class="dropdown-content menu">
					<li>
						<button
							on:click={async () => {
								if(docId)
								{
									open = false;
									handleCloseDialog();
									let db = getFirestore();
									deleteDoc(doc(db, 'userData', docId as string))
										.then(() => {
											let pathReference = null;
											if (storage) {
												pathReference = ref(storage, image);
												if (pathReference) {
													deleteObject(pathReference)
														.then(() => {
															showNotification('Note deleted succesfully!', 2000, 'Success');
														})
														.catch((error) => {
															showNotification("Couldn't delete note!", 2000, 'Failure');
														});
												}
											}
										})
										.catch(() => {
											showNotification("Couldn't delete note!", 2000, 'Failure');
										});
								}
							}}
							class="btn btn-base-100 dropdown-content menu btn-small">Delete</button
						>
					</li>
				</ul>
			</details>
		</div>

		<div class="h-full overflow-auto leanscroll px-12 prose prose-h2:first-of-type:mt-0">
			<h2>Summary</h2>
			<p>{summary}</p>
			<h2>Content</h2>
			<p>
				{text}
			</p>
			<h2>Source Image</h2>
			{#if loading === true}
				<p>loading...</p>
			{:else if failed === true}
				<p>failed to load the image</p>
			{:else}
				<img src={imageSource} alt="Notes" />
			{/if}
		</div>
	</div>
</div>
