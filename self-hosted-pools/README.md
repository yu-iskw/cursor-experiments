# Self-hosted Cloud Agent pools (GCP Cloud Run)

Terraform and container definitions for [Cursor self-hosted Cloud Agent pools](https://cursor.com/docs/cloud-agent/self-hosted-cloud-run) on **Cloud Run Worker Pools**.

## Architecture

| Pool | Instances | Role |
|------|-----------|------|
| **Worker pool** (`cursor-agents-pool` by default) | Autoscaled (`MIN`–`MAX`) | Runs `agent worker start --pool` against one `REPO_URL` |
| **Autoscaler pool** (`cursor-autoscaler-pool`) | Fixed at **1** | Polls Cursor fleet API; PATCHes worker pool `manualInstanceCount` |

Terraform **ignores** live worker instance count after create so the autoscaler can scale without drift on every `terraform apply`.

## Prerequisites

1. Cursor Team/Enterprise with **Self-Hosted Cloud Agents** enabled.
2. Team admin: **Allow Self-Hosted Agents** (and optionally **Require**).
3. [Service account API key](https://cursor.com/docs/account/enterprise/service-accounts) (not a user key).
4. GCP project with billing; permissions to enable APIs and run Terraform (`roles/run.developer`, `roles/iam.serviceAccountUser`, etc.).

## Directory layout

```
self-hosted-pools/
├── containers/
│   ├── worker/          # Cursor agent worker image
│   └── autoscaler/      # Fleet API poller + Cloud Run resize
├── docs/
│   └── verification-checklist.md
└── terraform/
    ├── modules/         # APIs, IAM, secrets, AR, worker pool, autoscaler
    └── environments/
        ├── dev/
        ├── staging/
        └── prod/
```

## Deploy (dev)

### 1. Configure variables

```bash
cd self-hosted-pools/terraform/environments/dev
cp terraform.tfvars.example terraform.tfvars
# Edit project_id, region, repo_url, image URIs
```

### 2. Bootstrap secrets (values never go in Terraform)

```bash
export PROJECT_ID=your-gcp-project-id

# Service account API key from Cursor dashboard
echo -n 'YOUR_SERVICE_ACCOUNT_API_KEY' | gcloud secrets versions add CURSOR_API_KEY \
  --project="$PROJECT_ID" --data-file=-

# Git PAT (private repos)
echo -n 'YOUR_GIT_TOKEN' | gcloud secrets versions add GIT_TOKEN \
  --project="$PROJECT_ID" --data-file=-
```

### 3. Build and push images

```bash
export REGION=us-central1
export REPO=cursor-self-hosted-pools

gcloud auth configure-docker "${REGION}-docker.pkg.dev" --quiet

# Worker
docker build -t "${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/cursor-worker:latest" \
  self-hosted-pools/containers/worker
docker push "${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/cursor-worker:latest"

# Autoscaler
docker build -t "${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/cursor-autoscaler:latest" \
  self-hosted-pools/containers/autoscaler
docker push "${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/cursor-autoscaler:latest"
```

Set `worker_image` and `autoscaler_image` in `terraform.tfvars` to these URIs (use digests in production).

### 4. Apply Terraform

```bash
cd self-hosted-pools/terraform/environments/dev
terraform init
terraform plan
terraform apply
```

`terraform apply` enables APIs, creates Artifact Registry (if not present), Secret Manager secret **containers**, IAM, and both worker pools.

### 5. Verify

See [docs/verification-checklist.md](docs/verification-checklist.md).

Quick check:

```bash
curl -s -H "Authorization: Bearer $CURSOR_API_KEY" \
  https://api.cursor.com/v0/private-workers/summary | jq .
```

Launch a Cloud Agent from the Cursor UI with **Self-hosted** selected, or API with `"usePrivateWorker": true`.

## Environments

| Directory | Default `environment` | Notes |
|-----------|----------------------|--------|
| `terraform/environments/dev` | `dev` | `deletion_protection = false` |
| `terraform/environments/staging` | `staging` | Same modules; separate state recommended |
| `terraform/environments/prod` | `prod` | `deletion_protection = true` by default |

Use a remote backend in `backend.tf` per environment before team use.

## Autoscaler behavior

Environment variables (set by Terraform on the autoscaler pool):

| Variable | Default | Description |
|----------|---------|-------------|
| `TARGET_UTILIZATION` | `0.5` | Target fraction of workers in use |
| `MIN_INSTANCES` | `1` | Floor |
| `MAX_INSTANCES` | `10` (dev example: 5) | Ceiling |
| `POLLING_INTERVAL_MS` | `30000` | Poll interval |
| `SCALE_DOWN_IDLE_POLLS` | `2` | Consecutive idle polls before scale-down |

## Worker container

- Base: `ubuntu:24.04`, installs Cursor `agent` CLI.
- Clones `REPO_URL` to `/workspace/repo` on first start.
- Runs: `agent worker start --pool --management-addr :${PORT}`.
- Health: HTTP `/healthz` on `PORT` (8080).

Optional: `CURSOR_WORKER_POOL_NAME` (maps to `--pool-name`).

## Operations

| Task | Approach |
|------|----------|
| Scale capacity | Autoscaler (automatic) or PATCH worker pool API; avoid changing count-only via Terraform |
| Rotate API key | New Secret Manager version → recycle worker/autoscaler instances |
| Upgrade agent CLI | Rebuild worker image → update `worker_image` in tfvars → `terraform apply` |
| Destroy | `terraform destroy` (disable `deletion_protection` in prod only when intentional) |

## References

- [Self-Hosted Cloud Run](https://cursor.com/docs/cloud-agent/self-hosted-cloud-run)
- [Self-Hosted Pool](https://cursor.com/docs/cloud-agent/self-hosted-pool)
- [Cloud Agents API](https://cursor.com/docs/cloud-agent/api/endpoints)
- [Implementation plan](../docs/plans/2026-06-03-001-feat-self-hosted-cloud-run-pools-plan.md)
