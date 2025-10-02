# Module for creating a simple default CloudSQL PostgreSQL database
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

locals {
  db_name     = "get_started"
  db_username = "get_started"
}

data "google_client_config" "this" {}

resource "random_string" "root_password" {
  length  = 12
  lower   = true
  upper   = true
  numeric = true
  special = false
}

resource "random_string" "db_password" {
  length  = 12
  lower   = true
  upper   = true
  numeric = true
  special = false
}

# Minimalistic Postgres CloudSQL instance accessible from anywhere
resource "google_sql_database_instance" "instance" {
  name             = "get-started-cloudsql-db-instance"
  project          = data.google_client_config.this.project
  region           = data.google_client_config.this.region
  database_version = "POSTGRES_18"
  root_password    = random_string.root_password.result
  settings {
    tier    = "db-custom-2-7680"
    edition = "ENTERPRISE"
    ip_configuration {
      authorized_networks {
        name  = "anywhere"
        value = "0.0.0.0/0"
      }
    }
    data_cache_config {
      data_cache_enabled = false
    }
    backup_configuration {
      enabled = false
    }
  }
  deletion_protection = false
}

# User for the instance
resource "google_sql_user" "builtin_user" {
  name     = local.db_username
  password = random_string.db_password.result
  instance = google_sql_database_instance.instance.name
  type     = "BUILT_IN"
}

# Database in the CloudSQL instance
resource "google_sql_database" "database" {
  name     = local.db_name
  instance = google_sql_database_instance.instance.name
}
