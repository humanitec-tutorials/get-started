output "k8s_connect_command" {
  value = length(aws_eks_cluster.get-started) > 0 ? "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.get-started[0].name}" : "No cluster created"
}

# Expand for GCP: length(gcp_gke_cluster.get-started) > 0 ? "gcloud container clusters get-credentials <TODO: cluster name from TF resource> --region ${var.gcp_region} --project ${var.gcp_project_id}"