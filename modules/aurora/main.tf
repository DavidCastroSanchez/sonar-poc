# Random string for the password
resource "random_password" "aurora_password" {
  length  = 16
  special = false
}

# Store the password in AWS Secrets Manager
resource "aws_secretsmanager_secret" "aurora_secret" {
  name = "${var.project_name}-aurora-secret"
}

resource "aws_secretsmanager_secret_version" "aurora_secret_version" {
  secret_id = aws_secretsmanager_secret.aurora_secret.id
  secret_string = jsonencode({
    username = "admin"
    password = random_password.aurora_password.result
  })
}

# Security group for Aurora
resource "aws_security_group" "aurora" {
  name        = "${var.project_name}-aurora-sg"
  description = "Security group for Aurora cluster"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow MySQL access from ECS tasks"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = var.allowed_security_groups
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# Aurora Parameter Group
resource "aws_rds_cluster_parameter_group" "aurora" {
  name        = "${var.project_name}-aurora-pg"
  family      = "aurora-mysql8.0"
  description = "Aurora cluster parameter group"

  parameter {
    name  = "slow_query_log"
    value = "1"
  }
}

# Aurora DB Instance Parameter Group
resource "aws_db_parameter_group" "aurora" {
  name        = "${var.project_name}-aurora-instance-pg"
  family      = "aurora-mysql8.0"
  description = "Aurora DB instance parameter group"
}

# Aurora Cluster
resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = "${var.project_name}-aurora-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "8.0.mysql_aurora.3.09.0"
  database_name           = replace(var.project_name, "-", "")
  master_username         = jsondecode(aws_secretsmanager_secret_version.aurora_secret_version.secret_string)["username"]
  master_password         = jsondecode(aws_secretsmanager_secret_version.aurora_secret_version.secret_string)["password"]
  db_subnet_group_name    = var.db_subnet_group_name
  vpc_security_group_ids  = [aws_security_group.aurora.id]

  storage_encrypted       = true
  skip_final_snapshot     = var.skip_final_snapshot
  final_snapshot_identifier = "${var.project_name}-final-snapshot"

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora.name

  availability_zones      = var.availability_zones

  backup_retention_period = var.backup_retention_period
  preferred_backup_window = "03:00-04:00"
  
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  
  copy_tags_to_snapshot   = true

  tags = var.tags
}

# Aurora Instances
resource "aws_rds_cluster_instance" "aurora_instances" {
  count               = var.instance_count
  identifier          = "${var.project_name}-aurora-instance-${count.index + 1}"
  cluster_identifier  = aws_rds_cluster.aurora.id
  instance_class      = var.instance_class
  engine              = aws_rds_cluster.aurora.engine
  engine_version      = aws_rds_cluster.aurora.engine_version

  db_parameter_group_name    = aws_db_parameter_group.aurora.name
  db_subnet_group_name       = var.db_subnet_group_name
  auto_minor_version_upgrade = true
  
  publicly_accessible    = false
  
  tags = var.tags
}
