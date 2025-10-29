This folder contains an isolated terraform setup for the `staging` environment.

How to run:

```bash
cd terraform/environments/staging
terraform init
terraform plan
terraform apply
```

Edit `terraform.tfvars` to set VPC and subnet IDs.
