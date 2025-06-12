variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ECS instances"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID of the ALB"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "EC2 instance type for ECS instances"
  type        = string
  default     = "t3.medium"
}

variable "desired_capacity" {
  description = "Desired number of EC2 instances"
  type        = number
  default     = 3
}

variable "min_size" {
  description = "Minimum number of EC2 instances"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of EC2 instances"
  type        = number
  default     = 6
}

variable "enable_container_insights" {
  description = "Whether to enable CloudWatch Container Insights"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
