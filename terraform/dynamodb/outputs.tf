output "users_table_id" {
  value = aws_dynamodb_table.users.id
}

output "tasks_table_id" {
  value = aws_dynamodb_table.tasks.id
}

output "users_table_arn" {
  value = aws_dynamodb_table.users.arn
}

output "tasks_table_arn" {
  value = aws_dynamodb_table.tasks.arn
}

output "users_table_name" {
  value = aws_dynamodb_table.users.name
}

output "tasks_table_name" {
  value = aws_dynamodb_table.tasks.name
}