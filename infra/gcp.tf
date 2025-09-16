provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}
locals {
  create_gcp = var.enabled_cloud_provider == "gcp"
}