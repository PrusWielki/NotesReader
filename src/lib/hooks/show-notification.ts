import notificationMessage from '$lib/store/notification';
import { notificationType } from '$lib/store/notification';
export const showNotification = (message: string, time: number, type: 'Success' | 'Failure') => {
	notificationType.set(type);
	notificationMessage.set(message);

	setTimeout(() => {
		notificationMessage.set('');
	}, time);
};
