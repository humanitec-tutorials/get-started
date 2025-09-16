terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5"
    }
    
    # Added through tutorial
    platform-orchestrator = {
      source  = "humanitec/platform-orchestrator"
      version = "~> 2"
    }
  }
}

# Added through tutorial
# Configure the Platform Orchestrator provider
provider "platform-orchestrator" {
  org_id     = var.orchestrator_org
  auth_token = var.orchestrator_auth_token
  api_url    = "https://api.humanitec.dev"
}
