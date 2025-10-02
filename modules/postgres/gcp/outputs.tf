output "identifier" {
  value = google_sql_database_instance.instance.id
}
output "project" {
  value = google_sql_database_instance.instance.project
}
output "region" {
  value = google_sql_database_instance.instance.region
}
output "host" {
  value = google_sql_database_instance.instance.public_ip_address
}
output "port" {
  value = 5432
}
output "database" {
  value = google_sql_database.database.name
}
output "username" {
  value = local.db_username
}
output "password" {
  value     = random_string.db_password.result
  sensitive = true
}
output "humanitec_metadata" {
  description = "Metadata for the Orchestrator"
  value = merge(
    {
      "Region" = google_sql_database_instance.instance.region
    },
    {
      "Identifier" = google_sql_database_instance.instance.id
    },
    {
      "Host" = google_sql_database_instance.instance.public_ip_address
    },
    {
      "Port" = 5432
    },
    {
      "Database" = google_sql_database.database.name
    },
    {
      "Region" = google_sql_database_instance.instance.region
    },
    {
      "Google Cloud console URL" = "https://console.cloud.google.com/sql/instances/${google_sql_database_instance.instance.id}/overview?project=${data.google_client_config.this.project}"
    }
  )
}
