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

resource "aws_cloudwatch_log_group" "flow_logs" {
 name              = "/aws/vpc-flow-logs/${var.project_name}"
 retention_in_days = var.flow_log_retention_days
 tags              = var.tags
}




resource "aws_iam_role" "flow_logs" {
 name = "${var.project_name}-vpc-flow-logs-role"


 assume_role_policy = jsonencode({
   Version = "2012-10-17",
   Statement = [{
     Effect = "Allow",
     Principal = {
       Service = "vpc-flow-logs.amazonaws.com"
     },
     Action = "sts:AssumeRole"
   }]
 })


 tags = var.tags
}


resource "aws_iam_role_policy" "flow_logs" {
 name = "${var.project_name}-vpc-flow-logs-policy"
 role = aws_iam_role.flow_logs.id


 policy = jsonencode({
   Version = "2012-10-17",
   Statement = [{
     Effect = "Allow",
     Action = [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents",
       "logs:DescribeLogGroups",
       "logs:DescribeLogStreams"
     ],
     Resource = "${aws_cloudwatch_log_group.flow_logs.arn}:*"
   }]
 })
}


resource "aws_flow_log" "vpc_flow_logs" {
 iam_role_arn    = aws_iam_role.flow_logs.arn
 log_destination = aws_cloudwatch_log_group.flow_logs.arn
 traffic_type    = "ALL"
 vpc_id          = module.vpc.vpc_id
 tags            = var.tags
}
