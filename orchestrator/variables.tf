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
variable "orchestrator_org" {
  description = "Ochestrator organization ID"
}
variable "orchestrator_auth_token" {
  description = "Orchestrator auth token"
}
variable "k8s_cluster_name" {
  description = "Name of the runner K8s cluster"
}
variable "k8s_cluster_endpoint" {
  description = "Endpoing of the runner K8s cluster API server"
}
variable "cluster_ca_certificate" {
  description = "CA cert of the runner K8s cluster"
}
variable "agent_runner_irsa_role_arn" {
  description = "AWS IAM Role arn for the agent runner"
}