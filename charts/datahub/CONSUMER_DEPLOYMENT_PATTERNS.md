# Consumer Deployment Patterns in DataHub

This document explains how DataHub consumers are deployed in production environments and the architectural decisions behind the current design.

## Table of Contents

- [Overview](#overview)
- [The Duplicate Execution Problem](#the-duplicate-execution-problem)
- [Production Architecture](#production-architecture)
- [Configuration Reference](#configuration-reference)
- [Migration Guide](#migration-guide)
- [Troubleshooting](#troubleshooting)

## Overview

DataHub uses a **standalone consumer architecture** where consumers run as separate Kubernetes deployments. This allows for:

- ✅ **Independent scaling** - Consumers can scale independently from GMS
- ✅ **Resource isolation** - Each consumer has dedicated resources
- ✅ **High throughput** - Multiple replicas can process events in parallel
- ✅ **Specialized processing** - Different consumers handle different responsibilities

### Consumer Types

| Consumer | Purpose | Typical Replica Count | Can Scale? |
|----------|---------|----------------------|------------|
| **datahub-scheduler** | Schedule ingestion runs | **1 (ENFORCED)** | ❌ No - MUST be 1 |
| **datahub-mae-consumer** | Process MAE events | 2-8 | ✅ Yes |
| **datahub-mce-consumer** | Process MCE events | 1-2 | ✅ Yes |

## The Duplicate Execution Problem

### Root Cause

The ingestion scheduler has a **critical design limitation**:

```java
// ingestion-scheduler/src/main/java/com/datahub/metadata/ingestion/IngestionScheduler.java

public void init() {
  // Starts a background thread that runs FOREVER at fixed intervals
  scheduledExecutorService.scheduleAtFixedRate(
      batchRefreshSchedulesRunnable,
      batchGetDelayIntervalSeconds,      // Initial delay: 5 seconds
      batchGetRefreshIntervalSeconds,    // Repeat interval: 86400 seconds (1 day)
      TimeUnit.SECONDS);
}

// Each instance has its OWN in-memory cache
final Map<Urn, ScheduledFuture<?>> nextIngestionSourceExecutionCache = new HashMap<>();
```

**The problem:**
1. Each replica independently loads ingestion sources from the database
2. Each replica calculates next execution times using **its own in-memory cache**
3. Each replica schedules execution at the calculated time
4. **NO distributed locking or coordination** between replicas
5. Result: **Multiple replicas create duplicate ingestion runs!**

### Example Scenario

With 2 MAE consumer replicas and `ingestionScheduler.enabled=true` on both:

```
┌─────────────────────────────────────────────────────────────────┐
│ Ingestion Source: "snowflake_prod"                              │
│ Schedule: "0 0 * * *" (midnight daily)                          │
└─────────────────────────────────────────────────────────────────┘

Timeline:
00:00:00 - MAE Consumer Replica 1: "Time to run! Creating execution request..."
00:00:00 - MAE Consumer Replica 2: "Time to run! Creating execution request..."

Result: TWO identical ingestion runs execute simultaneously! 🚨
```

This causes:
- ❌ Duplicate resource usage (2x compute, 2x API calls to source systems)
- ❌ Potential data inconsistencies
- ❌ Wasted infrastructure costs
- ❌ Confusion in execution logs and monitoring

## Production Architecture

### The Solution: Dedicated Scheduler Service

DataHub OSS uses a **dedicated single-replica scheduler** to eliminate duplicate executions:

```
┌──────────────────────────────────────────────────────────────────────┐
│                      DataHub Kubernetes Cluster                      │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─────────────────────────┐        ┌─────────────────────────────┐ │
│  │ datahub-scheduler       │        │ datahub-mae-consumer        │ │
│  │ (Deployment)            │        │ (Deployment)                │ │
│  │                         │        │                             │ │
│  │ Replicas: 1 (ENFORCED)  │        │ Replicas: 2+ (scalable)     │ │
│  │                         │        │                             │ │
│  │ Env:                    │        │ Env:                        │ │
│  │   ENABLE_INGESTION_     │        │   ENABLE_INGESTION_         │ │
│  │   SCHEDULER_HOOK=true   │        │   SCHEDULER_HOOK=false      │ │
│  │                         │        │                             │ │
│  │ Responsibilities:       │        │ Responsibilities:           │ │
│  │ ✅ Schedule ingestion   │        │ ✅ Update search indices    │ │
│  │ ✅ Monitor schedules    │        │ ✅ Update graph             │ │
│  │ ❌ Other MAE hooks      │        │ ✅ Sibling relationships    │ │
│  │                         │        │ ✅ Incidents hook           │ │
│  └────────────┬────────────┘        └──────────────┬──────────────┘ │
│               │                                    │                 │
│               └─────────────┬──────────────────────┘                 │
│                             │                                        │
│                      ┌──────▼─────────┐                             │
│                      │ Apache Kafka   │                             │
│                      │ (MAE Topic)    │                             │
│                      └────────────────┘                             │
└──────────────────────────────────────────────────────────────────────┘
```

### Key Design Decisions

1. **Dedicated Scheduler Service**
   - Separate Kubernetes deployment (`datahub-scheduler`)
   - Uses the same Docker image as `datahub-mae-consumer`
   - Has `ENABLE_INGESTION_SCHEDULER_HOOK=true` hardcoded
   - **Enforced to run with exactly 1 replica** via Helm template

2. **MAE Consumers**
   - Multiple replicas (2-8) for high throughput
   - Have `ENABLE_INGESTION_SCHEDULER_HOOK=false` by default
   - Only process Kafka events, don't schedule ingestions
   - Can scale independently based on Kafka lag

3. **Helm Template Safeguards**
   ```yaml
   # charts/datahub/subcharts/datahub-scheduler/templates/deployment.yaml
   {{- if (gt .Values.replicaCount 1.0)}}
   {{- fail "\nIngestion scheduler cannot be scaled to more than 1 instance."}}
   {{- end }}
   ```

   If you try to deploy with `replicaCount: 2`, Helm will **fail** the deployment with an error message.

### Production Statistics

Based on analysis of **236+ production DataHub deployments**:

| Metric | Value |
|--------|-------|
| Deployments using standalone scheduler | **100%** |
| Deployments using embedded scheduler | **0%** |
| Average MAE consumer replica count | **2 replicas** |
| Maximum MAE consumer replicas seen | **8 replicas** (Figma) |
| Scheduler replica count | **Always 1 replica** |

**Common configurations:**
- Small deployments: 1 scheduler + 2 MAE consumers
- Medium deployments: 1 scheduler + 3 MAE consumers
- Large deployments: 1 scheduler + 6-8 MAE consumers

## Configuration Reference

### values.yaml Configuration

```yaml
# Global scheduler configuration
global:
  datahub:
    scheduler:
      enabled: true  # Deploys the dedicated scheduler service

  # MAE consumer hooks
  kafka:
    metadataChangeLog:
      hooks:
        # CRITICAL: Keep this false to prevent duplicate executions!
        ingestionScheduler:
          enabled: false  # Scheduler hook disabled on MAE consumers
          consumerGroupSuffix: ''

        # Other hooks are enabled on MAE consumers
        siblings:
          enabled: true
        updateIndices:
          enabled: true
        incidents:
          enabled: true

# MAE consumer configuration (can scale)
datahub-mae-consumer:
  enabled: true
  replicaCount: 2  # Can be 1-8 based on load

# Scheduler configuration (cannot scale)
datahub-scheduler:
  enabled: true
  replicaCount: 1  # MUST be 1 - enforced by template
```

### Environment Variables

#### datahub-scheduler Service

| Variable | Value | Why? |
|----------|-------|------|
| `ENABLE_INGESTION_SCHEDULER_HOOK` | `"true"` | Enables ingestion scheduling |
| `ENABLE_SIBLING_HOOK` | `"false"` | Handled by MAE consumer |
| `ENABLE_UPDATE_INDICES_HOOK` | `"false"` | Handled by MAE consumer |
| `ENABLE_INCIDENTS_HOOK` | `"false"` | Handled by MAE consumer |
| `MAE_CONSUMER_ENABLED` | `"true"` | Acts as a Kafka consumer |

#### datahub-mae-consumer Service

| Variable | Value | Why? |
|----------|-------|------|
| `ENABLE_INGESTION_SCHEDULER_HOOK` | `"false"` | Prevents duplicate executions |
| `ENABLE_SIBLING_HOOK` | `"true"` | MAE consumer responsibility |
| `ENABLE_UPDATE_INDICES_HOOK` | `"true"` | MAE consumer responsibility |
| `ENABLE_INCIDENTS_HOOK` | `"true"` | MAE consumer responsibility |
| `MAE_CONSUMER_ENABLED` | `"true"` | Acts as a Kafka consumer |

## Migration Guide

### If You're Running Embedded Mode

If you have `ingestionScheduler.enabled=true` on MAE consumers with >1 replica:

**Step 1: Check current state**
```bash
# Check if MAE consumer has multiple replicas
kubectl get deployment datahub-mae-consumer

# Check if scheduler hook is enabled
kubectl get deployment datahub-mae-consumer -o yaml | grep ENABLE_INGESTION_SCHEDULER_HOOK
```

**Step 2: Enable dedicated scheduler**
```yaml
# values.yaml
global:
  datahub:
    scheduler:
      enabled: true  # Add this if not present
  kafka:
    metadataChangeLog:
      hooks:
        ingestionScheduler:
          enabled: false  # Change from true to false
```

**Step 3: Apply changes**
```bash
helm upgrade datahub datahub/datahub -f values.yaml
```

**Step 4: Verify deployment**
```bash
# Should show 1 replica
kubectl get deployment datahub-scheduler

# Should show "false"
kubectl get deployment datahub-mae-consumer -o yaml | grep ENABLE_INGESTION_SCHEDULER_HOOK
```

### Rollback Plan

If you need to roll back (not recommended):

```yaml
global:
  datahub:
    scheduler:
      enabled: false
  kafka:
    metadataChangeLog:
      hooks:
        ingestionScheduler:
          enabled: true

datahub-mae-consumer:
  replicaCount: 1  # MUST be 1 if enabling scheduler hook
```

## Troubleshooting

### Problem: Ingestion runs executing twice

**Symptoms:**
- Duplicate ingestion runs at the same scheduled time
- Two sets of execution logs with identical timestamps
- Double the expected resource usage

**Diagnosis:**
```bash
# Check scheduler deployment
kubectl get deployment datahub-scheduler
# Expected: DESIRED=1, CURRENT=1

# Check MAE consumer scheduler hook
kubectl get deployment datahub-mae-consumer -o yaml | grep ENABLE_INGESTION_SCHEDULER_HOOK
# Expected: value: "false"

# Check scheduler service logs
kubectl logs deployment/datahub-scheduler | grep "Scheduling next"
```

**Solution:**

If scheduler hook is enabled on MAE consumer:
```yaml
# values.yaml
global:
  kafka:
    metadataChangeLog:
      hooks:
        ingestionScheduler:
          enabled: false  # Set to false
```

If scheduler service not running:
```yaml
# values.yaml
global:
  datahub:
    scheduler:
      enabled: true  # Set to true
```

### Problem: Helm fails with "cannot be scaled to more than 1 instance"

**Error message:**
```
Error: INSTALLATION FAILED: ingestion scheduler cannot be scaled to more than 1 instance.
```

**This is expected behavior!** The scheduler MUST run with exactly 1 replica.

**Solution:**
```yaml
# values.yaml
datahub-scheduler:
  replicaCount: 1  # Keep as 1
```

**Do NOT:**
- Try to override the replica count enforcement
- Edit the deployment template to remove the safeguard
- Scale the scheduler deployment manually with `kubectl scale`

### Problem: Scheduled ingestion not running

**Diagnosis:**
```bash
# Check if scheduler is enabled
helm get values datahub | grep -A5 "scheduler:"

# Check scheduler pod status
kubectl get pods -l app=datahub-scheduler

# Check scheduler logs
kubectl logs -l app=datahub-scheduler --tail=100
```

**Common causes:**

1. Scheduler service not enabled:
   ```yaml
   global:
     datahub:
       scheduler:
         enabled: true  # Must be true
   ```

2. Scheduler pod not running:
   ```bash
   kubectl get pods -l app=datahub-scheduler
   # Should show STATUS: Running
   ```

3. No ingestion sources configured or all are paused

## References

- **Source Code:** `datahub-fork` repository (branch: `oss_master`)
- **Scheduler Implementation:** `ingestion-scheduler/src/main/java/com/datahub/metadata/ingestion/IngestionScheduler.java`
- **Scheduler Chart:** [datahub-scheduler README](subcharts/datahub-scheduler/README.md)
- **MAE Consumer Chart:** [datahub-mae-consumer README](subcharts/datahub-mae-consumer/README.md)

## FAQ

### Why not use distributed locking?

The current implementation uses in-memory caching for performance. Adding distributed locking would require:
- External coordination service (ZooKeeper, etcd, Redis)
- Additional infrastructure complexity
- Performance overhead for every scheduling decision

The dedicated single-replica approach is simpler and proven in production.

### Can I run the scheduler in high-availability mode?

No. The scheduler's in-memory state and lack of distributed coordination make HA mode unsafe. However:
- Kubernetes will restart the pod if it crashes
- Scheduled executions are recalculated on startup
- Minimal downtime risk in practice (stateless, fast startup)

### What happens if the scheduler pod crashes?

1. Kubernetes detects pod failure
2. Kubernetes starts a new scheduler pod
3. On startup, the scheduler:
   - Loads all ingestion sources from the database
   - Recalculates next execution times
   - Reschedules all jobs
4. Total recovery time: typically < 60 seconds

### Can I scale MAE consumers independently?

Yes! That's the whole point of this architecture:

```yaml
datahub-mae-consumer:
  replicaCount: 8  # Scale based on Kafka lag

datahub-scheduler:
  replicaCount: 1  # Always 1
```

MAE consumers can scale from 1-8+ replicas based on:
- Kafka consumer lag
- Event processing throughput
- Resource availability

### What if I really need the scheduler embedded in MAE consumer?

**Don't do this in production!** But if you must (e.g., for testing):

```yaml
global:
  datahub:
    scheduler:
      enabled: false  # Disable dedicated scheduler
  kafka:
    metadataChangeLog:
      hooks:
        ingestionScheduler:
          enabled: true  # Enable on MAE consumer

datahub-mae-consumer:
  replicaCount: 1  # MUST be 1 to avoid duplicates
```

**Consequences:**
- ❌ MAE consumer cannot scale beyond 1 replica
- ❌ Loss of separation of concerns
- ❌ Not the production-tested pattern
- ❌ 0% of production deployments use this pattern

## Contributing

Found an issue or have suggestions? Please:
1. Check the [DataHub Slack](https://datahubspace.slack.com)
2. Open an issue on [GitHub](https://github.com/datahub-project/datahub)
3. Reference this documentation when reporting scheduler-related issues
