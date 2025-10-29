# Terraform-Parse (renderer + infra)

This workspace contains a small service that renders an HTTP JSON payload into a Terraform file for creating an S3 bucket, plus example Terraform and Helm artifacts used for the take-home assignment.

This README explains how to build, test and run the `terraform_parse_service` locally, how to exercise its endpoints, and where to find the Terraform and Helm example deployments.

## Prerequisites
- Node.js (16+) and npm installed locally. Use Homebrew or nvm on macOS.
- (Optional) Helm and a Kubernetes cluster (minikube/kind) to deploy the Helm chart.
- (Optional) Terraform to run the example infra.

## Service: terraform_parse_service
Location: `terraform_parse_service/`

This is a minimal Node/Express service that accepts POST requests and renders Terraform for an S3 bucket. It exposes two endpoints:

- `POST /render` — returns the generated Terraform as plain text
- `POST /render_and_write` — renders and writes the Terraform file to the repo `terraform/` folder as `s3_bucket.tf`

### Payload format
Send JSON with this shape in the request body:

```json
{
	"payload":{
		"properties":{
			"aws-region":"eu-west-1",
			"acl":"private",
			"bucket-name":"tripla-bucket"
		}
	}
}
```

### Install and run (local)
1. Change into the service folder and install dependencies:

```bash
cd terraform_parse_service
npm install
```

2. Start the service:

```bash
npm start
# By default the service listens on port 3001
```

3. Health check:

```bash
curl http://localhost:3001/health
```

### Examples

Render terraform and print it:

```bash
curl -sS -X POST http://localhost:3001/render \
	-H "Content-Type: application/json" \
	-d '{"payload":{"properties":{"aws-region":"eu-west-1","acl":"private","bucket-name":"tripla-bucket"}}}'
```

Render and write the file to `terraform/s3_bucket.tf`:

```bash
curl -sS -X POST http://localhost:3001/render_and_write \
	-H "Content-Type: application/json" \
	-d '{"payload":{"properties":{"aws-region":"eu-west-1","acl":"private","bucket-name":"tripla-bucket"}}}'
```

The `render_and_write` endpoint returns JSON with the written file path.

### Quick test without starting HTTP server
If you only want to test the renderer logic (no HTTP), run the included script from the repository root (requires Node):

```bash
node terraform_parse_service/test_render.js
```

It prints the generated Terraform to stdout.

## Terraform example (multi-environment)
Location: `terraform/`

This repository includes example Terraform code and three isolated environment folders under `terraform/environments/`:
- `dev/`
- `staging/`
- `prod/`

Each environment folder is an independent Terraform configuration you can run separately. Typical workflow (for `dev`):

```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
```

Notes:
- Fill `terraform.tfvars` in each environment with `vpc_id` and `subnet_ids` before applying EKS.
- Use a remote backend (S3 + DynamoDB) per environment in production to avoid state collisions. You can pass backend config at `terraform init -backend-config=...`.

Important: AWS credentials required

- Terraform will fail during `terraform plan`/`apply` if valid AWS credentials are not available on your machine. Common error looks like: "no valid credential sources for Terraform AWS Provider found." To fix locally, provide credentials using one of these options:
	- Configure the AWS CLI (recommended):
		```bash
		aws configure --profile myprofile
		export AWS_PROFILE=myprofile
		```
	- Export environment variables (short-lived/test):
		```bash
		export AWS_ACCESS_KEY_ID=AKIA...
		export AWS_SECRET_ACCESS_KEY=...
		export AWS_SESSION_TOKEN=... # if using temporary creds
		```
	- Use a secure helper such as `aws-vault`:
		```bash
		brew install aws-vault
		aws-vault add myprofile
		aws-vault exec myprofile -- terraform plan
		```
	After configuring credentials, re-run `terraform init` (optional) and `terraform plan`.

## Helm chart
Location: `helm/`

Small Helm chart with `frontend` and `backend` deployments. I added resource requests/limits, and liveness/readiness probes in `values.yaml` and templates. To render templates locally:

```bash
helm template ./helm --values helm/values.yaml
```

To install into a cluster (minikube/kind):

```bash
helm install test-release ./helm --values helm/values.yaml
kubectl get pods
kubectl describe pod <pod>
```

## Troubleshooting
- If `npm install` or `node` commands fail, install Node.js (Homebrew: `brew install node` or preferred nvm workflow).
- If `terraform init` complains about backend, create appropriate backend configuration or remove backend block before testing locally.


