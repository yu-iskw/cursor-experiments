variable "project_id" {
  type        = string
  description = "GCP project ID."
}

variable "region" {
  type        = string
  description = "GCP region for worker pools and Artifact Registry."
  default     = "us-central1"
}

variable "environment" {
  type    = string
  default = "staging"
}

variable "repo_url" {
  type        = string
  description = "Git repository URL served by this worker pool."
}

variable "worker_pool_name" {
  type    = string
  default = "cursor-agents-pool"
}

variable "autoscaler_pool_name" {
  type    = string
  default = "cursor-autoscaler-pool"
}

variable "worker_image" {
  type        = string
  description = "Full Artifact Registry image URI for the worker container."
}

variable "autoscaler_image" {
  type        = string
  description = "Full Artifact Registry image URI for the autoscaler container."
}

variable "initial_instance_count" {
  type    = number
  default = 1
}

variable "min_instances" {
  type    = number
  default = 1
}

variable "max_instances" {
  type    = number
  default = 5
}

variable "target_utilization" {
  type    = number
  default = 0.5
}

variable "worker_cpu" {
  type    = string
  default = "1"
}

variable "worker_memory" {
  type    = string
  default = "2Gi"
}

variable "pool_name_label" {
  type        = string
  description = "Cursor pool name passed to agent worker (--pool-name)."
  default     = "default"
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "create_git_token_secret" {
  type    = bool
  default = true
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "enable_vpc" {
  type    = bool
  default = false
}

variable "vpc_network" {
  type    = string
  default = ""
}

variable "vpc_subnetwork" {
  type    = string
  default = ""
}
