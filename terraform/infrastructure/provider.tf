terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
  bucket         = "ecs-fargate-microservice-platform-bucket"
  key            = "infrastructure/terraform.tfstate"
  region         = "us-east-1"
  dynamodb_table = "ecs-fargate-microservice-platform-table"
  encrypt        = true
}

  required_version = ">= 1.0"
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

