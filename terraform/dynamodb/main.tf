resource "aws_dynamodb_table" "users" {
  name         = "${var.project_name}-users-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userID"

  attribute {
    name = "userID"
    type = "S" # S is for string
  }
  tags = {
    Name        = "${var.project_name}-users"
    Environment = var.environment
  }

}

resource "aws_dynamodb_table" "tasks" {
  name         = "${var.project_name}-tasks-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "taskID"

  attribute {
    name = "taskID"
    type = "S"
  }

  attribute {
    name = "userID"
    type = "S"
  }
  global_secondary_index {
    name            = "UserIdIndex"
    hash_key        = "userID"
    projection_type = "ALL"
  }
  tags = {
    Name        = "${var.project_name}-tasks"
    Environment = var.environment
  }
}

