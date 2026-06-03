# Self-hosted Cloud Agent pools (GCP Cloud Run)

This directory will host **Terraform** and **container definitions** for running [Cursor self-hosted Cloud Agent pools](https://cursor.com/docs/cloud-agent/self-hosted-cloud-run) on **Cloud Run Worker Pools**.

## Status

**Planning only.** Do not add Terraform or deploy resources until the implementation plan is approved:

- [Implementation plan](../docs/plans/2026-06-03-001-feat-self-hosted-cloud-run-pools-plan.md) (`status: draft`)

## What will live here

| Path | Purpose |
|------|---------|
| `terraform/modules/` | Reusable modules (APIs, IAM, Artifact Registry, secrets, worker pool, autoscaler) |
| `terraform/environments/{dev,staging,prod}/` | Per-environment roots and `terraform.tfvars` |
| `containers/worker/` | Cursor `agent worker start --pool` image |
| `containers/autoscaler/` | Fleet API poller + Cloud Run resize |

Deployment is **Terraform-only** (no shell scripts as the canonical deploy interface). Image build may use Cloud Build in CI; `gcloud run worker-pools deploy` is not the source of truth.

## Architecture (target)

1. **Worker pool** — N instances; outbound HTTPS to Cursor; one git repo per pool (`REPO_URL`).
2. **Autoscaler pool** — 1 instance; polls `GET /v0/private-workers/summary`; PATCHes worker pool `manualInstanceCount`.

See the plan document for diagrams, IAM, state ownership (Terraform vs autoscaler), and implementation units.

## Prerequisites (summary)

- Cursor Team/Enterprise with **Self-Hosted Cloud Agents** enabled (confirm with your account team).
- **Service account API key** (not a user API key) in Secret Manager as `CURSOR_API_KEY`.
- **Git token** with access to the target repository.
- GCP project with billing; deployer credentials for Terraform.

Official references:

- [Self-Hosted Cloud Run](https://cursor.com/docs/cloud-agent/self-hosted-cloud-run)
- [Self-Hosted Pool](https://cursor.com/docs/cloud-agent/self-hosted-pool)
- [Cloud Agents API](https://cursor.com/docs/cloud-agent/api/endpoints)
