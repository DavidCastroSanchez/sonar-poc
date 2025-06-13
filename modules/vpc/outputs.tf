output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "database_subnets" {
  description = "List of IDs of database subnets"
  value       = module.vpc.database_subnets
}

output "database_subnet_group_name" {
  description = "Name of database subnet group"
  value       = module.vpc.database_subnet_group_name
}

output "azs" {
  description = "List of availability zones"
  value       = module.vpc.azs
}

output "flow_log_id" {
 description = "The ID of the VPC Flow Log"
 value       = aws_flow_log.vpc_flow_logs.id
}


output "flow_log_cloudwatch_group_arn" {
 description = "The ARN of the CloudWatch log group for VPC Flow Logs"
 value       = aws_cloudwatch_log_group.flow_logs.arn
}
