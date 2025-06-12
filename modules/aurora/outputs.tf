output "cluster_id" {
  description = "ID of the Aurora cluster"
  value       = aws_rds_cluster.aurora.id
}

output "cluster_arn" {
  description = "ARN of the Aurora cluster"
  value       = aws_rds_cluster.aurora.arn
}

output "cluster_endpoint" {
  description = "Writer endpoint for the cluster"
  value       = aws_rds_cluster.aurora.endpoint
}

output "reader_endpoint" {
  description = "Reader endpoint for the cluster"
  value       = aws_rds_cluster.aurora.reader_endpoint
}

output "security_group_id" {
  description = "ID of the security group for the Aurora cluster"
  value       = aws_security_group.aurora.id
}

output "database_name" {
  description = "Name of the default database"
  value       = aws_rds_cluster.aurora.database_name
}

output "master_username" {
  description = "Master username for the database"
  value       = aws_rds_cluster.aurora.master_username
  sensitive   = true
}

output "secret_arn" {
  description = "ARN of the secret containing database credentials"
  value       = aws_secretsmanager_secret.aurora_secret.arn
}
