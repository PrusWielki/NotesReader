import { writable } from 'svelte/store';

const notificationMessage = writable('');

export const notificationType = writable('');

export default notificationMessage;
