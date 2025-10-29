output "cluster_name" {
  value = module.eks.cluster_id
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "s3_bucket_id" {
  value = aws_s3_bucket.static_assets.id
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.static_assets.arn
}
