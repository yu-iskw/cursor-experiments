resource "google_artifact_registry_repository" "pool_images" {
  project       = var.project_id
  location      = var.region
  repository_id = var.repository_id
  description   = "Container images for Cursor self-hosted worker pools"
  format        = "DOCKER"
}
