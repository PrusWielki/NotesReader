## App written in Sveltekit and deployed on Google Cloud Platform with Cloud Functions allowing for OCR from images and text summarization

## How to run

1. Fill the values in vars.tf

2. Create a .env in main directory with following fields:

```ts
VITE_FIREBASE_API_KEY= API KEY HERE
VITE_FIREBASE_APP_ID= APP ID HERE
VITE_FIREBASE_USE_EMULATOR=false
VITE_FIREBASE_AUTH_DOMAIN=notesreader.firebaseapp.com
VITE_STORAGE_BUCKET_DEFUALT=notesreader.appspot.com
VITE_PROJECT_ID=notesreader
```

3. Run `terraform init` and `terraform apply`

4. Fill the missing values in .env

5. Run `gsutil cors set cors.json gs://notesreader.appspot.com`

6. Run `firebase deploy`
