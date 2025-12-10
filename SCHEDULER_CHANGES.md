# Ingestion Scheduler Architecture Changes

## Problem Statement

Previously, the OSS Helm charts enabled the ingestion scheduler hook on MAE consumer pods by default. When running multiple MAE consumer replicas for high availability, this caused **duplicate ingestion executions** because:

1. Each MAE consumer replica independently runs its own scheduler thread (`IngestionScheduler.init()` calls `scheduleAtFixedRate()`)
2. No distributed locking exists between replicas
3. Each replica maintains its own in-memory cache of scheduled executions
4. Result: Multiple replicas schedule and execute the same ingestion at the same time

## Solution

This PR implements the same architecture pattern used in DataHub Cloud:

### 1. Dedicated Scheduler Service

Added new `datahub-scheduler` subchart that:
- Runs as a separate Kubernetes deployment
- Uses the MAE consumer image but in "scheduler-only" mode
- Has `ENABLE_INGESTION_SCHEDULER_HOOK=true` with all other hooks disabled
- **Enforced to run with exactly 1 replica** (Helm fails deployment if you try to scale it)
- Dedicated to scheduling ingestion runs only (doesn't process Kafka events)

### 2. Disabled Scheduler on MAE Consumers

Changed default configuration in `values.yaml`:
- `kafka.metadataChangeLog.hooks.ingestionScheduler.enabled: false` (was `true`)
- MAE consumers now only process Kafka events, don't run scheduler thread
- Can safely scale MAE consumers to multiple replicas for high availability

### 3. Configuration

New configuration in `global.datahub`:
```yaml
datahub:
  scheduler:
    enabled: true  # Controls whether datahub-scheduler service is deployed
```

## Files Changed

1. **charts/datahub/subcharts/datahub-scheduler/** - New subchart (copied from Cloud)
   - Enforces 1-replica limit in deployment.yaml (lines 12-13)
   - Only enables ingestion scheduler hook, disables all others

2. **charts/datahub/values.yaml**
   - Line 805: Changed `ingestionScheduler.enabled: false` (was `true`)
   - Lines 924-928: Added `scheduler.enabled: true` configuration

3. **charts/datahub/Chart.yaml**
   - Lines 29-32: Added datahub-scheduler subchart dependency

## Deployment Impact

**Existing Deployments:**
- Default behavior changes - ingestion scheduling now runs in dedicated service
- If upgrading, the new scheduler service will be deployed automatically
- MAE consumer pods will stop scheduling ingestions (no duplicate risk)

**New Deployments:**
- Scheduler service deploys by default with 1 replica
- Safe to scale MAE consumers to multiple replicas
- No risk of duplicate ingestion executions

## Testing

After applying these changes:

1. **Verify scheduler deployment:**
   ```bash
   kubectl get deployment datahub-scheduler
   # Should show 1/1 replica
   ```

2. **Verify MAE consumers don't schedule:**
   ```bash
   kubectl logs -l app=datahub-mae-consumer | grep "ENABLE_INGESTION_SCHEDULER_HOOK"
   # Should show "false" for all MAE consumer pods
   ```

3. **Verify scheduler is active:**
   ```bash
   kubectl logs -l app=datahub-scheduler | grep "ENABLE_INGESTION_SCHEDULER_HOOK"
   # Should show "true"
   ```

## References

- Cloud implementation: `datahub-helm-fork/charts/datahub/subcharts/datahub-scheduler/`
- Scheduler code: `ingestion-scheduler/src/main/java/com/datahub/metadata/ingestion/IngestionScheduler.java`
- Issue discussion: [Internal Slack thread on duplicate ingestion executions]
