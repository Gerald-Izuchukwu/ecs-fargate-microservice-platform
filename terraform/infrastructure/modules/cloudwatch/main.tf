resource "aws_cloudwatch_log_group" "ecs_tasks" {
  name              = "/ecs/${var.project_name}-${var.environment}"
  retention_in_days = 7  # Keep logs for 7 days

  tags = {
    Name        = "${var.project_name}-ecs-logs"
    Environment = var.environment
  }
}