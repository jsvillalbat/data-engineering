## NY Taxi data engineering project

A minimal NY Taxi data ingestion project using Dockerized Postgres, a Jupyter notebook for loading data, and a small Python script.

## Prerequisites
- Docker and Docker Compose installed
- Python 3.11 (or your existing `.venv` kernel)
- Parquet file present: `yellow_tripdata_2025-01.parquet`

## Start Postgres with Docker Compose
The compose file provisions:
- Postgres 13 on port `5432` with DB `ny_taxi`, user `root`, password `root`
- pgAdmin on `http://localhost:8080` (email `admin@admin.com`, password `root`)

Start services:
```bash
docker compose up -d
```

Data volume is mounted at `./ny_taxi_postgres_data`.

## Load data using the notebook
Open `ingestion_pipeline.ipynb` and run the cells in order. It will:
- Download the NY taxi data from https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page 
- Read `yellow_tripdata_2025-01.parquet` into a pandas DataFrame
- Create a SQLAlchemy engine to Postgres:
  - `postgresql://root:root@localhost:5432/ny_taxi`
- Create the `yellow_taxi_data` table (schema inferred from DataFrame)
- Append all rows into `yellow_taxi_data`
- Load taxi zones lookup into a `zones` table from:
  - `https://d37ci6vzurychx.cloudfront.net/misc/taxi_zone_lookup.csv`

Notes:
- Initial table create uses `ny_data.head(0).to_sql(..., if_exists="replace")`
- Full dataset load uses `ny_data.to_sql(..., if_exists="append")`

## Run the simple pipeline script
`pipeline.py` accepts a single argument (e.g., a day identifier) and prints a status message. Example:
```bash
python pipeline.py 2025-01-15
```

Expected output includes the provided argument and a success message.

## Accessing pgAdmin
- URL: `http://localhost:8080`
- Login: `admin@admin.com` / `root`
- Add a new server pointing to:
  - Host: `pg-database`
  - Port: `5432`
  - DB: `ny_taxi`
  - User: `root`
  - Password: `root`

## Connection details
- SQLAlchemy URL: `postgresql://root:root@localhost:5432/ny_taxi`
- Main tables created by the notebook:
  - `yellow_taxi_data`
  - `zones`

## Stop services
```bash
docker compose down
```

## Terraform (GCP) setup

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
