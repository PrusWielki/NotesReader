variable "project_id" {
  type    = string
  default = "notesreader"
}

variable "project_name" {
  type    = string
  default = "notesreader"
}

variable "display_name" {
  type    = string
  default = "notesreader"
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
  default = "./CloudFunctions/Hello"
}

variable "cloud_function_entry_point" {
  type = string
  default = "helloHttp"
}