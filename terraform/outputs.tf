output "vpc_id" {
  value = module.vpc.vpc_id
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "users_table_name" {
  value = module.dynamodb.users_table_name
}

output "tasks_table_name" {
  value = module.dynamodb.tasks_table_name
}