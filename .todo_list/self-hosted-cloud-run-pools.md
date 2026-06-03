# Self-hosted Cloud Run pools — plan todo

Plan: [docs/plans/2026-06-03-001-feat-self-hosted-cloud-run-pools-plan.md](../docs/plans/2026-06-03-001-feat-self-hosted-cloud-run-pools-plan.md)

## Planning phase (current)

- [x] Research Cursor Cloud Run worker pool docs and GCP/Terraform patterns
- [x] Create `self-hosted-pools/` directory (planning artifacts only)
- [x] Write implementation plan in `docs/plans/`
- [ ] Review plan with team; resolve open questions
- [ ] Mark plan `status: approved`

## Implementation phase (after approval — do not start early)

- [ ] U2: Terraform foundation modules (APIs, IAM, registry, secrets)
- [ ] U3: Worker container image
- [ ] U4: Worker pool Terraform module
- [ ] U5: Autoscaler container + Terraform module
- [ ] U6: Staging/prod environments + optional VPC
- [ ] U7: Complete README and verification checklist
