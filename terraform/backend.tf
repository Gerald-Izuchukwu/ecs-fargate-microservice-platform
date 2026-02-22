terraform {
  backend "s3" {
    bucket = "ecs-fargate-microservice-bucket"
    key    = "ecs-fargate-microservice-platform/terraform.tfstate"
    region = "eu-north-1"
  }
}