output "humanitec_metadata" {
  description = "Metadata for Humanitec."
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
