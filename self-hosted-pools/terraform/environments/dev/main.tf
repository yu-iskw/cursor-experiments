locals {
  common_labels = merge(
    {
      managed-by  = "terraform"
      environment = var.environment
      component   = "cursor-self-hosted-pools"
    },
    var.labels,
  )
}

module "project_apis" {
  source = "../../modules/project-apis"

  project_id = var.project_id
}

module "secrets" {
  source = "../../modules/secrets"

  project_id              = var.project_id
  create_git_token_secret = var.create_git_token_secret
  labels                  = local.common_labels

  depends_on = [module.project_apis]
}

module "artifact_registry" {
  source = "../../modules/artifact-registry"

  project_id = var.project_id
  region     = var.region

  depends_on = [module.project_apis]
}

module "iam" {
  source = "../../modules/iam"

  project_id                      = var.project_id
  region                          = var.region
  cursor_api_key_secret_id        = module.secrets.cursor_api_key_secret_id
  git_token_secret_id             = module.secrets.git_token_secret_id
  artifact_registry_repository_id = module.artifact_registry.repository_id

  depends_on = [module.secrets, module.artifact_registry]
}

module "worker_pool" {
  source = "../../modules/worker-pool

  project_id               = var.project_id
  region                   = var.region
  name                     = var.worker_pool_name
  image                    = var.worker_image
  service_account_email    = module.iam.worker_service_account_email
  cursor_api_key_secret_id = module.secrets.cursor_api_key_secret_id
  git_token_secret_id      = module.secrets.git_token_secret_id
  initial_instance_count   = var.initial_instance_count
  cpu                      = var.worker_cpu
  memory                   = var.worker_memory
  deletion_protection      = var.deletion_protection
  labels                   = local.common_labels

  env_vars = {
    REPO_URL                      = var.repo_url
    CURSOR_WORKER_POOL_NAME       = var.pool_name_label
    CURSOR_WORKER_IDLE_RELEASE_TIMEOUT = "600"
  }

  vpc_network    = var.enable_vpc ? var.vpc_network : ""
  vpc_subnetwork = var.enable_vpc ? var.vpc_subnetwork : ""

  api_dependencies = [module.project_apis, module.iam]

  depends_on = [module.iam]
}

module "autoscaler_pool" {
  source = "../../modules/autoscaler-pool

  project_id               = var.project_id
  region                   = var.region
  name                     = var.autoscaler_pool_name
  image                    = var.autoscaler_image
  service_account_email    = module.iam.autoscaler_service_account_email
  worker_pool_name         = var.worker_pool_name
  cursor_api_key_secret_id = module.secrets.cursor_api_key_secret_id
  target_utilization       = var.target_utilization
  min_instances            = var.min_instances
  max_instances            = var.max_instances
  deletion_protection      = var.deletion_protection
  labels                   = local.common_labels

  api_dependencies = [module.project_apis, module.iam, module.worker_pool]

  depends_on = [module.worker_pool]
}
