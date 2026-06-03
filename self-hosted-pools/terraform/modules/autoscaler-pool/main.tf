locals {
  autoscaler_env = merge(
    {
      GOOGLE_CLOUD_PROJECT  = var.project_id
      CLOUD_RUN_LOCATION    = var.region
      WORKER_POOL_NAME      = var.worker_pool_name
      TARGET_UTILIZATION    = tostring(var.target_utilization)
      MIN_INSTANCES         = tostring(var.min_instances)
      MAX_INSTANCES         = tostring(var.max_instances)
      POLLING_INTERVAL_MS   = tostring(var.polling_interval_ms)
      SCALE_DOWN_IDLE_POLLS = tostring(var.scale_down_idle_polls)
    },
    var.extra_env_vars,
  )
}

resource "google_cloud_run_v2_worker_pool" "autoscaler" {
  project  = var.project_id
  location = var.region
  name     = var.name

  deletion_protection = var.deletion_protection
  labels              = var.labels

  template {
    service_account = var.service_account_email

    containers {
      name  = "cursor-autoscaler"
      image = var.image

      resources {
        limits = {
          cpu    = var.cpu
          memory = var.memory
        }
      }

      dynamic "env" {
        for_each = local.autoscaler_env
        content {
          name  = env.key
          value = env.value
        }
      }

      env {
        name = "CURSOR_API_KEY"
        value_source {
          secret_key_ref {
            secret  = var.cursor_api_key_secret_id
            version = var.secret_version
          }
        }
      }
    }
  }

  scaling {
    manual_instance_count = 1
  }

  depends_on = var.api_dependencies
}
