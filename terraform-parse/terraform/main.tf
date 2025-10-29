terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

// Configure EKS module using variables for multi-env and safe defaults
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.0.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids

  # forward node groups map so caller can control sizing per environment
  # Note: newer versions of the eks module expect `eks_managed_node_groups`
  # (previously called `node_groups`). Map our `var.node_groups` into the
  # module's `eks_managed_node_groups` input so older variable names still work.
  eks_managed_node_groups = var.node_groups

  tags = merge({
    Environment = var.environment
  }, var.common_tags)
}

// Safer S3 bucket configuration. Avoid hardcoded names and public ACL.
resource "aws_s3_bucket" "static_assets" {
  bucket = var.s3_bucket_name != "" ? var.s3_bucket_name : "${var.cluster_name}-${var.environment}-static"
  acl    = var.s3_acl

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    id      = "expire-old-objects"
    enabled = true
    expiration {
      days = var.s3_lifecycle_days
    }
    noncurrent_version_expiration {
      days = var.s3_noncurrent_days
    }
  }

  force_destroy = var.s3_force_destroy

  tags = merge({
    Env = var.environment,
    ManagedBy = "terraform"
  }, var.s3_tags)
}

resource "aws_s3_bucket_acl" "static_assets_acl" {
  bucket = aws_s3_bucket.static_assets.id
  acl    = var.s3_acl
}
