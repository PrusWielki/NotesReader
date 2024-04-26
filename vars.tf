variable "project_id" {
  type    = string
  default = "notesreader11"
}

variable "project_name" {
  type    = string
  default = "notesreader11"
}

variable "display_name" {
  type    = string
  default = "notesreader11"
}

variable "region" {
  type    = string
  default = "europe-central2"
}

variable "billing_account" {
  type = string
  default = ""
}

variable "document_ai_region" {
  type = string
  default = "eu"

}

variable "cloud_function_path" {
  type = string
  default = "./CloudFunctions/Main"
}

variable "cloud_function_entry_point" {
  type = string
  default = "helloPubSub"
}