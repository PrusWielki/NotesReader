import { getStorage, ref, uploadBytes } from 'firebase/storage';
import { showNotification } from './show-notification';

export const pushImage = (image: File) => {
	const storage = getStorage();
	const storageRef = ref(storage, 'images/' + crypto.randomUUID());
	uploadBytes(storageRef, image).then((snapshot) => {
		showNotification('Uploaded!', 4000, 'Success');
	});
};
