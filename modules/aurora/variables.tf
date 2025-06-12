variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "allowed_security_groups" {
  description = "List of security group IDs allowed to access the database"
  type        = list(string)
  default     = []
}

variable "instance_class" {
  description = "Instance class for Aurora instances"
  type        = string
  default     = "db.t3.medium"
}

variable "instance_count" {
  description = "Number of Aurora instances"
  type        = number
  default     = 2
}

variable "backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "skip_final_snapshot" {
  description = "Whether to skip final snapshot when destroying the cluster"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
