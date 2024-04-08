# Verify Terraform gcloud module works in your environment
module "gcloud_deploy_app" {
  source                            = "terraform-google-modules/gcloud/google"
  version                           = "~> 2.0"
  use_tf_google_credentials_env_var = false
  skip_download                     = false

  create_cmd_entrypoint = "gcloud"
  create_cmd_body       = "app deploy build/app.yaml"

  # if you want to skip the destroy, but you could also have another gcloud command
  destroy_cmd_entrypoint = "echo"
  destroy_cmd_body       = "skip"
}