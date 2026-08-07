terraform {
  required_version = ">= 1.6"
  required_providers {
    aws    = { source = "hashicorp/aws", version = "~> 6.0" }
    random = { source = "hashicorp/random", version = "~> 3.6" }
  }
}

module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "4.2.0"
}

provider "aws" {
  region = var.region

# CM-6, configuration settings

default_tags {
  tags = {
    Project = "<insert name>"
    Environment = "<dev, staging, prod>"
    ManagedBy = "<who manages this>"
    ComplianceScope = "<pci, sox, hippa, etc>" 
  }
 }
}

resource "random_id" "suffix" {
  byte_length = 4
}

# Created a user to perform the steps; this isn't needed if you already have users in your AWS instance

resource "aws_iam_user" "kms_admin" {
  name = "kms-admin-test"
}

locals {
  primary_name = "${var.project_name}-${var.environment}-data-${random_id.suffix.hex}"
  log_name     = "${var.project_name}-${var.environment}-logs-${random_id.suffix.hex}"
}
# Primary Bucket
resource "aws_s3_bucket" "primary" {
  bucket = local.primary_name
}

# CM-6, configuration settings

resource "aws_s3_bucket_versioning" "primary" {
  bucket = aws_s3_bucket.primary.id

    versioning_configuration {
    status = "Enabled"
    }
}
# AC-3, access enforcement, blocking public access

resource "aws_s3_bucket_public_access_block" "primary" {
  bucket = aws_s3_bucket.primary.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
  
# SC-28, protection of information at rest. 

resource "aws_s3_bucket_server_side_encryption_configuration" "primary" {
  bucket = aws_s3_bucket.primary.id

rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
      # This is used when the algorithm isn't defined - kms_master_key_id = module.kms.key_arn
    }
  }
}

resource "aws_s3_bucket" "log" {
  bucket = local.log_name
}

# SC-28, protection of information at rest. 

resource "aws_s3_bucket_server_side_encryption_configuration" "log" {
  bucket = aws_s3_bucket.log.id

rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
      # this is needed if the algorithm isn't defined above - kms_master_key_id = module.kms.key_arn
    }
  }
}

# CM-6, configuration settings 

resource "aws_s3_bucket_versioning" "log" {
  bucket = aws_s3_bucket.log.id

    versioning_configuration {
    status = "Enabled"
    }
}

# AC-3, access enforcement to block public access

resource "aws_s3_bucket_public_access_block" "log" {
  bucket = aws_s3_bucket.log.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# AC-3, access enforcement

resource "aws_s3_bucket_ownership_controls" "log" {
  bucket = aws_s3_bucket.log.id

  rule {
    object_ownership = "BucketOwnerPreferred"
    # The ownership changes based on the need. Review the Terraform registry for AWS
  }
}

# AU-3 and AU-6, audit record content and review

resource "aws_s3_bucket_acl" "log" {
  depends_on = [
    aws_s3_bucket_ownership_controls.log,
    aws_s3_bucket_public_access_block.log,
  ]

  bucket = aws_s3_bucket.log.id
  acl = "log-delivery-write"
}

resource "aws_s3_bucket_logging" "primary" {
  bucket = aws_s3_bucket.primary.id

  target_bucket = aws_s3_bucket.log.id
  target_prefix = "log/"
  target_object_key_format {
    partitioned_prefix {
      partition_date_source = "EventTime"
    }
  }
}
