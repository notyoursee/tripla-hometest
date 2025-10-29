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

# Intentionally simplistic EKS module usage (hardcoded values)
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.0.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.25"
  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids
  node_groups = {
    default = {
      desired_capacity = 2
      instance_type    = "t3.medium"
    }
  }

  tags = {
    Environment = var.environment
  }
}

# Buggy S3 bucket (hardcoded name, public ACL, no lifecycle)
resource "aws_s3_bucket" "static_assets" {
  bucket = "tripla-static-assets" # hardcoded
  acl    = "public-read"          # insecure
  tags = {
    Env = var.environment
  }
}
