# Credentials
# -----------

# resource "aws_secretsmanager_secret" "secret" {
#   name = "dummy-user"
# }

# # The secret (password) 
# resource "aws_secretsmanager_secret_version" "v" {
#   secret_id     = aws_secretsmanager_secret.secret.id
#   secret_string = jsonencode(var.secret)
# }

# NOTE:
#   If you delete the resource, there will be a retention period, 
#   before you can create the same resource, using the same secret. (same name)