output "humanitec_metadata" {
  description = "Metadata for the Orchestrator"
  value = merge(
    {
      "Namespace" = var.namespace
    },
    {
      "Image" = var.image
    },
    {
      "Deployment" = kubernetes_deployment.simple.metadata[0].name
    }
  )
}
