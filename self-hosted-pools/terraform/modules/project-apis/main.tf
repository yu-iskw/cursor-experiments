terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.49.0"
    }
  }
}

resource "google_project_service" "apis" {
  for_each = toset(var.services)

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}
