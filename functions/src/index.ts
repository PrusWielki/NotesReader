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
	logger.info(request.body);
	const value = await client.annotateImage(request.body);
	logger.info('Hello logs!', { structuredData: true });
	response.send(value);
});
