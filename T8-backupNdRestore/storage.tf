# Storage
# -------
resource "aws_s3_bucket" "b" {
  for_each = local.buckets

  bucket = each.value

  tags = {
    Name = "${each.key}-bucket"
  }
}

# Versioning buckets
# resource "aws_s3_bucket_versioning" "v" {
#   for_each = aws_s3_bucket.b
#   bucket   = each.value.id

#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# Lifecycle config for buckets
resource "aws_s3_bucket_lifecycle_configuration" "lc" {
  for_each = { for k, v in aws_s3_bucket.b : k => v if k == "private" }
  bucket   = each.value.id

  rule {
    id     = "cleanup-noncurrent"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

# Effectively making the public bucket -> Public
resource "aws_s3_bucket_public_access_block" "public" {
  bucket = aws_s3_bucket.b["public"].id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
#   for_each = aws_s3_bucket.b
#   bucket   = each.value.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }