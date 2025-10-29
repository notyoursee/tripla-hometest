This folder contains an isolated terraform setup for the `dev` environment.

How to run:

```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
```

Edit `terraform.tfvars` to set VPC and subnet IDs.
