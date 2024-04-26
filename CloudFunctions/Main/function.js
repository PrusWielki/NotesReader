// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

'use strict';

// [START functions_cloudevent_pubsub]
const functions = require('@google-cloud/functions-framework');

const Vision = require('@google-cloud/vision');
const vision = new Vision.ImageAnnotatorClient();

// Register a CloudEvent callback with the Functions Framework that will
// be executed when the Pub/Sub trigger topic receives a message.
functions.cloudEvent('extractText', async (cloudEvent) => {
	// The Pub/Sub message is passed as the CloudEvent's data payload.
	// const base64name = cloudEvent.data.message.data;

	// const name = base64name ? Buffer.from(base64name, 'base64').toString() : 'World';
	const { bucket, name } = cloudEvent.data;

	const [textDetections] = await vision.textDetection(`gs://${bucket}/${name}`);
	const [annotation] = textDetections.textAnnotations;
	const text = annotation ? annotation.description.trim() : '';
	console.log('Extracted text from image:', text);
});
// [END functions_cloudevent_pubsub]
