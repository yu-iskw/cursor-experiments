output "worker_service_account_email" {
  value = google_service_account.worker.email
}

output "autoscaler_service_account_email" {
  value = google_service_account.autoscaler.email
}

output "worker_service_account_id" {
  value = google_service_account.worker.name
}

output "autoscaler_service_account_id" {
  value = google_service_account.autoscaler.name
}
