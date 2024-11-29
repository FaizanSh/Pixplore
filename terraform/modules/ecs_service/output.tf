output "ecs_service_url" {
  value       = aws_lb.ecs_alb.dns_name
  description = "The URL of the FastAPI ECS service through the ALB"
}

output "ecs_service_arn" {
  value       = aws_lb.ecs_alb.arn
  description = "The ARN of the FastAPI ECS service through the ALB"
}

output "ecs_service_target_group_arn" {
  value       = aws_lb_target_group.ecs_tg.arn
  description = "The ARN of the FastAPI ECS service target group"
}
