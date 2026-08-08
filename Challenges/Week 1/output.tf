output "bucket_name" {
  description = "Primary bucket name."
  value       = aws_s3_bucket.primary.id
}

output "bucket_arn" {
  description = "Primary bucket ARN."
  value       = aws_s3_bucket.primary.arn
}

output "log_bucket_name" {
  description = "Log bucket name."
  value       = aws_s3_bucket.log.id
}

output "primary_bucket_encryption_algorithm" {
  description = "The server-side encryption algorithm applied to the primary bucket"
  value = [
    for r in aws_s3_bucket_server_side_encryption_configuration.primary.rule :
    r.apply_server_side_encryption_by_default[0].sse_algorithm
  ][0]
}

output "primary_bucket_versioning_status" {
	description = "Versioning configuration"
	value = aws_s3_bucket_versioning.primary.versioning_configuration[0].status
}

output "primary_bucket_public_access_block { 
	description = "Access control applied to primary bucket"
	value = {
		aws_s3_bucket_public_access_block.primary.block_public_acls 
  		aws_s3_bucket_public_access_block.primary.block_public_policy
  		aws_s3_bucket_public_access_block.primary.ignore_public_acls
  		aws_s3_bucket_public_access_block.primary.restrict_public_buckets
	}
}

output "primary_bucket_logging_target" {
	description = "Target bucket to store access logs from the primary bucket"
	value = aws_s3_bucket_logging_primary.target_bucket
}
