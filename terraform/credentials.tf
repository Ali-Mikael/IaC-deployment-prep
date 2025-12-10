# Credentials
# -----------

# Secret will be under this name
resource "aws_secretsmanager_secret" "secret" {
  name = "dummy-user"
}

# The secret
resource "aws_secretsmanager_secret_version" "v" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = jsonencode(var.secret)
}