variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "worker_sa_id" {
  type    = string
  default = "cursor-worker-pool"
}

variable "autoscaler_sa_id" {
  type    = string
  default = "cursor-autoscaler"
}

variable "cursor_api_key_secret_id" {
  type = string
}

variable "git_token_secret_id" {
  type    = string
  default = ""
}

variable "artifact_registry_repository_id" {
  type    = string
  default = ""
}
