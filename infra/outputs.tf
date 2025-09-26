output "enabled_cloud_provider" {
  value = var.enabled_cloud_provider
}
output "k8s_connect_command" {
  value = length(aws_eks_cluster.get-started) > 0 ? "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.get-started[0].name}" : "No cluster created"
}
