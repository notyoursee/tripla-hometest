function q(s) {
  if (s === undefined || s === null) return '';
  return String(s).replace(/"/g, '\\"');
}

function renderTerraform(props) {
  const region = props['aws-region'] || props.aws_region || 'eu-west-1';
  const bucket = props['bucket-name'] || props.bucket_name;
  const acl = props['acl'] || 'private';

  if (!bucket) throw new Error('bucket-name is required');

  const provider = `provider "aws" {
  region = "${q(region)}"
}
`;

  const bucketRes = `resource "aws_s3_bucket" "bucket" {
  bucket = "${q(bucket)}"
  acl    = "${q(acl)}"

  tags = {
    ManagedBy = "terraform-parse-service"
  }
}
`;

  const aclRes = `resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "${q(acl)}"
}
`;

  const output = `output "bucket_arn" {
  value = aws_s3_bucket.bucket.arn
}
`;

  return [provider, bucketRes, aclRes, output].join('\n');
}

module.exports = { renderTerraform };
