Do it that way:

1. From the client, save the file in a bucket created on GCP
2. Send a http request to a cloud function with: bucketName, fileName, userId
   1. But this way I'm exposing bucketname and userId which I would rather not do.

Better yet:

1. Send file over http to a cloud function, make it save the file to a bucket
2. Make the function return text, and summary
3. In the client save the information to a firestore

Or:

1. Create a firebase cloud function (I don't think it can be deployed with terraform, it can be deployed with firebase CLI)
2. Send it the image file
3. Make it save it to a firebase bucket
4. Connect to Vision API and extract text
5. Summarize the text
6. Save it all to a firestore
7. Return success or failure
8. On the client refetch notes when success

- [ ] Create necessary cloud functions code - I have no idea how to make it event driven, cause when you want to trigger the function on a bucket upload event then you don't have access to who actually uploaded that file so it's hard to associate a user with a processed file and in order to allow vision api access to that bucket it would need to be made public it seems. So I think it's better to trigger it over http, by sending the image and then the function should return the extracted text and summary
- [ ] Add automatic auth setup to Terraform -that actually might not be possible :()
- [x] Write API in Sveltekit or maybe just communicate via client
- [ ] Connect the main page to the realtime database
- [ ] Connect modal to the realtime database
