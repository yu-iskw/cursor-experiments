output "artifact_registry_repository_url" {
  value = module.artifact_registry.repository_url
}

output "worker_pool_name" {
  value = module.worker_pool.name
}

output "worker_pool_uri" {
  value = module.worker_pool.uri
}

output "autoscaler_pool_name" {
  value = module.autoscaler_pool.name
}

output "worker_service_account_email" {
  value = module.iam.worker_service_account_email
}

output "autoscaler_service_account_email" {
  value = module.iam.autoscaler_service_account_email
}

output "cursor_api_key_secret_id" {
  value = module.secrets.cursor_api_key_secret_id
}

output "git_token_secret_id" {
  value = module.secrets.git_token_secret_id
}

output "suggested_worker_image" {
  value = "${module.artifact_registry.worker_image_path}:latest"
}

output "suggested_autoscaler_image" {
  value = "${module.artifact_registry.autoscaler_image_path}:latest"
}
