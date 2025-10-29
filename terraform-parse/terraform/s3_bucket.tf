provider "aws" {
  region = "eu-west-1"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "tripla-bucket"
  acl    = "private"

  tags = {
    ManagedBy = "terraform-parse-service"
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}

output "bucket_arn" {
  value = aws_s3_bucket.bucket.arn
}
