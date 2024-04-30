

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


resource "google_firestore_index" "userDataIndex" {
  project     = google_firebase_project.default.project
  database   = google_firestore_database.default.name
  collection = "userData"

  fields {
    field_path = "userId"
    order      = "ASCENDING"
  }
  fields {
    field_path = "date"
    order      = "ASCENDING"
  }




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







# Create a ruleset of Firestore Security Rules from a local file.
resource "google_firebaserules_ruleset" "firestore" {
  provider = google-beta

  project  = google_firebase_project.default.project
  source {
    files {
      name = "firestore.rules"
      # Write security rules in a local file named "firestore.rules".
      # Learn more: https://firebase.google.com/docs/firestore/security/get-started
      content = file("firestore.rules")
    }
  }

  # Wait for Firestore to be provisioned before creating this ruleset.
  depends_on = [
    google_firestore_database.default,
  ]
  }



# Release the ruleset for the Firestore instance.
resource "google_firebaserules_release" "firestore" {
  provider     = google-beta

  name         = "cloud.firestore"  # must be cloud.firestore
  ruleset_name = google_firebaserules_ruleset.firestore.name
  project      = google_firebase_project.default.project

  # Wait for Firestore to be provisioned before releasing the ruleset.
  depends_on = [
    google_firestore_database.default,
  ]

  lifecycle {
    replace_triggered_by = [
      google_firebaserules_ruleset.firestore
    ]
  }
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



