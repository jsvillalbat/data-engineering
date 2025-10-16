terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  project = "encoded-region-475220-t5"
  region  = "us-central1"
}

resource "google_storage_bucket" "demo-bucket" {
  name          = "encoded-region-475220-t5-terra-bucket"
  location      = "US"

  # Optional, but recommended settings:
  storage_class = "STANDARD"
  uniform_bucket_level_access = true

  versioning {
    enabled     = true
  }

  lifecycle_rule {
    action {
      type = "AbortIncompleteMultipartUpload"
    }
    condition {
      age = 1  // days
    }
  }

  force_destroy = true
}