variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "repository_id" {
  type    = string
  default = "cursor-self-hosted-pools"
}

variable "worker_image_name" {
  type    = string
  default = "cursor-worker"
}

variable "autoscaler_image_name" {
  type    = string
  default = "cursor-autoscaler"
}
