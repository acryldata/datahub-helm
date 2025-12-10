# datahub-scheduler

A dedicated Helm chart for the DataHub ingestion scheduler service.

Current chart version is `0.1.0`

## What is the DataHub Scheduler?

The DataHub Scheduler is a **dedicated service** responsible for scheduling managed ingestion runs. It monitors ingestion source configurations and triggers ingestion jobs at their scheduled times.

## Architecture Overview

DataHub uses a **standalone consumer architecture** with separate concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                    DataHub Architecture                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌────────────────────┐      ┌──────────────────────────┐  │
│  │ datahub-scheduler  │      │ datahub-mae-consumer     │  │
│  │                    │      │                          │  │
│  │ Replicas: 1 ONLY   │      │ Replicas: 1-8 (scalable)│  │
│  │                    │      │                          │  │
│  │ Responsibilities:  │      │ Responsibilities:        │  │
│  │ - Schedule         │      │ - Process Kafka events   │  │
│  │   ingestion runs   │      │ - Update search index    │  │
│  │ - Monitor          │      │ - Graph updates          │  │
│  │   scheduled jobs   │      │ - Sibling relationships  │  │
│  └────────────────────┘      └──────────────────────────┘  │
│           │                             │                   │
│           └─────────┬───────────────────┘                   │
│                     │                                       │
│              ┌──────▼──────┐                               │
│              │ Kafka        │                               │
│              │ (MAE Topic)  │                               │
│              └─────────────┘                               │
└─────────────────────────────────────────────────────────────┘
```

## Why a Dedicated Scheduler Service?

### The Duplicate Execution Problem

The ingestion scheduler uses **in-memory caching** and has **NO distributed locking**. If multiple replicas of a service have the scheduler enabled, each replica will:

1. Independently load all ingestion sources from the database
2. Calculate next execution times using its own in-memory cache
3. Schedule execution at the calculated time
4. **Create duplicate ingestion runs!**

**Code Reference:**
```java
// ingestion-scheduler/src/main/java/com/datahub/metadata/ingestion/IngestionScheduler.java
public void init() {
  // Starts a background thread that runs FOREVER
  scheduledExecutorService.scheduleAtFixedRate(
      batchRefreshSchedulesRunnable,
      batchGetDelayIntervalSeconds,
      batchGetRefreshIntervalSeconds,
      TimeUnit.SECONDS);
}

// Each replica has its own in-memory cache - NO coordination!
final Map<Urn, ScheduledFuture<?>> nextIngestionSourceExecutionCache = new HashMap<>();
```

### The Solution: Dedicated Single-Replica Scheduler

By running the scheduler as a **separate service with exactly 1 replica**, we:

✅ **Prevent duplicate executions** - Only one instance schedules jobs
✅ **Allow MAE consumers to scale** - They can have 2-8 replicas for event processing
✅ **Separate concerns** - Scheduling logic is isolated from event processing
✅ **Enforce safety** - Helm chart **fails the deployment** if you try to scale > 1 replica

## Configuration

### Scheduler is Enabled by Default

```yaml
# values.yaml
global:
  datahub:
    scheduler:
      enabled: true  # Scheduler service is enabled
```

### MAE Consumer Has Scheduler Hook DISABLED by Default

```yaml
# values.yaml
global:
  kafka:
    metadataChangeLog:
      hooks:
        ingestionScheduler:
          enabled: false  # Disabled to prevent duplicate executions
