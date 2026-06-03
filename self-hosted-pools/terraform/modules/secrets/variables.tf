variable "project_id" {
  type = string
}

variable "cursor_api_key_secret_id" {
  type    = string
  default = "CURSOR_API_KEY"
}

variable "git_token_secret_id" {
  type    = string
  default = "GIT_TOKEN"
}

variable "create_git_token_secret" {
  type    = bool
  default = true
}

variable "labels" {
  type    = map(string)
  default = {}
}
