module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
  aws_region   = var.aws_region
}

module "dynamodb" {
  source       = "./modules/dynamodb"
  project_name = var.project_name
  environment  = var.environment
}

# module "ecr" {
#   source       = "./ecr"
#   project_name = var.project_name
#   environment  = var.environment
# }

module "iam" {
  source          = "./modules/iam"
  project_name    = var.project_name
  users_table_arn = module.dynamodb.users_table_arn
  tasks_table_arn = module.dynamodb.tasks_table_arn
}

module "cloudwatch" {
  source       = "./modules/cloudwatch"
  project_name = var.project_name
  environment  = var.environment
}

module "alb" {
  source            = "./modules/alb"
  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}

module "ecs" {
  source                 = "./modules/ecs"
  project_name           = var.project_name
  environment            = var.environment
  aws_region             = var.aws_region
  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnet_ids
  alb_security_group_id  = module.alb.alb_security_group_id
  target_group_arn       = module.alb.target_group_arn
  alb_listener_arn       = module.alb.alb_listener_arn
  ecs_execution_role_arn = module.iam.ecs_execution_role_arn
  ecs_task_role_arn      = module.iam.ecs_task_role_arn
  # ecr_repository_url     = module.ecr.repository_url
  users_table_name       = module.dynamodb.users_table_name
  tasks_table_name       = module.dynamodb.tasks_table_name
  log_group_name         = module.cloudwatch.log_group_name
}