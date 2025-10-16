# Terraform (GCP) setup

Use the Terraform module in `terraform-demo/` to provision a Google Cloud Storage bucket.

### Prerequisites
- Terraform 1.3+ installed
- A GCP project and a service account with Storage Admin permissions
- A service account key file saved at `terraform-demo/keys/my_creds.json`

### Configure provider settings
Edit `terraform-demo/main.tf` to set your values:
- `provider "google"` → `project` and `region`
- `resource "google_storage_bucket" "demo-bucket"` → unique bucket `name`

Example relevant lines:
```12:18:/Users/juan.villalba/Desktop/data-engineering/terraform-demo/main.tf
provider "google" {
  project = "<your-project-id>"
  region  = "us-central1"
}
```

```15:21:/Users/juan.villalba/Desktop/data-engineering/terraform-demo/main.tf
resource "google_storage_bucket" "demo-bucket" {
  name     = "<unique-bucket-name>"
  location = "US"
  # ... other settings ...
}
```

### Authenticate
Export your credentials so Terraform can authenticate:
```bash
export GOOGLE_APPLICATION_CREDENTIALS="$(pwd)/terraform-demo/keys/my_creds.json"
```

Alternatively, if you use gcloud and Application Default Credentials:
```bash
gcloud auth application-default login
```

### Initialize and plan/apply
Run all commands from the `terraform-demo/` directory:
```bash
cd terraform-demo
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

On success, a GCS bucket will be created with versioning and uniform bucket-level access enabled. `force_destroy = true` is set, allowing bucket deletion even if it contains objects.

### Update configuration
If you change `main.tf`, re-run:
```bash
terraform plan -out=tfplan && terraform apply tfplan
```

### Destroy resources
Tear down everything created by this configuration:
```bash
terraform destroy
```

### Notes
- Provider pinned in `.terraform.lock.hcl` to `hashicorp/google` `4.51.0`.
- State is local by default (`terraform.tfstate` in `terraform-demo/`). Consider a remote backend for team use.