import { getStorage, ref, uploadBytes } from 'firebase/storage';
import { showNotification } from './show-notification';

export const pushImage = async (image: File) => {
	const fileExt = image.name.split('.').pop();
	if (fileExt !== 'png' && fileExt !== 'jpg' && fileExt !== 'pdf')
		showNotification('File should be .png, .jpg !', 4000, 'Failure');

	fetch(import.meta.env.VITE_HTTPFUNCTION_URL, { method: 'POST', body: image }).then((res) =>
		console.log(res)
	);
	/* 
	const vision = new ImageAnnotatorClient();
	const [textDetections] = await vision.textDetection(image);
	const [annotation] = textDetections.textAnnotations;
	const text = annotation ? annotation.description.trim() : '';
	console.log('Extracted text from image:', textDetections);

	fetch(import.meta.env.VITE_HTTPFUNCTION_URL, { method: 'POST', body: image }).then((res) =>
		res.json().then((result) => {
			console.log(result);
		})
	);
 */
	/* 	const storage = getStorage();

	const storageRef = ref(storage, crypto.randomUUID() + '.' + fileExt);
	uploadBytes(storageRef, image).then((snapshot) => {
		showNotification('Uploaded!', 4000, 'Success');
	}); */
};
