output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = module.alb.alb_dns_name
}

output "aurora_endpoint" {
  description = "Writer endpoint for the Aurora cluster"
  value       = module.aurora.cluster_endpoint
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs_cluster.cluster_name
}

output "logging_bucket" {
  description = "Name of the S3 bucket"
  value       = module.s3.bucket_id
}

output "backup_vault_arn" {
  description = "ARN of the primary backup vault"
  value       = var.enable_dr ? module.dr[0].backup_vault_arn : null
}

output "dr_backup_vault_arn" {
  description = "ARN of the DR backup vault"
  value       = var.enable_dr ? module.dr[0].dr_backup_vault_arn : null
}