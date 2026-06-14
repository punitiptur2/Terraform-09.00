data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name_prefix   = "${var.project_name}-${var.environment}"
  subnet_azs    = slice(data.aws_availability_zones.available.names, 0, length(var.private_subnet_cidrs))
  allowed_cidrs = length(var.allowed_cidr_blocks) > 0 ? var.allowed_cidr_blocks : [var.vpc_cidr_block]
}

resource "aws_kms_key" "main" {
  description             = "KMS key for ${local.name_prefix} data services"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "main" {
  name          = "alias/${local.name_prefix}-data"
  target_key_id = aws_kms_key.main.key_id
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = local.subnet_azs[count.index]

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-private-${count.index + 1}"
    Tier = "private"
  })
}

resource "aws_db_subnet_group" "main" {
  name       = "${local.name_prefix}-db-subnets"
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-db-subnets"
  })
}

resource "aws_elasticache_subnet_group" "main" {
  name       = "${local.name_prefix}-redis-subnets"
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]
}

resource "aws_db_parameter_group" "main" {
  name   = "${local.name_prefix}-mysql-params"
  family = var.db_parameter_group_family

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "long_query_time"
    value = "2"
  }
}

resource "aws_elasticache_parameter_group" "main" {
  name   = "${local.name_prefix}-redis-params"
  family = var.redis_parameter_group_family

  parameter {
    name  = "activedefrag"
    value = "yes"
  }
}

resource "aws_security_group" "rds" {
  name        = "${local.name_prefix}-rds-sg"
  description = "Allow MySQL access within the private network"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = local.allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "redis" {
  name        = "${local.name_prefix}-redis-sg"
  description = "Allow Redis access within the private network"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = local.allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "random_password" "db" {
  length           = 24
  special          = true
  override_special = "!@#$%^&*-_=+"
}

resource "aws_secretsmanager_secret" "db" {
  name                    = "${local.name_prefix}/rds/master"
  recovery_window_in_days = 7
  kms_key_id              = aws_kms_key.main.arn
  description             = "Master credentials for the ${local.name_prefix} RDS instance"
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id

  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db.result
    engine   = "mysql"
    host     = aws_db_instance.primary.address
    port     = 3306
  })
}

resource "aws_db_instance" "primary" {
  identifier                      = "${local.name_prefix}-primary"
  allocated_storage               = var.db_allocated_storage
  engine                          = "mysql"
  engine_version                  = var.db_engine_version
  instance_class                  = var.db_instance_class
  db_name                         = var.db_name
  username                        = var.db_username
  password                        = random_password.db.result
  port                            = 3306
  db_subnet_group_name            = aws_db_subnet_group.main.name
  vpc_security_group_ids          = [aws_security_group.rds.id]
  parameter_group_name            = aws_db_parameter_group.main.name
  storage_encrypted               = true
  kms_key_id                      = aws_kms_key.main.arn
  multi_az                        = true
  publicly_accessible             = false
  backup_retention_period         = 7
  backup_window                   = var.db_backup_window
  maintenance_window              = var.db_maintenance_window
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]
  performance_insights_enabled    = true
  performance_insights_kms_key_id = aws_kms_key.main.arn
  auto_minor_version_upgrade      = true
  apply_immediately               = false
  deletion_protection             = true
  copy_tags_to_snapshot           = true
  skip_final_snapshot             = false
  final_snapshot_identifier       = "${local.name_prefix}-final-${random_string.suffix.result}"
  storage_type                    = "gp3"

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-primary"
    Role = "primary"
  })
}

resource "aws_db_instance" "replica" {
  identifier                   = "${local.name_prefix}-replica"
  replicate_source_db          = aws_db_instance.primary.identifier
  instance_class               = var.db_replica_instance_class
  db_subnet_group_name         = aws_db_subnet_group.main.name
  vpc_security_group_ids       = [aws_security_group.rds.id]
  publicly_accessible          = false
  multi_az                     = false
  auto_minor_version_upgrade   = true
  apply_immediately            = false
  storage_encrypted            = true
  kms_key_id                   = aws_kms_key.main.arn
  performance_insights_enabled = true
  availability_zone            = local.subnet_azs[1]
  skip_final_snapshot          = true

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-replica"
    Role = "replica"
  })
}

resource "aws_elasticache_replication_group" "main" {
  replication_group_id       = "${local.name_prefix}-redis"
  description                = "Redis replication group for ${local.name_prefix}"
  engine                     = "redis"
  engine_version             = var.redis_engine_version
  node_type                  = var.redis_node_type
  port                       = 6379
  parameter_group_name       = aws_elasticache_parameter_group.main.name
  subnet_group_name          = aws_elasticache_subnet_group.main.name
  security_group_ids         = [aws_security_group.redis.id]
  num_node_groups            = 1
  replicas_per_node_group    = 1
  automatic_failover_enabled  = true
  multi_az_enabled           = true
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  kms_key_id                 = aws_kms_key.main.arn
  snapshot_retention_limit   = 7
  snapshot_window            = var.redis_snapshot_window
  maintenance_window         = var.redis_maintenance_window
  apply_immediately          = false
  auto_minor_version_upgrade  = true

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-redis"
    Role = "cache"
  })
}