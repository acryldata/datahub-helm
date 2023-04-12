# datahub-gms

![Version: 0.2.150](https://img.shields.io/badge/Version-0.2.150-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.10.0](https://img.shields.io/badge/AppVersion-v0.10.0-informational?style=flat-square)

A Helm chart for LinkedIn DataHub's datahub-gms component

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| extraEnvs | list | `[]` |  |
| extraInitContainers | list | `[]` |  |
| extraLabels | object | `{}` |  |
| extraVolumeMounts | list | `[]` |  |
| extraVolumes | list | `[]` |  |
| fullnameOverride | string | `""` |  |
| global.datahub.alwaysEmitChangeLog | bool | `true` |  |
| global.datahub.appVersion | string | `"1.0"` |  |
| global.datahub.cache.search.enabled | bool | `false` |  |
| global.datahub.cache.search.homepage.entityCounts.ttlSeconds | int | `600` |  |
| global.datahub.cache.search.lineage.enabled | bool | `false` |  |
| global.datahub.cache.search.lineage.lightningThreshold | int | `300` |  |
| global.datahub.cache.search.lineage.ttlSeconds | int | `86400` |  |
| global.datahub.cache.search.primary.maxSize | int | `10000` |  |
| global.datahub.cache.search.primary.ttlSeconds | int | `600` |  |
| global.datahub.enableGraphDiffMode | bool | `true` |  |
| global.datahub.enable_retention | bool | `false` |  |
| global.datahub.encryptionKey.secretKey | string | `"encryption-key-secret"` |  |
| global.datahub.encryptionKey.secretRef | string | `"encryption-key-secret"` |  |
| global.datahub.gms.port | string | `"8080"` |  |
| global.datahub.managed_ingestion.enabled | bool | `true` |  |
| global.datahub.metadata_service_authentication.enabled | bool | `false` |  |
| global.datahub.metadata_service_authentication.systemClientId | string | `"__datahub_system"` |  |
| global.datahub.monitoring.enableJMXPort | bool | `false` |  |
| global.datahub.monitoring.enablePrometheus | bool | `false` |  |
| global.datahub.systemUpdate.enabled | bool | `true` |  |
| global.datahub.version | string | `"head"` |  |
| global.datahub_analytics_enabled | bool | `true` |  |
| global.elasticsearch.host | string | `"elasticsearch"` |  |
| global.elasticsearch.port | string | `"9200"` |  |
| global.elasticsearch.skipcheck | string | `"false"` |  |
| global.graph_service_impl | string | `"neo4j"` |  |
| global.hostAliases[0].hostnames[0] | string | `"broker"` |  |
| global.hostAliases[0].hostnames[1] | string | `"mysql"` |  |
| global.hostAliases[0].hostnames[2] | string | `"elasticsearch"` |  |
| global.hostAliases[0].hostnames[3] | string | `"neo4j"` |  |
| global.hostAliases[0].ip | string | `"192.168.0.104"` |  |
| global.kafka.bootstrap.server | string | `"broker:9092"` |  |
| global.kafka.schemaregistry.url | string | `"http://schema-registry:8081"` |  |
| global.neo4j.host | string | `"neo4j:7474"` |  |
| global.neo4j.password.secretKey | string | `"neo4j-password"` |  |
| global.neo4j.password.secretRef | string | `"neo4j-secrets"` |  |
| global.neo4j.uri | string | `"bolt://neo4j"` |  |
| global.neo4j.username | string | `"neo4j"` |  |
| global.sql.datasource.driver | string | `"com.mysql.cj.jdbc.Driver"` |  |
| global.sql.datasource.host | string | `"mysql:3306"` |  |
| global.sql.datasource.password.secretKey | string | `"mysql-password"` |  |
| global.sql.datasource.password.secretRef | string | `"mysql-secrets"` |  |
| global.sql.datasource.url | string | `"jdbc:mysql://mysql:3306/datahub?verifyServerCertificate=false&useSSL=true"` |  |
| global.sql.datasource.username | string | `"datahub"` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"linkedin/datahub-gms"` |  |
| image.tag | string | `nil` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.enabled | bool | `false` |  |
| ingress.extraLabels | object | `{}` |  |
| ingress.hosts[0].host | string | `"chart-example.local"` |  |
| ingress.hosts[0].paths | list | `[]` |  |
| ingress.hosts[0].redirectPaths | list | `[]` |  |
| ingress.tls | list | `[]` |  |
| initContainers[0].command[0] | string | `"sh"` |  |
| initContainers[0].command[1] | string | `"-c"` |  |
| initContainers[0].command[2] | string | `"{{- if or .Release.IsInstall .Release.IsUpgrade .Release.IsRollback }}\necho \"Waiting for {{ .Release.Name }}-datahub-system-update-job\"\nkubectl wait --for=condition=complete job/{{ .Release.Name }}-datahub-system-update-job --timeout=300s\nkubectl delete job {{ .Release.Name }}-datahub-system-update-job\n{{- end }}\n"` |  |
| initContainers[0].image | string | `"bitnami/kubectl:latest"` |  |
| initContainers[0].name | string | `"wait-for-system-update"` |  |
| livenessProbe.failureThreshold | int | `8` |  |
| livenessProbe.initialDelaySeconds | int | `60` |  |
| livenessProbe.periodSeconds | int | `30` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| readinessProbe.failureThreshold | int | `8` |  |
| readinessProbe.initialDelaySeconds | int | `60` |  |
| readinessProbe.periodSeconds | int | `30` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| revisionHistoryLimit | int | `10` |  |
| securityContext | object | `{}` |  |
| service.annotations | object | `{}` |  |
| service.name | string | `"http"` |  |
| service.port | string | `"8080"` |  |
| service.protocol | string | `"TCP"` |  |
| service.targetPort | string | `"http"` |  |
| service.type | string | `"LoadBalancer"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `"datahub-gms"` |  |
| serviceMonitor.create | bool | `false` |  |
| tolerations | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
