output "vpc_id" {
  value = aws_vpc.main.id
}

output "rds_primary_endpoint" {
  value = aws_db_instance.primary.address
}

output "rds_replica_endpoint" {
  value = aws_db_instance.replica.address
}

output "rds_secret_arn" {
  value = aws_secretsmanager_secret.db.arn
}

output "redis_primary_endpoint" {
  value = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "redis_reader_endpoint" {
  value = aws_elasticache_replication_group.main.reader_endpoint_address
}