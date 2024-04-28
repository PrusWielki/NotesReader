import { getStorage, ref, uploadBytes } from 'firebase/storage';
import { showNotification } from './show-notification';
import { collection, getFirestore, addDoc } from 'firebase/firestore';
import { httpsCallable } from 'firebase/functions';
import { functions } from '$lib/firebase.client';

const saveDataToDb = async (
	image: File,
	text: string,
	summary: string,
	fileExt: string,
	uid: string
) => {
	const storage = getStorage();
	const filename = crypto.randomUUID() + '.' + fileExt;

	const storageRef = ref(storage, filename);
	await uploadBytes(storageRef, image);
	const db = getFirestore();
	const data = {
		imageName: filename,
		text: text,
		summary: summary,
		userId: uid
	};
	const collectionRef = collection(db, 'userData');
	addDoc(collectionRef, data);
	showNotification('Uploaded!', 4000, 'Success');
};

export const pushImage = async (image: File, uid: string) => {
	const fileExt = image.name.split('.').pop();
	if (fileExt !== 'png' && fileExt !== 'jpg') {
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
			const extractText = httpsCallable(functions, 'extractText');
			showNotification('Processing...', 20000, 'Info');
			extractText({
				visionData: bodyToSend,
				imageName: image.name,
				imageType: (reader.result as string).split('base64,')[0]
			}).then((result) => {
				showNotification('File processed!', 1000, 'Success');
			});
			/* 			fetch(import.meta.env.VITE_HTTPFUNCTION_URL, {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json'
				},
				body: JSON.stringify(bodyToSend)
			}).then((res) =>
				res.json().then((result) => {
					
					saveDataToDb(image, result.text, result.summary, fileExt, uid);
				})
			); */
		} else showNotification("Couldn't process file!", 4000, 'Failure');
	};
};
