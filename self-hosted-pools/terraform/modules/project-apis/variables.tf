variable "project_id" {
  type        = string
  description = "GCP project ID."
}

variable "services" {
  type        = list(string)
  description = "API services to enable."
  default = [
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com",
    "iam.googleapis.com",
    "cloudbuild.googleapis.com",
    "compute.googleapis.com",
  ]
}
