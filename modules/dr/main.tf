data "aws_caller_identity" "current" {}

terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.dr]
    }
  }
}


resource "aws_backup_vault" "main" {
  name        = var.backup_vault_name
  kms_key_arn = var.kms_key_arn
  
  tags = var.tags
}

resource "aws_backup_vault" "dr_copy_target" {
  provider = aws.dr

  name = "${var.backup_vault_name}-dr"
  
  tags = var.tags
}

resource "aws_backup_plan" "aurora_daily" {
  name = "${var.project_name}-aurora-daily-plan"

  rule {
    rule_name         = "daily-aurora-backup"
    target_vault_name = aws_backup_vault.main.name
    schedule          = var.backup_schedule
    start_window      = 60
    completion_window = 180

    lifecycle {
      delete_after = var.backup_retention_days
    }

    copy_action {
      destination_vault_arn = aws_backup_vault.dr_copy_target.arn
    }
  }
  
  tags = var.tags
}

resource "aws_iam_role" "backup_role" {
  name = "${var.project_name}-aws-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "backup.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
  
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "backup_role_policy" {
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_backup_selection" "aurora" {
  name         = "${var.project_name}-aurora-selection"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.aurora_daily.id

  resources = [
    var.aurora_cluster_arn
  ]
}
