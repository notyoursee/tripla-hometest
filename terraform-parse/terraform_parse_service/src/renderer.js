function q(s) {
  if (s === undefined || s === null) return '';
  return String(s).replace(/"/g, '\\"');
}

function renderTerraform(props) {
  const region = props['aws-region'] || props.aws_region || 'eu-west-1';
  const bucket = props['bucket-name'] || props.bucket_name;
  const acl = props['acl'] || 'private';

  if (!bucket) throw new Error('bucket-name is required');

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

  // Note: do not include provider configuration here so the generated TF
  // can be merged into an existing Terraform working directory that already
  // provides a provider "aws". If you need a standalone file, add the
  // provider manually or run the renderer with a separate flag.
  return [bucketRes, aclRes, output].join('\n');
}

module.exports = { renderTerraform };
