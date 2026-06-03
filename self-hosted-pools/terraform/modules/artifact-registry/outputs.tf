output "repository_id" {
  value = google_artifact_registry_repository.pool_images.repository_id
}

output "repository_url" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.pool_images.repository_id}"
}

output "worker_image_path" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.pool_images.repository_id}/${var.worker_image_name}"
}

output "autoscaler_image_path" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.pool_images.repository_id}/${var.autoscaler_image_name}"
}
