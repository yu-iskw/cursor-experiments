resource "google_secret_manager_secret" "cursor_api_key" {
  project   = var.project_id
  secret_id = var.cursor_api_key_secret_id

  replication {
    auto {}
  }

  labels = var.labels
}

resource "google_secret_manager_secret" "git_token" {
  count = var.create_git_token_secret ? 1 : 0

  project   = var.project_id
  secret_id = var.git_token_secret_id

  replication {
    auto {}
  }

  labels = var.labels
}
