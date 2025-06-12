resource "aws_s3_bucket" "logging" {
  bucket = var.logging_bucket_name

  force_destroy = var.force_destroy

  tags = merge(var.tags, {
    Name = var.logging_bucket_name
  })
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.logging.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "logging_block" {
  bucket = aws_s3_bucket.logging.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

