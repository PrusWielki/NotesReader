

# Provider

# Terraform configuration to set up providers by version.
terraform {
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.0"
    }
  }
}

# Configures the provider to use the resource block's specified project for quota checks.
provider "google-beta" {
  user_project_override = true
}

# Configures the provider to not use the resource block's specified project for quota checks.
# This provider should only be used during project creation and initializing services.
provider "google-beta" {
  alias = "no_user_project_override"
  user_project_override = false
}
provider "google" {
  project     = var.project_name
  region      = var.project_name
}

# Basic project setup

# Creates a new Google Cloud project.
resource "google_project" "default" {
  provider   = google-beta.no_user_project_override

  name       = var.project_name
  project_id = var.project_id
  # Required for any service that requires the Blaze pricing plan
  # (like Firebase Authentication with GCIP)
  billing_account = var.billing_account

  # Required for the project to display in any list of Firebase projects.
  labels = {
    "firebase" = "enabled"
  }
}

# Enables required APIs.
resource "google_project_service" "default" {
  provider = google-beta.no_user_project_override
  project  = google_project.default.project_id
  for_each = toset([
    "cloudbilling.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "firebase.googleapis.com",
    # Enabling the ServiceUsage API allows the new project to be quota checked from now on.
    "serviceusage.googleapis.com",
    "aiplatform.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudbuild.googleapis.com",
    "run.googleapis.com"
  ])
  service = each.key

  # Don't disable the service if the resource block is removed by accident.
  disable_on_destroy = false
}


# Enables Firebase services for the new project created above.
resource "google_firebase_project" "default" {
  provider = google-beta
  project  = google_project.default.project_id

  # Waits for the required APIs to be enabled.
  depends_on = [
    google_project_service.default
  ]
}
# WEB APP

resource "google_firebase_web_app" "default" {
  provider = google-beta

  project      = google_firebase_project.default.project
  display_name = var.project_name
  deletion_policy = "DELETE"
}




# AUTH


# Enable the Identity Toolkit API.
resource "google_project_service" "auth" {
  provider = google-beta

  project  = google_firebase_project.default.project
  service =  "identitytoolkit.googleapis.com"

  # Don't disable the service if the resource block is removed by accident.
  disable_on_destroy = false
}

# Create an Identity Platform config.
# Also, enable Firebase Authentication using Identity Platform (if Authentication isn't yet enabled).
resource "google_identity_platform_config" "auth" {
  provider = google-beta
  project  = google_firebase_project.default.project

  # For example, you can configure to auto-delete anonymous users.
  autodelete_anonymous_users = true

  # Wait for identitytoolkit.googleapis.com to be enabled before initializing Authentication.
  depends_on = [
    google_project_service.auth,
  ]
}



# STORAGE FOR IMAGES, CLOUD STORAGE BUCKET and FIRESTORE




# Enable required APIs for Cloud Firestore.
resource "google_project_service" "firestore" {
  provider = google-beta

  project  = google_firebase_project.default.project
  for_each = toset([
    "firestore.googleapis.com",
    "firebaserules.googleapis.com",
  ])
  service = each.key

  # Don't disable the service if the resource block is removed by accident.
  disable_on_destroy = false
}

# Provision the Firestore database instance.
resource "google_firestore_database" "default" {
  provider                    = google-beta

  project                     = google_firebase_project.default.project
  name                        = "(default)"
  # See available locations:
  # https://firebase.google.com/docs/firestore/locations
  location_id                 = var.region
  # "FIRESTORE_NATIVE" is required to use Firestore with Firebase SDKs,
  # authentication, and Firebase Security Rules.
  type                        = "FIRESTORE_NATIVE"
  concurrency_mode            = "OPTIMISTIC"

  depends_on = [
    google_project_service.firestore
  ]
}



# Enable required APIs for Cloud Storage for Firebase.
resource "google_project_service" "storage" {
  provider = google-beta

  project  = google_firebase_project.default.project
  for_each = toset([
    "firebasestorage.googleapis.com",
    "storage.googleapis.com",
  ])
  service = each.key


  # Don't disable the service if the resource block is removed by accident.
  disable_on_destroy = false
}

# Provision the default Cloud Storage bucket for the project via Google App Engine.
resource "google_app_engine_application" "default" {
  provider    = google-beta

  project     = google_firebase_project.default.project
  # See available locations: https://firebase.google.com/docs/projects/locations#default-cloud-location
  # This will set the location for the default Storage bucket and the App Engine App.
  location_id = var.region  # Must be in the same location as Firestore (above)

  # Wait until Firestore is provisioned first.
  depends_on = [
    google_firestore_database.default
  ]
}

# Make the default Storage bucket accessible for Firebase SDKs, authentication, and Firebase Security Rules.
resource "google_firebase_storage_bucket" "default-bucket" {
  provider  = google-beta

  project   = google_firebase_project.default.project
  bucket_id = google_app_engine_application.default.default_bucket
}

# CLOUD FUNCTION
resource "google_project_service" "cf" {
  project = google_project.default.project_id
  service = "cloudfunctions.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}

resource "random_id" "default" {
  byte_length = 8
}
resource "google_project_service" "cb" {
  project = google_project.default.project_id
  service = "cloudbuild.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}

data "archive_file" "default" {
  type        = "zip"
  output_path = "/tmp/function-source.zip"
  source_dir  = var.cloud_function_path
}


resource "google_storage_bucket" "bucket" {
  name = "${random_id.default.hex}-gcf-source" # Every bucket name must be globally unique
  location = var.region
}

resource "google_storage_bucket_object" "archive" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.bucket.name
  source = data.archive_file.default.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions_function" "function" {
  name        = "function-test"
  description = "My function"
  runtime     = "nodejs16"
  region=var.region

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  trigger_http          = true
  entry_point           = var.cloud_function_entry_point
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}