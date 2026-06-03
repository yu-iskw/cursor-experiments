output "cursor_api_key_secret_id" {
  value = google_secret_manager_secret.cursor_api_key.secret_id
}

output "git_token_secret_id" {
  value = var.create_git_token_secret ? google_secret_manager_secret.git_token[0].secret_id : var.git_token_secret_id
}
