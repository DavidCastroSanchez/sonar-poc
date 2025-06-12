output "alb_id" {
  description = "ID of the ALB"
  value       = aws_lb.ecs_alb.id
}

output "alb_arn" {
  description = "ARN of the ALB"
  value       = aws_lb.ecs_alb.arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.ecs_alb.dns_name
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.ecs_tg.arn
}

output "security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb_sg.id
}
output "lb_listener_arn" {
  description = "ARN of the ALB listener"
  value       = aws_lb_listener.http.arn
}
