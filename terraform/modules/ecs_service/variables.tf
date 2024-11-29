variable "region" {
  description = "AWS region"
  type        = string
}

variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "repository_name" {
  description = "ECR repository name"
  type        = string
}

variable "task_family" {
  description = "ECS task family name"
  type        = string
}

variable "task_cpu" {
  description = "CPU units for the ECS task"
  type        = string
}

variable "task_memory" {
  description = "Memory for the ECS task"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where ECS tasks will run"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ECS tasks"
  type        = list(string)
}

variable "desired_count" {
  description = "Number of ECS service instances"
  type        = number
}

variable "upload_photo_lambda_target_group_arn" {
  description = "The target group ARN for the upload photo lambda"
  type        = string
}

variable "landing_page_lambda_target_group_arn" {
  description = "The target group ARN for the landing page lambda"
  type        = string
  
}