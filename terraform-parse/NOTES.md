## NOTES — Terraform-Parse take-home

This file documents key implementation decisions, fixes made, multi-environment approach, and where AI was used.

### 1) API service creation (terraform_parse_service)
- Language: Node.js + Express for a minimal, dependency-light HTTP service.
- Endpoints:
	- `POST /render` — accepts the payload and returns a generated Terraform file as plain text.
	- `POST /render_and_write` — renders Terraform and writes it to the repository `terraform/s3_bucket.tf` (creates the folder if missing).
- Design notes:
	- The renderer module (`src/renderer.js`) focuses on a single resource type (S3 bucket). It accepts a `properties` map and performs minimal escaping and validation.
	- Input validation is intentionally small to keep the service minimal; required fields like `bucket-name` are checked and will return an error on missing values.
	- The service returns plain-text TF for easy download and also provides a small header `X-Filename` when returning the file content.

### 2) Terraform fixes & improvements
- Replaced unsafe/hardcoded defaults:
	- Removed a hardcoded public S3 bucket name and `public-read` ACL. Bucket name is now configurable via `s3_bucket_name` and defaults to `${cluster_name}-${environment}-static`.
	- Default ACL set to `private` and server-side encryption (SSE) enabled.
- Safety and lifecycle:
	- Enabled `versioning` and added a lifecycle rule and `force_destroy` toggle.
	- Added `aws_s3_bucket_acl` resource as requested.
- Configurability for multi-env:
	- Exposed `cluster_version`, `node_groups`, and `common_tags` variables so node sizing and cluster config can be configured per environment.
	- Added S3-specific variables: `s3_bucket_name`, `s3_acl`, `s3_force_destroy`, `s3_lifecycle_days`, `s3_noncurrent_days`, and `s3_tags`.
- Outputs:
	- Added S3 outputs (id and ARN) and more EKS outputs (CA data) to make integration with downstream modules easier.

### 3) Helm fixes
- Resource requests/limits:
	- Added `frontend.resources` and `backend.resources` in `values.yaml` with conservative defaults. Templates consume these values and fall back to a global `resources` block.
- Probes:
	- Added configurable liveness and readiness probes for both frontend and backend (HTTP GET on configured ports, path default `/`).
	- Probe timing/config is parameterized in `values.yaml` so you can tune dev vs prod.
- Horizontal Pod Autoscaling (HPA):
	- Enhanced backend HPA with both CPU and memory-based scaling metrics.
	- Set target utilization thresholds to 75% for both CPU and memory to balance responsiveness and stability.
	- Made HPA fully configurable via `backend.hpa` in values:
		- Configurable min/max replicas (defaults: 1-5)
		- Adjustable target utilization percentages for both CPU and memory
		- Values can be overridden per environment (e.g., higher limits in production)
- Template improvements:
	- Deployment templates were updated to pull replica counts, image repo/tag, ports, resources, and probes from values — making the chart more flexible.
  - Image tagging and labels fixes:
      - Pinned image tags: changed uses of `latest` to explicit image tags in `values.yaml` (for example `nginx:1.16.0`) to avoid unpredictable image changes during deploys. Pinning images improves reproducibility and makes rollbacks easier.
      - Service label fix: fixed the frontend service label selector (in `helm/templates/frontend-service.yaml`) so it matches the deployment labels (`app: frontend-app`) — this corrects a routing issue where the Service previously did not select the Deployment pods.
      - Service type configurability: Service types for frontend and backend are now driven by `helm/values.yaml` (`frontend.service.type` and `backend.service.type`). Set these to `ClusterIP`, `LoadBalancer`, or `NodePort` per environment; the templates default to `ClusterIP` if not set. For cloud deployments that require external IPs, set the service type to `LoadBalancer` and ensure your cluster provider supports it.
### 4) Multi-environment approach
- Implemented the *Environment folders* approach (dev / staging / prod) — each folder contains an isolated Terraform configuration (copied from root). This gives maximum isolation and a simple mental model: env = folder.
	- Pros: simple, isolated state, low risk for accidental cross-env changes.
	- Cons: duplication if you change core infra often. A recommended follow-up is to refactor into a shared module and small env wrappers that call it.
- Per-environment suggestions:
	- Use a remote backend (S3 + DynamoDB) per environment for state and locking. I can add `backend-*.conf` examples if you want.
	- Keep `terraform.tfvars` in each environment with only the values that differ (cluster name, VPC/subnets, tags, sizing).

### 5) How to run (short)
- Service (local):
	```bash
	cd terraform_parse_service
	npm install
	npm start
	# POST /render or /render_and_write as needed
	```
- Terraform (per env):
	```bash
	cd terraform/environments/dev
	terraform init
	terraform plan
	terraform apply
	```
- Helm (render):
	```bash
	helm template ./helm --values helm/values.yaml
	```

### 6) AI usage
During this technical test, I used GitHub Copilot as an AI assistant to help accelerate the process.

I first cloned the provided repository to my local machine and opened it using Visual Studio Code.

Copilot was used to generate the initial API implementation based on the given requirements and instructions.

For the Terraform section, I utilized Copilot to suggest structural improvements and enhance readability.

For the Helm section, Copilot assisted in refactoring the YAML manifests to support reusable values in Helm templates. I also performed a double-check by running helm install tripla ./helm --dry-run --debug locally using Kind to ensure the manifests rendered correctly.

All AI-generated code was manually reviewed, verified, and adjusted to ensure it aligned with the overall repository structure and the test requirements


