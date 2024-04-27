import { onRequest } from 'firebase-functions/v2/https';
import * as logger from 'firebase-functions/logger';
import { setGlobalOptions } from 'firebase-functions/v2';

import { VertexAI } from '@google-cloud/vertexai';

const project = 'notesreader11';
const location = 'europe-west1';
const textModel = 'gemini-1.0-pro';

const vertexAI = new VertexAI({ project: project, location: location });

const generativeModel = vertexAI.getGenerativeModel({
	model: textModel,

	generationConfig: { maxOutputTokens: 256 }
});

setGlobalOptions({ region: 'europe-west1' });
import vision from '@google-cloud/vision';

const client = new vision.ImageAnnotatorClient();

export const extractText = onRequest({ cors: true }, async (request, response) => {
	const [textDetections] = await client.textDetection(request.body);
	const fullTextAnnotation = textDetections.fullTextAnnotation;

	logger.info(fullTextAnnotation?.text);

	const requestVertex = {
		contents: [
			{ role: 'user', parts: [{ text: 'Summarize this text: ' + fullTextAnnotation?.text }] }
		]
	};
	const result = await generativeModel.generateContent(requestVertex);
	const responseVertex = result.response;

	logger.info(JSON.stringify(responseVertex));

	response.send({ text: fullTextAnnotation?.text });
});
