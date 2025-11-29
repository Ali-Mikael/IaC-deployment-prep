# Creating the vault for EC2 backups
resource "aws_backup_vault" "ec2_vault" {
  name = "ec2-backup-vault"
}

# The plan for the backups
resource "aws_backup_plan" "ec2_backup" {
  name = "ec2-backup-plan"

  rule {
    rule_name         = "instance-backup-rule"
    target_vault_name = aws_backup_vault.ec2_vault.name
    schedule          = "cron(0 10 * * ? *)"
    completion_window = 120

    lifecycle {
      delete_after = 14
    }
  }
}

# Selecting resource to back up
resource "aws_backup_selection" "ec2" {
  iam_role_arn = data.aws_iam_role.lab_role.arn
  name         = "ec2-backup-selection"
  plan_id      = aws_backup_plan.ec2_backup.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Backup"
    value = "Daily"
  }
}