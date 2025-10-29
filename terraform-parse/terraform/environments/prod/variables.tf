variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "cluster_name" {
  type    = string
  default = "tripla-prod-eks"
}

variable "cluster_version" {
  type    = string
  default = "1.25"
}

variable "node_groups" {
  type = map(object({
    desired_capacity = number
    instance_type    = string
  }))
  default = {
    default = {
      desired_capacity = 3
      instance_type    = "t3.large"
    }
  }
}

variable "vpc_id" {
  type = string
  default = ""
}

variable "subnet_ids" {
  type = list(string)
  default = []
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "common_tags" {
  type    = map(string)
  default = {}
}

// S3 related vars
variable "s3_bucket_name" {
  type    = string
  default = ""
}

variable "s3_acl" {
  type    = string
  default = "private"
}

variable "s3_force_destroy" {
  type    = bool
  default = false
}

variable "s3_lifecycle_days" {
  type    = number
  default = 365
}

variable "s3_noncurrent_days" {
  type    = number
  default = 90
}

variable "s3_tags" {
  type    = map(string)
  default = {}
}
