variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "name" {
  type = string
}

variable "image" {
  type = string
}

variable "service_account_email" {
  type = string
}

variable "cursor_api_key_secret_id" {
  type = string
}

variable "git_token_secret_id" {
  type    = string
  default = ""
}

variable "secret_version" {
  type    = string
  default = "latest"
}

variable "env_vars" {
  type    = map(string)
  default = {}
}

variable "initial_instance_count" {
  type    = number
  default = 1
}

variable "cpu" {
  type    = string
  default = "1"
}

variable "memory" {
  type    = string
  default = "2Gi"
}

variable "container_port" {
  type    = number
  default = 8080
}

variable "container_command" {
  type    = list(string)
  default = null
}

variable "container_args" {
  type    = list(string)
  default = []
}

variable "enable_http_probes" {
  type    = bool
  default = true
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "vpc_network" {
  type    = string
  default = ""
}

variable "vpc_subnetwork" {
  type    = string
  default = ""
}

variable "vpc_network_tags" {
  type    = list(string)
  default = []
}

variable "vpc_egress" {
  type    = string
  default = "PRIVATE_RANGES_ONLY"
}

variable "api_dependencies" {
  type    = list(any)
  default = []
}
