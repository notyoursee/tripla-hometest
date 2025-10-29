// Environment: dev
// This file re-uses the root module files via copy for isolation.

// Copy of root main.tf for dev environment. Edit values in terraform.tfvars.
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

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.0.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids

  node_groups = var.node_groups

  tags = merge({
    Environment = var.environment
  }, var.common_tags)
}

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
