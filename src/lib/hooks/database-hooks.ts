import { getStorage, ref, uploadBytes } from 'firebase/storage';
import { showNotification } from './show-notification';
import { collection, getFirestore, addDoc } from 'firebase/firestore';

const saveDataToDb = async (image: File, text: string, summary: string, fileExt: string) => {
	const storage = getStorage();
	const filename = crypto.randomUUID() + '.' + fileExt;

	const storageRef = ref(storage, filename);
	await uploadBytes(storageRef, image);
	const db = getFirestore();
	const data = {
		imageName: filename,
		text: text,
		summary: summary
	};
	// Add a new document in collection "cities" with ID 'LA'
	const collectionRef = collection(db, 'userData');
	addDoc(collectionRef, data);
	showNotification('Uploaded!', 4000, 'Success');
};

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
				}
			};
			fetch(import.meta.env.VITE_HTTPFUNCTION_URL, {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json'
				},
				body: JSON.stringify(bodyToSend)
			}).then((res) =>
				res.json().then((result) => {
					saveDataToDb(image, result.text, result.summary, fileExt);
				})
			);
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
};
