<script lang="ts">
	// register/+page.svelte
	import { auth } from '$lib/firebase.client';
	import {
		GoogleAuthProvider,
		createUserWithEmailAndPassword,
		signInWithPopup
	} from 'firebase/auth';
	import { goto } from '$app/navigation';
	import { session } from '$lib/session';
	import { showNotification } from '$lib/hooks/show-notification';

	let email: string = '';
	let password: string = '';
	let repeatedPassword: string = '';

	async function handleRegister() {
		if (repeatedPassword === password) {
			await createUserWithEmailAndPassword(auth, email, password)
				.then((result) => {
					const { user } = result;
					session.update((cur: any) => {
						return {
							...cur,
							user,
							loggedIn: true,
							loading: false
						};
					});
					goto('/');
				})
				.catch((error) => {
					throw new Error(error);
				});
		} else {
			showNotification('Passwords dont match!', 2000, 'Failure');
		}
	}

	async function loginWithGoogle() {
		const provider = new GoogleAuthProvider();
		await signInWithPopup(auth, provider)
			.then((result) => {
				const { displayName, email, photoURL, uid } = result?.user;
				session.set({
					loggedIn: true,
					user: {
						displayName,
						email,
						photoURL,
						uid
					}
				});

				goto('/main');
			})
			.catch((error) => {
				return error;
			});
	}
</script>

<div class="w-full font-montserrat min-h-[100lvh] flex items-center">
	<form
		class="max-w-md sm:w-full w-10/12 mx-auto px-4 flex flex-col items-center gap-4"
		on:submit={handleRegister}
	>
		<h1 class="text-center text-xl font-bold sm:text-3xl mb-2">Glad to see You</h1>
		<h2 class="text-center font-semibold max-w-lg w-fit [text-wrap:balance] mb-2">
			Just a few more steps before You can start converting Your notes
		</h2>
		<label
			class="input input-bordered w-full input-neutral focus-within:input-primary flex items-center gap-2"
		>
			<svg
				xmlns="http://www.w3.org/2000/svg"
				viewBox="0 0 16 16"
				fill="currentColor"
				class="w-4 h-4 opacity-70"
			>
				<path
					d="M2.5 3A1.5 1.5 0 0 0 1 4.5v.793c.026.009.051.02.076.032L7.674 8.51c.206.1.446.1.652 0l6.598-3.185A.755.755 0 0 1 15 5.293V4.5A1.5 1.5 0 0 0 13.5 3h-11Z"
				/>
				<path
					d="M15 6.954 8.978 9.86a2.25 2.25 0 0 1-1.956 0L1 6.954V11.5A1.5 1.5 0 0 0 2.5 13h11a1.5 1.5 0 0 0 1.5-1.5V6.954Z"
				/>
			</svg>
			<input bind:value={email} type="text" class="grow text-lg" placeholder="Email" />
		</label>
		<label class="input input-bordered w-full flex items-center focus-within:input-primary gap-2">
			<svg
				xmlns="http://www.w3.org/2000/svg"
				viewBox="0 0 16 16"
				fill="currentColor"
				class="w-4 h-4 opacity-70"
			>
				<path
					fill-rule="evenodd"
					d="M14 6a4 4 0 0 1-4.899 3.899l-1.955 1.955a.5.5 0 0 1-.353.146H5v1.5a.5.5 0 0 1-.5.5h-2a.5.5 0 0 1-.5-.5v-2.293a.5.5 0 0 1 .146-.353l3.955-3.955A4 4 0 1 1 14 6Zm-4-2a.75.75 0 0 0 0 1.5.5.5 0 0 1 .5.5.75.75 0 0 0 1.5 0 2 2 0 0 0-2-2Z"
					clip-rule="evenodd"
				/>
			</svg>
			<input bind:value={password} type="password" class="grow text-lg" placeholder="Password" />
		</label>
		<label class="input input-bordered w-full flex items-center focus-within:input-primary gap-2">
			<svg
				xmlns="http://www.w3.org/2000/svg"
				viewBox="0 0 16 16"
				fill="currentColor"
				class="w-4 h-4 opacity-70"
			>
				<path
					fill-rule="evenodd"
					d="M14 6a4 4 0 0 1-4.899 3.899l-1.955 1.955a.5.5 0 0 1-.353.146H5v1.5a.5.5 0 0 1-.5.5h-2a.5.5 0 0 1-.5-.5v-2.293a.5.5 0 0 1 .146-.353l3.955-3.955A4 4 0 1 1 14 6Zm-4-2a.75.75 0 0 0 0 1.5.5.5 0 0 1 .5.5.75.75 0 0 0 1.5 0 2 2 0 0 0-2-2Z"
					clip-rule="evenodd"
				/>
			</svg>
			<input
				bind:value={repeatedPassword}
				type="password"
				placeholder="Repeat Password"
				class="grow text-lg"
			/>
		</label>
		<button type="submit" class="btn w-full btn-primary text-lg">Sign up</button>
		<p>Or</p>
		<button
			type="button"
			on:click={loginWithGoogle}
			class="btn w-full btn-neutral btn-outline gap-1 sm:gap-2"
		>
			<p
				class="py-1 font-bold bg-[linear-gradient(to_right,theme(colors.red.500),theme(colors.yellow.500),theme(colors.green.500),theme(colors.blue.500))] inline-block text-transparent bg-clip-text"
			>
				Sign up with Google
			</p>

			<svg
				xmlns="http://www.w3.org/2000/svg"
				x="0px"
				y="0px"
				width="32"
				height="32"
				viewBox="0 0 48 48"
			>
				<path
					fill="#FFC107"
					d="M43.611,20.083H42V20H24v8h11.303c-1.649,4.657-6.08,8-11.303,8c-6.627,0-12-5.373-12-12c0-6.627,5.373-12,12-12c3.059,0,5.842,1.154,7.961,3.039l5.657-5.657C34.046,6.053,29.268,4,24,4C12.955,4,4,12.955,4,24c0,11.045,8.955,20,20,20c11.045,0,20-8.955,20-20C44,22.659,43.862,21.35,43.611,20.083z"
				></path>
				<path
					fill="#FF3D00"
					d="M6.306,14.691l6.571,4.819C14.655,15.108,18.961,12,24,12c3.059,0,5.842,1.154,7.961,3.039l5.657-5.657C34.046,6.053,29.268,4,24,4C16.318,4,9.656,8.337,6.306,14.691z"
				></path>
				<path
					fill="#4CAF50"
					d="M24,44c5.166,0,9.86-1.977,13.409-5.192l-6.19-5.238C29.211,35.091,26.715,36,24,36c-5.202,0-9.619-3.317-11.283-7.946l-6.522,5.025C9.505,39.556,16.227,44,24,44z"
				></path>
				<path
					fill="#1976D2"
					d="M43.611,20.083H42V20H24v8h11.303c-0.792,2.237-2.231,4.166-4.087,5.571c0.001-0.001,0.002-0.001,0.003-0.002l6.19,5.238C36.971,39.205,44,34,44,24C44,22.659,43.862,21.35,43.611,20.083z"
				></path>
			</svg>
		</button>
	</form>
</div>
