# terraform_parse_service

Minimal service that accepts a JSON payload and returns a Terraform (.tf) file for creating an S3 bucket and ACL.

Start (after installing Node/npm and dependencies):

```bash
cd terraform_parse_service
npm install
npm start
```

POST to `http://localhost:3001/render` with body:

{
  "payload":{
    "properties":{
      "aws-region":"eu-west-1",
      "acl":"private",
      "bucket-name": "tripla-bucket"
    }
  }
}

Response: plain text Terraform (.tf)

New endpoint: `POST /render_and_write`
- This will render the Terraform and write it to the repo `terraform/` folder as `s3_bucket.tf`.
- Example:

```bash
curl -sS -X POST http://localhost:3001/render_and_write \
  -H "Content-Type: application/json" \
  -d '{"payload":{"properties":{"aws-region":"eu-west-1","acl":"private","bucket-name":"tripla-bucket"}}}'
```

Response will be JSON with the written file path.
