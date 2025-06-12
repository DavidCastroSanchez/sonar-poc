variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "cluster_id" {
  description = "ID of the ECS cluster"
  type        = string
}

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ECS service"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for the ECS service"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the ALB target group"
  type        = string
}

variable "lb_listener_arn" {
  description = "ARN of the ALB listener"
  type        = string
}

variable "container_image" {
  description = "Docker image for the container"
  type        = string
  default     = "nginx:latest"
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 80
}

variable "container_environment" {
  description = "Environment variables for the container"
  type        = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "task_cpu" {
  description = "CPU units for the task"
  type        = string
  default     = "256"
}

variable "task_memory" {
  description = "Memory for the task in MiB"
  type        = string
  default     = "512"
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 3
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of tasks for auto scaling"
  type        = number
  default     = 1
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of tasks for auto scaling"
  type        = number
  default     = 6
}

variable "cpu_target_value" {
  description = "Target CPU utilization percentage for auto scaling"
  type        = number
  default     = 60
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
