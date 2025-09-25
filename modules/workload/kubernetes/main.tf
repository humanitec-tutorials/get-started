# Module for creating a simple default Kubernetes workload based on a Deployment

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2"
    }
  }
}

# Minimalistic Kubernetes deployment
resource "kubernetes_deployment" "simple" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }
  spec {
    selector {
      match_labels = {
        app = var.name
      }
    }
    template {
      metadata {
        labels = {
          app = var.name
        }
      }
      spec {
        container {
          image = var.image
          name  = "main"
          dynamic "env" {
            for_each = var.variables
            content {
              name  = env.key
              value = env.value
            }
          }
        }
      }
    }
  }
}
