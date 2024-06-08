## App written in Sveltekit and deployed on Google Cloud Platform with Cloud Functions allowing for OCR from images and text summarization, developed under the supervision of Google

## How to run

1. Fill the values in vars.tf

2. Create a .env in main directory with following fields:

```ts
VITE_FIREBASE_API_KEY= API KEY HERE // After step 3.
VITE_FIREBASE_APP_ID= APP ID HERE // After step 3.
VITE_FIREBASE_USE_EMULATOR=false
VITE_FIREBASE_AUTH_DOMAIN=notesreader.firebaseapp.com
VITE_STORAGE_BUCKET_DEFUALT=notesreader.appspot.com
VITE_HTTPFUNCTION_URL = DEPLOYED FUNCTION URL
VITE_PROJECT_ID=notesreader
VITE_CLOUDFUNCTION_REGION = europe-west1

```

3. Run `terraform init` and `terraform apply`

4. Fill the missing values in .env (API KEY and APP ID)

5. Edit functions/src/consts.ts to comply with the values entered in .env (PROJECT_NAME)

6. Enable Authentication by email and Google in Firebase console

7. Run `firebase deploy --only functions`

8. Run `gsutil cors set cors.json gs://notesreader.appspot.com`

9. Run `firebase experiments:enable webframeworks`

10. Make sure you are on Node 20 and Run `firebase deploy`
