# Verification checklist — self-hosted Cloud Run pools

Use after `terraform apply` and secret bootstrap. Replace placeholders with your project values.

## Bootstrap

- [ ] `CURSOR_API_KEY` secret version added (service account API key)
- [ ] `GIT_TOKEN` secret version added (if private repo)
- [ ] Worker and autoscaler images pushed to Artifact Registry
- [ ] `terraform apply` completes without errors in target environment

## Registration

- [ ] `curl -s -H "Authorization: Bearer $CURSOR_API_KEY" https://api.cursor.com/v0/private-workers/summary` shows `totalConnected >= MIN_INSTANCES`
- [ ] Cursor dashboard → Cloud Agents → Self-hosted lists idle workers
- [ ] Cloud Logging shows worker containers cloning repo and starting `agent worker`

## Agent execution

- [ ] Launch Cloud Agent with self-hosted routing (`usePrivateWorker: true` or UI Self-hosted selector)
- [ ] Session completes on pool (check worker logs / dashboard active → idle)

## Autoscaling

- [ ] Under load, autoscaler logs show `reconcile_apply` with increasing `to` count
- [ ] After drain, count decreases toward `MIN_INSTANCES` without killing active sessions (check `inUse` in logs)
- [ ] `MAX_INSTANCES` caps scale-up

## Operations

- [ ] `terraform plan` does not propose changing worker `manual_instance_count` (ignored by lifecycle)
- [ ] Secret rotation: new secret version + instance recycle restores registration
- [ ] `terraform destroy` removes pools (non-prod only if `deletion_protection = false`)
