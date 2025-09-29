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
  }
}
