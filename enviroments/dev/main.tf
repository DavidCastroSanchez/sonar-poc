provider "aws" {
  region = var.aws_region
}

locals {
  common_tags = {
    Owner       = var.owner
    Project     = var.project_name
    Environment = var.environment
  }
}

module "vpc" {
  source = "../../modules/vpc"
  
  project_name     = "${var.project_name}-${var.environment}"
  vpc_cidr         = var.vpc_cidr
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets
  single_nat_gateway = true
  
  tags = local.common_tags
}

module "s3_logging" {
  source = "../../modules/s3"
  
  logging_bucket_name = "${var.logging_bucket_name}-${var.environment}"
  
  tags = local.common_tags
}

module "alb" {
  source = "../../modules/alb"
  
  project_name = "${var.project_name}-${var.environment}"
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.public_subnets
  
  tags = local.common_tags
}

module "aurora" {
  source = "../../modules/aurora"
  
  project_name = "${var.project_name}-${var.environment}"
  vpc_id       = module.vpc.vpc_id
  db_subnet_group_name = module.vpc.database_subnet_group_name
  availability_zones   = module.vpc.azs
  allowed_security_groups = [module.ecs_cluster.security_group_id]
  instance_class      = "db.t3.medium" 
  instance_count      = 3              
  skip_final_snapshot = true          
  
  tags = local.common_tags
}

module "ecs_cluster" {
  source = "../../modules/ecs-cluster"
  
  project_name = "${var.project_name}-${var.environment}"
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnets
  alb_security_group_id = module.alb.security_group_id
  instance_type   = "t3.small"  
  desired_capacity = 2          
  min_size        = 1
  max_size        = 4
  
  tags = local.common_tags
}

module "ecs_service" {
  source = "../../modules/ecs-service"
  
  project_name    = "${var.project_name}-${var.environment}"
  aws_region      = var.aws_region
  cluster_id      = module.ecs_cluster.cluster_id
  cluster_name    = module.ecs_cluster.cluster_name
  subnet_ids      = module.vpc.private_subnets
  security_group_id = module.ecs_cluster.security_group_id
  target_group_arn = module.alb.target_group_arn
  lb_listener_arn  = module.alb.lb_listener_arn
  
  container_image = "nginx:latest"
  container_environment = [
    {
      name  = "ENVIRONMENT"
      value = var.environment
    }
  ]
  
  task_cpu       = "256"
  task_memory    = "512"
  desired_count  = 2 
  
  autoscaling_min_capacity = 1
  autoscaling_max_capacity = 4
  log_retention_days = 14  
  
  tags = local.common_tags
}

provider "aws" {
  alias  = "dr"
  region = var.dr_region
}

module "dr" {
  source = "../../modules/dr"
  count  = var.enable_dr ? 1 : 0
  
  providers = {
    aws    = aws
    aws.dr = aws.dr
  }
  
  project_name        = "${var.project_name}-${var.environment}"
  aurora_cluster_arn  = module.aurora.cluster_arn
  backup_vault_name   = "${var.project_name}-${var.environment}-vault"
  backup_retention_days = 7 
  
  tags = local.common_tags
}