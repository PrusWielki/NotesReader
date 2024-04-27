/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import { onRequest } from 'firebase-functions/v2/https';
import * as logger from 'firebase-functions/logger';
import { setGlobalOptions } from 'firebase-functions/v2';

setGlobalOptions({ region: 'europe-west1' });
import vision from '@google-cloud/vision';

const client = new vision.ImageAnnotatorClient();

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

export const extractText = onRequest({ cors: true }, async (request, response) => {
	// const value = await client.annotateImage(request.body);
	const [textDetections] = await client.textDetection(request.body);
	const fullTextAnnotation = textDetections.fullTextAnnotation;
	logger.info(fullTextAnnotation?.text);

	response.send({ text: fullTextAnnotation?.text });
});
