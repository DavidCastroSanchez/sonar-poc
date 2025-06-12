output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.cluster.id
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.cluster.name
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.cluster.arn
}

output "security_group_id" {
  description = "ID of the security group for ECS instances"
  value       = aws_security_group.ecs_instances.id
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.ecs_asg.name
}

output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.ecs.id
}
