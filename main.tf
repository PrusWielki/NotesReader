

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
    "run.googleapis.com",
    "eventarc.googleapis.com",
    "pubsub.googleapis.com",
    "vision.googleapis.com"
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

# Create a ruleset of Cloud Storage Security Rules from a local file.
resource "google_firebaserules_ruleset" "storage" {
  provider = google-beta

  project  = google_firebase_project.default.project
  source {
    files {
      # Write security rules in a local file named "storage.rules".
      # Learn more: https://firebase.google.com/docs/storage/security/get-started
      name    = "storage.rules"
      content = file("storage.rules")
    }
  }

  # Wait for the default Storage bucket to be provisioned before creating this ruleset.
  depends_on = [
    google_firebase_storage_bucket.default-bucket,
  ]
}

# Release the ruleset to the default Storage bucket.
resource "google_firebaserules_release" "default-bucket" {
  provider     = google-beta

  name         = "firebase.storage/${google_app_engine_application.default.default_bucket}"
  ruleset_name = "projects/${google_firebase_project.default.project}/rulesets/${google_firebaserules_ruleset.storage.name}"
  project      = google_firebase_project.default.project

  lifecycle {
    replace_triggered_by = [
      google_firebaserules_ruleset.storage
    ]
  }
}


# CLOUD FUNCTION



# Topic that will via an Eventarc-trigger trigger Cloud function
resource "google_pubsub_topic" "topic" {
  name = "cloud-function-topic"
}


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





data "google_storage_project_service_account" "default" {
}
data "google_project" "project" {
}
resource "google_project_iam_member" "gcs_pubsub_publishing" {
  project = data.google_project.project.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${data.google_storage_project_service_account.default.email_address}"
}

resource "google_service_account" "account" {
  account_id   = "gcf-sa"
  display_name = "Test Service Account - used for both the cloud function and eventarc trigger in the test"
}

# Permissions on the service account used by the function and Eventarc trigger
resource "google_project_iam_member" "invoking" {
  project    = data.google_project.project.project_id
  role       = "roles/run.invoker"
  member     = "serviceAccount:${google_service_account.account.email}"
  depends_on = [google_project_iam_member.gcs_pubsub_publishing]
}

resource "google_project_iam_member" "event_receiving" {
  project    = data.google_project.project.project_id
  role       = "roles/eventarc.eventReceiver"
  member     = "serviceAccount:${google_service_account.account.email}"
  depends_on = [google_project_iam_member.invoking]
}

resource "google_project_iam_member" "artifactregistry_reader" {
  project    = data.google_project.project.project_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.account.email}"
  depends_on = [google_project_iam_member.event_receiving]
}


resource "google_cloudfunctions2_function" "default" {
  depends_on = [
    google_project_iam_member.event_receiving,
    google_project_iam_member.artifactregistry_reader,
  ]
  name        = "function"
  location    = var.region
  description = "a new function"

  build_config {
    runtime     = "nodejs20"
    entry_point = var.cloud_function_entry_point # Set the entry point in the code
    environment_variables = {
      BUILD_CONFIG_TEST = "build_test"
    }
    source {
      storage_source {
        bucket = google_storage_bucket.bucket.name
        object = google_storage_bucket_object.archive.name
      }
    }
  }
  service_config {
    max_instance_count = 3
    min_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
    environment_variables = {
      SERVICE_CONFIG_TEST = "config_test"
    }
    ingress_settings               = "ALLOW_INTERNAL_ONLY"
    all_traffic_on_latest_revision = true
    service_account_email          = google_service_account.account.email
  }

  event_trigger {
    trigger_region        = var.region # The trigger must be in the same location as the bucket
    event_type            = "google.cloud.storage.object.v1.finalized"
    retry_policy          = "RETRY_POLICY_RETRY"
    service_account_email = google_service_account.account.email
    event_filters {
      attribute = "bucket"
      value     = google_firebase_storage_bucket.default-bucket.bucket_id
    }
  }
}




