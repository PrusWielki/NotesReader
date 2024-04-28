import { onCall } from 'firebase-functions/v2/https';
import * as logger from 'firebase-functions/logger';
import { setGlobalOptions } from 'firebase-functions/v2';
import { VertexAI } from '@google-cloud/vertexai';
import vision from '@google-cloud/vision';
import admin = require('firebase-admin');
import * as crypto from 'crypto';
import { PROJECT_NAME, LOCATION, TEXT_MODEL } from './consts';

admin.initializeApp();

const project = PROJECT_NAME;
const location = LOCATION;
const textModel = TEXT_MODEL;

const vertexAI = new VertexAI({ project: project, location: location });

const generativeModel = vertexAI.getGenerativeModel({
	model: textModel,

	generationConfig: { maxOutputTokens: 256 }
});

setGlobalOptions({ region: 'europe-west1' });

const client = new vision.ImageAnnotatorClient();

export const extractText = onCall({ cors: true }, async (request) => {
	logger.info(request);

	// Extract Text

	const [textDetections] = await client.textDetection(request.data.visionData);
	const fullTextAnnotation = textDetections.fullTextAnnotation;

	logger.info(fullTextAnnotation?.text);

	// Summarize notes

	const requestVertex = {
		contents: [
			{ role: 'user', parts: [{ text: 'Summarize this text: ' + fullTextAnnotation?.text }] }
		]
	};
	const result = await generativeModel.generateContent(requestVertex);
	const responseVertex = result.response;
	let responseText = '';
	if (responseVertex?.candidates)
		responseVertex.candidates[0].content.parts.forEach((part) => (responseText += part.text));

	logger.info(responseText);

	// Save to Cloud Storage and Firstore

	const fileExt = request.data.imageName.split('.').pop();
	const filename = crypto.randomUUID() + '.' + fileExt;

	const file = admin.storage().bucket().file(filename);
	var imageBuffer = new Buffer(request.data.visionData.image.content, 'base64');
	await file.save(imageBuffer, { contentType: request.data.imageType.split(':')[1].split(';')[0] });

	await admin.firestore().collection('userData').add({
		text: fullTextAnnotation?.text,
		summary: responseText,
		userId: request.auth?.uid,
		imageName: filename
	});

	return { text: fullTextAnnotation?.text, summary: responseText };
});
