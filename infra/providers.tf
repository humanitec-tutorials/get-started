terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6"
    }
    required_version = ">= 1.12.0"
  }
}
