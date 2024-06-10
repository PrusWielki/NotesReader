import { showNotification } from './show-notification';
import { httpsCallable } from 'firebase/functions';
import { functions } from '$lib/firebase.client';

export const pushImage = async (image: File) => {
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
			}).then(() => {
				showNotification('File processed!', 1000, 'Success');
			}).catch(() => {
				showNotification("Couldn't process file!", 2000, 'Failure');
			});
		} else showNotification("Couldn't process file!", 2000, 'Failure');
	};
};
