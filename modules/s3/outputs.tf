output "bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.logging.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.logging.arn
}

output "bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.logging.bucket_domain_name
}
