# Security Group for ALB
resource "aws_security_group" "alb" {
  name        = "ec-fargate-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  # Allow HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP inbound traffic"
  }

  # Allow HTTPS from anywhere (optional for now)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS inbound traffic"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "ecs-fargate-alb"
  internal           = false  # Internet-facing
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids  # ALB must be in public subnets

  enable_deletion_protection = false  # Set to true in production

  tags = {
    Name        = "${var.project_name}-alb"
    Environment = var.environment
  }
}

# Target Group (where ALB forwards traffic)
resource "aws_lb_target_group" "app" {
  name        = "ec-fargate-tg"
  port        = 3000  # Your container port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"  # CRITICAL: Must be "ip" for Fargate

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/health"  # Your health endpoint
    protocol            = "HTTP"
    matcher             = "200"
  }

  # Deregistration delay (how long to wait before removing unhealthy tasks)
  deregistration_delay = 30

  tags = {
    Name = "${var.project_name}-tg"
  }
}

# Listener (ALB listens on port 80)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}