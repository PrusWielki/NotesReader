import { getStorage, ref, uploadBytes } from 'firebase/storage';
import { showNotification } from './show-notification';

export const pushImage = async (image: File) => {
	const fileExt = image.name.split('.').pop();
	if (fileExt !== 'png' && fileExt !== 'jpg' && fileExt !== 'pdf') {
		showNotification('File should be .png, .jpg !', 4000, 'Failure');
		return;
	}

	var reader = new FileReader();
	reader.readAsDataURL(image);

	reader.onload = function () {
		if (reader.result) {
			const bodyToSend = {
				image: {
					content: (reader.result as string).split('base64,')[1]
				},
				features: [{ type: 'TEXT_DETECTION' }]
			};
			fetch(import.meta.env.VITE_HTTPFUNCTION_URL, {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json'
				},
				body: JSON.stringify(bodyToSend)
			}).then((res) => console.log(res));
		} else showNotification("Couldn't process file!", 4000, 'Failure');
	};

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
	const filename = crypto.randomUUID() + '.' + fileExt;

	const storageRef = ref(storage, filename);
	uploadBytes(storageRef, image).then((snapshot) => {
		showNotification('Uploaded!', 4000, 'Success');
		fetch(import.meta.env.VITE_HTTPFUNCTION_URL, {
			method: 'POST',

			body: 'gs://' + import.meta.env.VITE_STORAGE_BUCKET_DEFUALT + '/' + filename
		}).then((res) => console.log(res));
	}); */
};
