variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "name" {
  type    = string
  default = "cursor-autoscaler-pool"
}

variable "image" {
  type = string
}

variable "service_account_email" {
  type = string
}

variable "worker_pool_name" {
  type = string
}

variable "cursor_api_key_secret_id" {
  type = string
}

variable "secret_version" {
  type    = string
  default = "latest"
}

variable "target_utilization" {
  type    = number
  default = 0.5
}

variable "min_instances" {
  type    = number
  default = 1
}

variable "max_instances" {
  type    = number
  default = 10
}

variable "polling_interval_ms" {
  type    = number
  default = 30000
}

variable "scale_down_idle_polls" {
  type    = number
  default = 2
}

variable "extra_env_vars" {
  type    = map(string)
  default = {}
}

variable "cpu" {
  type    = string
  default = "1"
}

variable "memory" {
  type    = string
  default = "512Mi"
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "api_dependencies" {
  type    = list(any)
  default = []
}
