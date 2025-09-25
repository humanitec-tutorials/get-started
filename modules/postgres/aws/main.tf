# Module for creating a simple default RDS PostgreSQL database
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6"
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

data "aws_region" "current" {}

resource "random_string" "db_password" {
  length  = 12
  lower   = true
  upper   = true
  numeric = true
  special = false
}

resource "aws_db_instance" "get_started_rds_postgres_instance" {
  allocated_storage        = 5
  engine                   = "postgres"
  identifier               = "get-started-rds-db-instance"
  instance_class           = "db.t4g.micro"
  storage_encrypted        = true
  publicly_accessible      = true
  delete_automated_backups = true
  skip_final_snapshot      = true
  db_name                  = local.db_name
  username                 = local.db_username
  password                 = random_string.db_password.result
  apply_immediately        = true
  multi_az                 = false
  dedicated_log_volume     = false
}

# Need to open access to the database port via a security rule despite "publicly_accessible"
resource "aws_security_group_rule" "get_started_postgres_access" {
  type              = "ingress"
  from_port         = aws_db_instance.get_started_rds_postgres_instance.port
  to_port           = aws_db_instance.get_started_rds_postgres_instance.port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = tolist(aws_db_instance.get_started_rds_postgres_instance.vpc_security_group_ids)[0]
}
