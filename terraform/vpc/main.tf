resource "aws_vpc" "ecs_fargate" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
      Name = "ECS-Fargate-VPC"
    }
}

resource "aws_subnet" "main" {
    count = 2

    vpc_id = aws_vpc.ecs_fargate.id
    # cidr_block = "10.0.1.0/24"
    cidr_block = cidrsubnet("10.0.0.0/16", 8, count.index)
    map_public_ip_on_launch = true

    tags = {
      Name = "ECS-Fargate-Subnet"
    }
}

resource "aws_subnet" "private" {
    count = 2
    vpc_id = aws_vpc.ecs_fargate.id
    cidr_block = cidrsubnet("10.0.0.0/16", 8, count.index + 10)

    tags = {
      Name = "ECS-Fargate-Subnet"
    }
  
}

resource "aws_internet_gateway" "name" {
    vpc_id = aws_vpc.ecs_fargate.id

    tags = {
      Name = "ECS-Fargate-Internet-Gateway"
    }
}