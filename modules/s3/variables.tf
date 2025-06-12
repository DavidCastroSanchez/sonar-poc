variable "logging_bucket_name" {
  description = "S3 bucket name for storing logs"
  type        = string
}

variable "force_destroy" {
  description = "Whether to force destroy the bucket even if it contains objects"
  type        = bool
  default     = true
}

variable "enable_lifecycle_rules" {
  description = "Whether to enable lifecycle rules for log rotation"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain logs before deletion"
  type        = number
  default     = 90
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
