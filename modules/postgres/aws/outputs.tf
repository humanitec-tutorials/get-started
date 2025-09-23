output "identifier" {
  value = aws_db_instance.get_started_rds_postgres_instance.identifier
}
output "arn" {
  value = aws_db_instance.get_started_rds_postgres_instance.arn
}
output "address" {
  value = aws_db_instance.get_started_rds_postgres_instance.address
}
output "port" {
  value = aws_db_instance.get_started_rds_postgres_instance.port
}
output "database" {
  value = local.db_name
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
      "arn" = aws_db_instance.get_started_rds_postgres_instance.arn
    },
    {
      "Identifier" = aws_db_instance.get_started_rds_postgres_instance.identifier
    },
    {
      "Address" = aws_db_instance.get_started_rds_postgres_instance.address
    },
    {
      "Port" = aws_db_instance.get_started_rds_postgres_instance.port
    },
    {
      "Database" = local.db_name
    },
    {
      "Region" = data.aws_region.current.region
    },
    {
      "AWS console URL" = "https://${data.aws_region.current.region}.console.aws.amazon.com/rds/home?region=${data.aws_region.current.region}#database:id=${aws_db_instance.get_started_rds_postgres_instance.identifier}"
    }
  )
}
