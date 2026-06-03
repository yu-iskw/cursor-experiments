# Self-hosted Cloud Run pools

Plan: [docs/plans/2026-06-03-001-feat-self-hosted-cloud-run-pools-plan.md](../docs/plans/2026-06-03-001-feat-self-hosted-cloud-run-pools-plan.md)

## Planning phase

- [x] Research Cursor Cloud Run worker pool docs and GCP/Terraform patterns
- [x] Create `self-hosted-pools/` directory
- [x] Write implementation plan in `docs/plans/`
- [x] Mark plan approved

## Implementation phase

- [x] U2: Terraform foundation modules (APIs, IAM, registry, secrets)
- [x] U3: Worker container image
- [x] U4: Worker pool Terraform module
- [x] U5: Autoscaler container + Terraform module
- [x] U6: Staging/prod environments + tfvars examples
- [x] U7: README and verification checklist
