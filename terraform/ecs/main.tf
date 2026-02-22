# ECS Cluster (just a logical grouping)
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"  # Enable CloudWatch Container Insights
  }

  tags = {
    Name        = "${var.project_name}-cluster"
    Environment = var.environment
  }
}

# Security Group for ECS Tasks
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.project_name}-ecs-tasks-sg"
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id

  # Allow inbound from ALB only
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
    description     = "Allow traffic from ALB"
  }

  # Allow all outbound (for NAT gateway, DynamoDB, etc.)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.project_name}-ecs-tasks-sg"
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc"  # Required for Fargate
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"   # 0.25 vCPU
  memory                   = "512"   # 512 MB

  # The execution role (for ECS to pull image, write logs)
  execution_role_arn = var.ecs_execution_role_arn
  
  # The task role (for your app to access DynamoDB)
  task_role_arn = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "api"
      image     = "${var.ecr_repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "USERS_TABLE"
          value = var.users_table_name
        },
        {
          name  = "TASKS_TABLE"
          value = var.tasks_table_name
        },
        {
          name  = "AWS_REGION"
          value = var.aws_region
        },
        {
          name  = "PORT"
          value = "3000"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.log_group_name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "api"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = {
    Name        = "${var.project_name}-task-definition"
    Environment = var.environment
  }
}

# ECS Service
resource "aws_ecs_service" "app" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 2  # Run 2 tasks for high availability
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids  # Tasks run in private subnets
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false  # No public IP needed (use NAT gateway)
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "api"
    container_port   = 3000
  }

  # Wait for ALB listener to be created before creating service
  depends_on = [var.alb_listener_arn]

  tags = {
    Name        = "${var.project_name}-service"
    Environment = var.environment
  }
}