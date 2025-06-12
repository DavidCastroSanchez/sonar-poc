output "backup_vault_arn" {
  description = "ARN of the primary backup vault"
  value       = aws_backup_vault.main.arn
}

output "dr_backup_vault_arn" {
  description = "ARN of the DR backup vault"
  value       = aws_backup_vault.dr_copy_target.arn
}

output "backup_plan_id" {
  description = "ID of the backup plan"
  value       = aws_backup_plan.aurora_daily.id
}

output "backup_role_arn" {
  description = "ARN of the IAM role for AWS Backup"
  value       = aws_iam_role.backup_role.arn
}
