locals {
  secret_env_blocks = concat(
    [
      {
        name    = "CURSOR_API_KEY"
        secret  = var.cursor_api_key_secret_id
        version = var.secret_version
      }
    ],
    var.git_token_secret_id != "" ? [
      {
        name    = "GIT_TOKEN"
        secret  = var.git_token_secret_id
        version = var.secret_version
      }
    ] : []
  )

  plain_env_blocks = [
    for key, value in var.env_vars : {
      name  = key
      value = value
    }
  ]
}

resource "google_cloud_run_v2_worker_pool" "workers" {
  project  = var.project_id
  location = var.region
  name     = var.name

  deletion_protection = var.deletion_protection
  labels              = var.labels

  template {
    service_account = var.service_account_email

    containers {
      name  = "cursor-worker"
      image = var.image

      command = var.container_command
      args    = var.container_args

      resources {
        limits = {
          cpu    = var.cpu
          memory = var.memory
        }
      }

      dynamic "env" {
        for_each = local.plain_env_blocks
        content {
          name  = env.value.name
          value = env.value.value
        }
      }

      dynamic "env" {
        for_each = local.secret_env_blocks
        content {
          name = env.value.name
          value_source {
            secret_key_ref {
              secret  = env.value.secret
              version = env.value.version
            }
          }
        }
      }

      dynamic "startup_probe" {
        for_each = var.enable_http_probes ? [1] : []
        content {
          http_get {
            path = "/healthz"
            port = var.container_port
          }
          initial_delay_seconds = 10
          timeout_seconds       = 5
          period_seconds        = 10
          failure_threshold     = 6
        }
      }

      ports {
        container_port = var.container_port
      }
    }

    dynamic "vpc_access" {
      for_each = var.vpc_network != "" ? [1] : []
      content {
        network_interfaces {
          network    = var.vpc_network
          subnetwork = var.vpc_subnetwork
          tags       = var.vpc_network_tags
        }
        egress = var.vpc_egress
      }
    }
  }

  scaling {
    manual_instance_count = var.initial_instance_count
  }

  lifecycle {
    ignore_changes = [
      scaling[0].manual_instance_count,
    ]
  }

  depends_on = var.api_dependencies
}
