variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "sonar"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owner tag for resources"
  type        = string
  default     = "dev-team"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "database_subnets" {
  description = "List of database subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]
}

variable "logging_bucket_name" {
  description = "S3 bucket name for storing logs"
  type        = string
  default     = "sonar-logs"
}

variable "enable_dr" {
  description = "Whether to enable disaster recovery backup"
  type        = bool
  default     = false
}

variable "dr_region" {
  description = "AWS region for disaster recovery"
  type        = string
  default     = "us-west-2"
}
