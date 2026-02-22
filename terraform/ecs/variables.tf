variable "project_name" {}
variable "environment" {}
variable "aws_region" {}
variable "vpc_id" {}
variable "private_subnet_ids" {
  type = list(string)
}
variable "alb_security_group_id" {}
variable "target_group_arn" {}
variable "alb_listener_arn" {}
variable "ecs_execution_role_arn" {}
variable "ecs_task_role_arn" {}
variable "ecr_repository_url" {}
variable "users_table_name" {}
variable "tasks_table_name" {}
variable "log_group_name" {}