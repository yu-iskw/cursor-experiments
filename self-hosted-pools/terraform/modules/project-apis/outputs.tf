output "enabled_services" {
  description = "APIs enabled on the project."
  value       = [for s in google_project_service.apis : s.service]
}
