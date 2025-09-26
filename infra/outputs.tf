output "enabled_cloud_provider" {
  value = var.enabled_cloud_provider
}
output "k8s_connect_command" {
  value = length(aws_eks_cluster.get-started) > 0 ? "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.get-started[0].name}" : "No cluster created"
}
output "k8s_cluster_name" {
  value = aws_eks_cluster.get-started[0].name
}
output "k8s_cluster_endpoint" {
  value = aws_eks_cluster.get-started[0].endpoint
}
output "cluster_ca_certificate" {
  value     = aws_eks_cluster.get-started[0].certificate_authority[0].data
  sensitive = true
}
output "agent_runner_irsa_role_arn" {
  value = aws_iam_role.agent_runner_irsa_role.arn
}
