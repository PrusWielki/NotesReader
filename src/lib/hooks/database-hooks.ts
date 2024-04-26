import { getStorage, ref, uploadBytes } from 'firebase/storage';
import { showNotification } from './show-notification';

export const pushImage = (image: File) => {
	const storage = getStorage();
	const fileExt = image.name.split('.').pop();
	if (fileExt !== 'png' && fileExt !== 'jpg' && fileExt !== 'pdf')
		showNotification('File should be .png, .jpg !', 4000, 'Failure');
	const storageRef = ref(storage, crypto.randomUUID() + '.' + fileExt);
	uploadBytes(storageRef, image).then((snapshot) => {
		showNotification('Uploaded!', 4000, 'Success');
	});
};
