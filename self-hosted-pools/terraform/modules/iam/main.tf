resource "google_service_account" "worker" {
  project      = var.project_id
  account_id   = var.worker_sa_id
  display_name = "Cursor self-hosted worker pool runtime"
}

resource "google_service_account" "autoscaler" {
  project      = var.project_id
  account_id   = var.autoscaler_sa_id
  display_name = "Cursor worker pool autoscaler"
}

resource "google_project_iam_member" "worker_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.worker.email}"
}

resource "google_project_iam_member" "worker_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.worker.email}"
}

resource "google_secret_manager_secret_iam_member" "worker_cursor_key" {
  project   = var.project_id
  secret_id = var.cursor_api_key_secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.worker.email}"
}

resource "google_secret_manager_secret_iam_member" "worker_git_token" {
  count = var.git_token_secret_id != "" ? 1 : 0

  project   = var.project_id
  secret_id = var.git_token_secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.worker.email}"
}

resource "google_artifact_registry_repository_iam_member" "worker_ar_reader" {
  count = var.artifact_registry_repository_id != "" ? 1 : 0

  project    = var.project_id
  location   = var.region
  repository = var.artifact_registry_repository_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.worker.email}"
}

resource "google_secret_manager_secret_iam_member" "autoscaler_cursor_key" {
  project   = var.project_id
  secret_id = var.cursor_api_key_secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.autoscaler.email}"
}

resource "google_project_iam_member" "autoscaler_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.autoscaler.email}"
}

# Resize worker pool via Cloud Run Admin API.
resource "google_project_iam_member" "autoscaler_run_developer" {
  project = var.project_id
  role    = "roles/run.developer"
  member  = "serviceAccount:${google_service_account.autoscaler.email}"
}

resource "google_artifact_registry_repository_iam_member" "autoscaler_ar_reader" {
  count = var.artifact_registry_repository_id != "" ? 1 : 0

  project    = var.project_id
  location   = var.region
  repository = var.artifact_registry_repository_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.autoscaler.email}"
}

# Cloud Run service agent must pull images from Artifact Registry.
data "google_project" "current" {
  project_id = var.project_id
}

resource "google_artifact_registry_repository_iam_member" "run_agent_ar_reader" {
  count = var.artifact_registry_repository_id != "" ? 1 : 0

  project    = var.project_id
  location   = var.region
  repository = var.artifact_registry_repository_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:service-${data.google_project.current.number}@serverless-robot-prod.iam.gserviceaccount.com"
}