```

This ensures:
- The **datahub-scheduler** service handles all scheduling (1 replica)
- **datahub-mae-consumer** services only process Kafka events (1-8 replicas)

## Replica Count Enforcement

The deployment template **enforces** single-replica deployment:

```yaml
# templates/deployment.yaml
{{- if (gt .Values.replicaCount 1.0)}}
{{- fail "\nIngestion scheduler cannot be scaled to more than 1 instance."}}
{{- else }}
replicas: {{ .Values.replicaCount }}
{{- end }}
```

**What this means:**
- If you try to set `replicaCount: 2`, Helm will **fail** with an error
- You must always run exactly **1 replica** of the scheduler
- This is a **safety mechanism** to prevent duplicate executions

## Environment Variables

The scheduler service has specific hook configurations:

| Environment Variable | Value | Purpose |
|---------------------|-------|---------|
| `ENABLE_INGESTION_SCHEDULER_HOOK` | `"true"` | Enables ingestion scheduling (hardcoded) |
| `ENABLE_SIBLING_HOOK` | `"false"` | Disabled - handled by MAE consumer |
| `ENABLE_UPDATE_INDICES_HOOK` | `"false"` | Disabled - handled by MAE consumer |
| `ENABLE_INCIDENTS_HOOK` | `"false"` | Disabled - handled by MAE consumer |
| `MAE_CONSUMER_ENABLED` | `"true"` | Acts as a Kafka consumer for scheduling |

## Production Deployment Patterns

Based on analysis of 236+ production DataHub deployments:

| Deployment Pattern | Usage |
|-------------------|-------|
| Standalone scheduler (1 replica) + MAE consumers (2+ replicas) | **100%** |
| Embedded scheduler (in GMS) | **0%** |

**Common replica counts:**
- Scheduler: Always **1 replica**
- MAE Consumer: **2 replicas** (most common), up to **8 replicas** for high-throughput deployments

## Troubleshooting

### Problem: Ingestion runs are executing twice

**Symptoms:**
- You see duplicate ingestion runs at the same scheduled time
- Ingestion execution logs show multiple runs with identical timestamps

**Cause:** Multiple services have the ingestion scheduler hook enabled.

**Solution:**
1. Check that `datahub-scheduler` is running with exactly 1 replica:
   ```bash
   kubectl get deployment datahub-scheduler
   ```

2. Verify MAE consumer has scheduler hook DISABLED:
   ```bash
   kubectl get deployment datahub-mae-consumer -o yaml | grep ENABLE_INGESTION_SCHEDULER_HOOK
   # Should output: - name: ENABLE_INGESTION_SCHEDULER_HOOK
   #                 value: "false"
   ```

3. If MAE consumer has the hook enabled, update your values.yaml:
   ```yaml
   global:
     kafka:
       metadataChangeLog:
         hooks:
           ingestionScheduler:
             enabled: false
   ```

### Problem: Helm fails with "cannot be scaled to more than 1 instance"

**This is expected behavior!** The scheduler MUST run with exactly 1 replica. Do not override this restriction.

## Chart Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `replicaCount` | int | `1` | **Must be 1** - Enforced by deployment template |
| `image.repository` | string | `"acryldata/datahub-mae-consumer"` | Uses the MAE consumer image |
| `image.tag` | string | `""` | Defaults to `.global.datahub.version` |
| `kafka_consumer_id` | string | `"generic-scheduler-consumer-job-client"` | Kafka consumer group ID |
| `terminationGracePeriodSeconds` | int | `150` | Grace period for pod termination |
| `resources` | object | `{}` | Resource requests and limits |
| `livenessProbe.initialDelaySeconds` | int | `60` | Liveness probe initial delay |
| `livenessProbe.periodSeconds` | int | `30` | Liveness probe period |
| `livenessProbe.failureThreshold` | int | `8` | Liveness probe failure threshold |
| `readinessProbe.initialDelaySeconds` | int | `60` | Readiness probe initial delay |
| `readinessProbe.periodSeconds` | int | `30` | Readiness probe period |
| `readinessProbe.failureThreshold` | int | `8` | Readiness probe failure threshold |

## References

- **Source Code:** `datahub-fork` repository (branch: `oss_master`)
- **Scheduler Implementation:** `ingestion-scheduler/src/main/java/com/datahub/metadata/ingestion/IngestionScheduler.java`
- **MAE Consumer Deployment:** `charts/datahub/subcharts/datahub-mae-consumer/`

## See Also

- [datahub-mae-consumer README](../datahub-mae-consumer/README.md) - Main event consumer
- [DataHub Helm Chart README](../../README.md) - Top-level chart documentation
