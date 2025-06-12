variable "project_name" {
  description = "Project or environment name"
  type        = string
}

variable "aurora_cluster_arn" {
  description = "ARN of the Aurora DB cluster to back up"
  type        = string
}

variable "backup_vault_name" {
  description = "Name of the backup vault"
  type        = string
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "backup_schedule" {
  description = "Cron expression for backup schedule"
  type        = string
  default     = "cron(0 5 * * ? *)"  # Daily at 5 AM UTC
}

variable "kms_key_arn" {
  description = "KMS key ARN for backup encryption"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}