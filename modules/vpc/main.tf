data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name = "opt-in-status"
    values = [
      "opt-in-not-required"
    ]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.project_name
  cidr = var.vpc_cidr
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets

  enable_nat_gateway           = true
  single_nat_gateway           = var.single_nat_gateway
  one_nat_gateway_per_az       = !var.single_nat_gateway
  enable_dns_support           = true
  enable_dns_hostnames         = true
  create_database_subnet_group = true

  tags = var.tags
}