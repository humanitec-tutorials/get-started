variable "enabled_cloud_provider" {
  description = "Which cloud provider to use"
}
variable "aws_region" {
  description = "AWS region for resources"
}
variable "gcp_project_id" {
  description = "GCP project ID"
}
variable "gcp_region" {
  description = "GCP region for resources"
}

# Added through tutorial
variable "orchestrator_org" {
  description = "Ochestrator organization name"
}

# Added through tutorial
variable "orchestrator_auth_token" {
  description = "Orchestrator auth token"
}
