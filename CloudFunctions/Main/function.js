'use strict';

// [START v2storageImports]
// [START v2storageSDKImport]
const { onObjectFinalized } = require('firebase-functions/v2/storage');
// [END v2storageSDKImport]

// [START v2storageAdditionalImports]
const { initializeApp } = require('firebase-admin/app');
const { getStorage } = require('firebase-admin/storage');
const logger = require('firebase-functions/logger');
const path = require('path');

// library for image resizing
const sharp = require('sharp');

initializeApp();
// [END v2storageAdditionalImports]
// [END v2storageImports]

// [START v2storageGenerateThumbnail]
/**
 * When an image is uploaded in the Storage bucket,
 * generate a thumbnail automatically using sharp.
 */
// [START v2storageGenerateThumbnailTrigger]
exports.generateThumbnail = onObjectFinalized({ cpu: 2 }, async (event) => {
	// [END v2storageGenerateThumbnailTrigger]

	// [START v2storageEventAttributes]
	const fileBucket = event.data.bucket; // Storage bucket containing the file.
	const filePath = event.data.name; // File path in the bucket.
	const contentType = event.data.contentType; // File content type.
	// [END v2storageEventAttributes]

	// [START v2storageStopConditions]
	// Exit if this is triggered on a file that is not an image.
	if (!contentType.startsWith('image/')) {
		return logger.log('This is not an image.');
	}
	// Exit if the image is already a thumbnail.
	const fileName = path.basename(filePath);
	if (fileName.startsWith('thumb_')) {
		return logger.log('Already a Thumbnail.');
	}
	// [END v2storageStopConditions]

	// [START v2storageThumbnailGeneration]
	// Download file into memory from bucket.
	const bucket = getStorage().bucket(fileBucket);
	const downloadResponse = await bucket.file(filePath).download();
	const imageBuffer = downloadResponse[0];
	logger.log('Image downloaded!');

	// Generate a thumbnail using sharp.
	const thumbnailBuffer = await sharp(imageBuffer)
		.resize({
			width: 200,
			height: 200,
			withoutEnlargement: true
		})
		.toBuffer();
	logger.log('Thumbnail created');

	// Prefix 'thumb_' to file name.
	const thumbFileName = `thumb_${fileName}`;
	const thumbFilePath = path.join(path.dirname(filePath), thumbFileName);

	// Upload the thumbnail.
	const metadata = { contentType: contentType };
	await bucket.file(thumbFilePath).save(thumbnailBuffer, {
		metadata: metadata
	});
	return logger.log('Thumbnail uploaded!');
	// [END v2storageThumbnailGeneration]
});
// [END v2storageGenerateThumbnail]
