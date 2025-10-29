This folder contains an isolated terraform setup for the `prod` environment.

How to run:

```bash
cd terraform/environments/prod
terraform init
terraform plan
terraform apply
```

Edit `terraform.tfvars` to set VPC and subnet IDs.
