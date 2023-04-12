# datahub

![Version: 0.3.0](https://img.shields.io/badge/Version-0.3.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.10.1](https://img.shields.io/badge/AppVersion-0.10.1-informational?style=flat-square)

A Helm chart for LinkedIn DataHub

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| DataHub | <datahub@acryl.io> |  |

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://./subcharts/acryl-datahub-actions | acryl-datahub-actions | 0.2.135 |
| file://./subcharts/datahub-frontend | datahub-frontend | 0.2.136 |
| file://./subcharts/datahub-gms | datahub-gms | 0.2.150 |
| file://./subcharts/datahub-ingestion-cron | datahub-ingestion-cron | 0.2.131 |
| file://./subcharts/datahub-mae-consumer | datahub-mae-consumer | 0.2.142 |
| file://./subcharts/datahub-mce-consumer | datahub-mce-consumer | 0.2.144 |
| https://confluentinc.github.io/cp-helm-charts/ | cp-helm-charts | 0.6.0 |
| https://equinor.github.io/helm-charts/charts/ | neo4j-community | 1.2.5 |
| https://helm.elastic.co | elasticsearch | 7.17.3 |
| https://neo4j-contrib.github.io/neo4j-helm/ | neo4j | 4.2.2-1 |
| https://raw.githubusercontent.com/bitnami/charts/archive-full-index/bitnami | kafka | 17.1.0 |
| https://raw.githubusercontent.com/bitnami/charts/archive-full-index/bitnami | mysql | 9.1.8 |
| https://raw.githubusercontent.com/bitnami/charts/archive-full-index/bitnami | postgresql | 11.6.6 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| acryl-datahub-actions.enabled | bool | `true` |  |
| acryl-datahub-actions.image.repository | string | `"acryldata/datahub-actions"` |  |
| acryl-datahub-actions.image.tag | string | `"v0.0.11"` |  |
| acryl-datahub-actions.resources.limits.memory | string | `"512Mi"` |  |
| acryl-datahub-actions.resources.requests.cpu | string | `"300m"` |  |
| acryl-datahub-actions.resources.requests.memory | string | `"256Mi"` |  |
| cp-helm-charts.cp-control-center.enabled | bool | `false` |  |
| cp-helm-charts.cp-kafka-connect.enabled | bool | `false` |  |
| cp-helm-charts.cp-kafka-rest.enabled | bool | `false` |  |
| cp-helm-charts.cp-kafka.enabled | bool | `false` |  |
| cp-helm-charts.cp-ksql-server.enabled | bool | `false` |  |
| cp-helm-charts.cp-schema-registry.enabled | bool | `true` |  |
| cp-helm-charts.cp-schema-registry.kafka.bootstrapServers | string | `"datahub-kafka:9092"` |  |
| cp-helm-charts.cp-zookeeper.enabled | bool | `false` |  |
| datahub-frontend.enabled | bool | `true` |  |
| datahub-frontend.image.repository | string | `"linkedin/datahub-frontend-react"` |  |
| datahub-frontend.ingress.enabled | bool | `false` |  |
| datahub-frontend.resources.limits.memory | string | `"1400Mi"` |  |
| datahub-frontend.resources.requests.cpu | string | `"100m"` |  |
| datahub-frontend.resources.requests.memory | string | `"512Mi"` |  |
| datahub-gms.enabled | bool | `true` |  |
| datahub-gms.image.repository | string | `"linkedin/datahub-gms"` |  |
| datahub-gms.resources.limits.memory | string | `"2Gi"` |  |
| datahub-gms.resources.requests.cpu | string | `"100m"` |  |
| datahub-gms.resources.requests.memory | string | `"1Gi"` |  |
| datahub-ingestion-cron.enabled | bool | `false` |  |
| datahub-ingestion-cron.image.repository | string | `"acryldata/datahub-ingestion"` |  |
| datahub-mae-consumer.image.repository | string | `"linkedin/datahub-mae-consumer"` |  |
| datahub-mae-consumer.resources.limits.memory | string | `"1536Mi"` |  |
| datahub-mae-consumer.resources.requests.cpu | string | `"100m"` |  |
| datahub-mae-consumer.resources.requests.memory | string | `"256Mi"` |  |
| datahub-mce-consumer.image.repository | string | `"linkedin/datahub-mce-consumer"` |  |
| datahub-mce-consumer.resources.limits.memory | string | `"1536Mi"` |  |
| datahub-mce-consumer.resources.requests.cpu | string | `"100m"` |  |
| datahub-mce-consumer.resources.requests.memory | string | `"256Mi"` |  |
| datahubSystemUpdate.image.repository | string | `"acryldata/datahub-upgrade"` |  |
| datahubSystemUpdate.initContainers[0].command[0] | string | `"sh"` |  |
| datahubSystemUpdate.initContainers[0].command[1] | string | `"-c"` |  |
| datahubSystemUpdate.initContainers[0].command[2] | string | `"echo \"Waiting for {{ .Release.Name }}-elasticsearch-setup-job\"\nkubectl wait --for=condition=complete job/{{ .Release.Name }}-elasticsearch-setup-job --timeout=300s\n"` |  |
| datahubSystemUpdate.initContainers[0].image | string | `"bitnami/kubectl:latest"` |  |
| datahubSystemUpdate.initContainers[0].name | string | `"wait-for-elasticsearch-setup"` |  |
| datahubSystemUpdate.initContainers[1].command[0] | string | `"sh"` |  |
| datahubSystemUpdate.initContainers[1].command[1] | string | `"-c"` |  |
| datahubSystemUpdate.initContainers[1].command[2] | string | `"echo \"Waiting for {{ .Release.Name }}-kafka-setup-job\"\nkubectl wait --for=condition=complete job/{{ .Release.Name }}-kafka-setup-job --timeout=300s\n"` |  |
| datahubSystemUpdate.initContainers[1].image | string | `"bitnami/kubectl:latest"` |  |
| datahubSystemUpdate.initContainers[1].name | string | `"wait-for-kafka-setup"` |  |
| datahubSystemUpdate.initContainers[2].command[0] | string | `"sh"` |  |
| datahubSystemUpdate.initContainers[2].command[1] | string | `"-c"` |  |
| datahubSystemUpdate.initContainers[2].command[2] | string | `"{{- if contains \"mysql\" .Values.global.sql.datasource.driver }}\necho \"Waiting for {{ .Release.Name }}-mysql-setup-job\"\nkubectl wait --for=condition=complete job/{{ .Release.Name }}-mysql-setup-job --timeout=300s\n{{ else if contains \"postgresql\" .Values.global.sql.datasource.driver }}\necho \"Waiting for {{ .Release.Name }}-postgresql-setup-job\"\nkubectl wait --for=condition=complete job/{{ .Release.Name }}-postgresql-setup-job --timeout=300s\n{{- end }}\n"` |  |
| datahubSystemUpdate.initContainers[2].image | string | `"bitnami/kubectl:latest"` |  |
| datahubSystemUpdate.initContainers[2].name | string | `"wait-for-database-setup"` |  |
| datahubSystemUpdate.podAnnotations | object | `{}` |  |
| datahubSystemUpdate.podSecurityContext | object | `{}` |  |
| datahubSystemUpdate.resources.limits.cpu | string | `"500m"` |  |
| datahubSystemUpdate.resources.limits.memory | string | `"512Mi"` |  |
| datahubSystemUpdate.resources.requests.cpu | string | `"300m"` |  |
| datahubSystemUpdate.resources.requests.memory | string | `"256Mi"` |  |
| datahubSystemUpdate.securityContext | object | `{}` |  |
| datahubUpgrade.batchDelayMs | int | `100` |  |
| datahubUpgrade.batchSize | int | `1000` |  |
| datahubUpgrade.enabled | bool | `true` |  |
| datahubUpgrade.image.repository | string | `"acryldata/datahub-upgrade"` |  |
| datahubUpgrade.initContainers[0].command[0] | string | `"sh"` |  |
| datahubUpgrade.initContainers[0].command[1] | string | `"-c"` |  |
| datahubUpgrade.initContainers[0].command[2] | string | `"export datahubGmsHost={{ printf \"%s:%s\" (printf \"%s-%s\" .Release.Name \"datahub-gms\") \"8080\" }}\nuntil curl -I --connect-timeout 5 http://${datahubGmsHost}/health; do\n  echo \"Waiting for http://${datahubGmsHost}/health\";\ndone;\n"` |  |
| datahubUpgrade.initContainers[0].image | string | `"curlimages/curl:latest"` |  |
| datahubUpgrade.initContainers[0].name | string | `"wait-for-datahub-gms"` |  |
| datahubUpgrade.podAnnotations | object | `{}` |  |
| datahubUpgrade.podSecurityContext | object | `{}` |  |
| datahubUpgrade.restoreIndices.resources.limits.cpu | string | `"500m"` |  |
| datahubUpgrade.restoreIndices.resources.limits.memory | string | `"512Mi"` |  |
| datahubUpgrade.restoreIndices.resources.requests.cpu | string | `"300m"` |  |
| datahubUpgrade.restoreIndices.resources.requests.memory | string | `"256Mi"` |  |
| datahubUpgrade.securityContext | object | `{}` |  |
| elasticsearch.antiAffinity | string | `"soft"` |  |
| elasticsearch.clusterHealthCheckParams | string | `"wait_for_status=yellow&timeout=1s"` |  |
| elasticsearch.enabled | bool | `true` |  |
| elasticsearch.esJavaOpts | string | `"-Xmx384m -Xms384m"` |  |
| elasticsearch.minimumMasterNodes | int | `1` |  |
| elasticsearch.replicas | int | `1` |  |
| elasticsearch.resources.limits.cpu | string | `"1000m"` |  |
| elasticsearch.resources.limits.memory | string | `"768M"` |  |
| elasticsearch.resources.requests.cpu | string | `"100m"` |  |
| elasticsearch.resources.requests.memory | string | `"768M"` |  |
| elasticsearchSetupJob.enabled | bool | `true` |  |
| elasticsearchSetupJob.image.repository | string | `"linkedin/datahub-elasticsearch-setup"` |  |
| elasticsearchSetupJob.initContainers[0].command[0] | string | `"/bin/sh"` |  |
| elasticsearchSetupJob.initContainers[0].command[1] | string | `"-c"` |  |
| elasticsearchSetupJob.initContainers[0].command[2] | string | `"export elasticsearchUrl={{ printf \"%s:%s\" .Values.global.elasticsearch.host .Values.global.elasticsearch.port }}\ndockerize -wait \"tcp://${elasticsearchUrl}/\" -timeout 360s\n"` |  |
| elasticsearchSetupJob.initContainers[0].image | string | `"jwilder/dockerize:latest"` |  |
| elasticsearchSetupJob.initContainers[0].name | string | `"wait-for-elasticsearch"` |  |
| elasticsearchSetupJob.podAnnotations | object | `{}` |  |
| elasticsearchSetupJob.podSecurityContext.fsGroup | int | `1000` |  |
| elasticsearchSetupJob.resources.limits.cpu | string | `"500m"` |  |
| elasticsearchSetupJob.resources.limits.memory | string | `"512Mi"` |  |
| elasticsearchSetupJob.resources.requests.cpu | string | `"300m"` |  |
| elasticsearchSetupJob.resources.requests.memory | string | `"256Mi"` |  |
| elasticsearchSetupJob.securityContext.runAsUser | int | `1000` |  |
| global.datahub.alwaysEmitChangeLog | bool | `true` |  |
| global.datahub.appVersion | string | `"1.0"` |  |
| global.datahub.enableGraphDiffMode | bool | `true` |  |
| global.datahub.encryptionKey.provisionSecret.autoGenerate | bool | `true` |  |
| global.datahub.encryptionKey.provisionSecret.enabled | bool | `true` |  |
| global.datahub.encryptionKey.secretKey | string | `"encryption_key_secret"` |  |
| global.datahub.encryptionKey.secretRef | string | `"datahub-encryption-secrets"` |  |
| global.datahub.gms.nodePort | string | `"30001"` |  |
| global.datahub.gms.port | string | `"8080"` |  |
| global.datahub.mae_consumer.nodePort | string | `"30002"` |  |
| global.datahub.mae_consumer.port | string | `"9091"` |  |
| global.datahub.managed_ingestion.defaultCliVersion | string | `"0.10.0"` |  |
| global.datahub.managed_ingestion.enabled | bool | `true` |  |
| global.datahub.metadata_service_authentication.enabled | bool | `false` |  |
| global.datahub.metadata_service_authentication.provisionSecrets.autoGenerate | bool | `true` |  |
| global.datahub.metadata_service_authentication.provisionSecrets.enabled | bool | `true` |  |
| global.datahub.metadata_service_authentication.systemClientId | string | `"__datahub_system"` |  |
| global.datahub.metadata_service_authentication.systemClientSecret.secretKey | string | `"system_client_secret"` |  |
| global.datahub.metadata_service_authentication.systemClientSecret.secretRef | string | `"datahub-auth-secrets"` |  |
| global.datahub.metadata_service_authentication.tokenService.salt.secretKey | string | `"token_service_salt"` |  |
| global.datahub.metadata_service_authentication.tokenService.salt.secretRef | string | `"datahub-auth-secrets"` |  |
| global.datahub.metadata_service_authentication.tokenService.signingKey.secretKey | string | `"token_service_signing_key"` |  |
| global.datahub.metadata_service_authentication.tokenService.signingKey.secretRef | string | `"datahub-auth-secrets"` |  |
| global.datahub.monitoring.enablePrometheus | bool | `true` |  |
| global.datahub.systemUpdate.enabled | bool | `true` |  |
| global.datahub.version | string | `"v0.10.1"` |  |
| global.datahub_analytics_enabled | bool | `true` |  |
| global.datahub_standalone_consumers_enabled | bool | `false` |  |
| global.elasticsearch.host | string | `"elasticsearch-master"` |  |
| global.elasticsearch.index.enableMappingsReindex | bool | `true` |  |
| global.elasticsearch.index.enableSettingsReindex | bool | `true` |  |
| global.elasticsearch.index.upgrade.allowDocCountMismatch | bool | `false` |  |
| global.elasticsearch.index.upgrade.cloneIndices | bool | `true` |  |
| global.elasticsearch.insecure | string | `"false"` |  |
| global.elasticsearch.port | string | `"9200"` |  |
| global.elasticsearch.search.exactMatch.caseSensitivityFactor | float | `0.7` |  |
| global.elasticsearch.search.exactMatch.enableStructured | bool | `true` |  |
| global.elasticsearch.search.exactMatch.exactFactor | float | `2` |  |
| global.elasticsearch.search.exactMatch.exclusive | bool | `false` |  |
| global.elasticsearch.search.exactMatch.prefixFactor | float | `1.6` |  |
| global.elasticsearch.search.exactMatch.withPrefix | bool | `true` |  |
| global.elasticsearch.search.graph.batchSize | int | `1000` |  |
| global.elasticsearch.search.graph.maxResult | int | `10000` |  |
| global.elasticsearch.search.graph.timeoutSeconds | int | `50` |  |
| global.elasticsearch.search.maxTermBucketSize | int | `20` |  |
| global.elasticsearch.skipcheck | string | `"false"` |  |
| global.elasticsearch.useSSL | string | `"false"` |  |
| global.graph_service_impl | string | `"elasticsearch"` |  |
| global.kafka.bootstrap.server | string | `"datahub-kafka:9092"` |  |
| global.kafka.schemaregistry.type | string | `"KAFKA"` |  |
| global.kafka.schemaregistry.url | string | `"http://datahub-cp-schema-registry:8081"` |  |
| global.kafka.topics.datahub_upgrade_history_topic_name | string | `"DataHubUpgradeHistory_v1"` |  |
| global.kafka.topics.datahub_usage_event_name | string | `"DataHubUsageEvent_v1"` |  |
| global.kafka.topics.failed_metadata_change_event_name | string | `"FailedMetadataChangeEvent_v4"` |  |
| global.kafka.topics.failed_metadata_change_proposal_topic_name | string | `"FailedMetadataChangeProposal_v1"` |  |
| global.kafka.topics.metadata_audit_event_name | string | `"MetadataAuditEvent_v4"` |  |
| global.kafka.topics.metadata_change_event_name | string | `"MetadataChangeEvent_v4"` |  |
| global.kafka.topics.metadata_change_log_timeseries_topic_name | string | `"MetadataChangeLog_Timeseries_v1"` |  |
| global.kafka.topics.metadata_change_log_versioned_topic_name | string | `"MetadataChangeLog_Versioned_v1"` |  |
| global.kafka.topics.metadata_change_proposal_topic_name | string | `"MetadataChangeProposal_v1"` |  |
| global.kafka.topics.platform_event_topic_name | string | `"PlatformEvent_v1"` |  |
| global.kafka.zookeeper.server | string | `"datahub-zookeeper:2181"` |  |
| global.neo4j.host | string | `"datahub-neo4j-community:7474"` |  |
| global.neo4j.password.secretKey | string | `"neo4j-password"` |  |
| global.neo4j.password.secretRef | string | `"neo4j-secrets"` |  |
| global.neo4j.uri | string | `"bolt://datahub-neo4j-community"` |  |
| global.neo4j.username | string | `"neo4j"` |  |
| global.sql.datasource.driver | string | `"com.mysql.cj.jdbc.Driver"` |  |
| global.sql.datasource.host | string | `"datahub-mysql:3306"` |  |
| global.sql.datasource.hostForMysqlClient | string | `"datahub-mysql"` |  |
| global.sql.datasource.password.secretKey | string | `"mysql-root-password"` |  |
| global.sql.datasource.password.secretRef | string | `"mysql-secrets"` |  |
| global.sql.datasource.port | string | `"3306"` |  |
| global.sql.datasource.url | string | `"jdbc:mysql://datahub-mysql:3306/datahub?verifyServerCertificate=false&useSSL=true&useUnicode=yes&characterEncoding=UTF-8&enabledTLSProtocols=TLSv1.2"` |  |
| global.sql.datasource.username | string | `"root"` |  |
| global.strict_mode | bool | `true` |  |
| kafka.enabled | bool | `true` |  |
| kafkaSetupJob.enabled | bool | `true` |  |
| kafkaSetupJob.image.repository | string | `"linkedin/datahub-kafka-setup"` |  |
| kafkaSetupJob.initContainers[0].command[0] | string | `"/bin/sh"` |  |
| kafkaSetupJob.initContainers[0].command[1] | string | `"-c"` |  |
| kafkaSetupJob.initContainers[0].command[2] | string | `"dockerize -wait \"tcp://{{ .Values.global.kafka.bootstrap.server | quote }}/\" -timeout 360s"` |  |
| kafkaSetupJob.initContainers[0].image | string | `"jwilder/dockerize:latest"` |  |
| kafkaSetupJob.initContainers[0].name | string | `"wait-for-kafka"` |  |
| kafkaSetupJob.podAnnotations | object | `{}` |  |
| kafkaSetupJob.podSecurityContext.fsGroup | int | `1000` |  |
| kafkaSetupJob.resources.limits.cpu | string | `"500m"` |  |
| kafkaSetupJob.resources.limits.memory | string | `"1024Mi"` |  |
| kafkaSetupJob.resources.requests.cpu | string | `"300m"` |  |
| kafkaSetupJob.resources.requests.memory | string | `"768Mi"` |  |
| kafkaSetupJob.securityContext.runAsUser | int | `1000` |  |
| mysql.auth.existingSecret | string | `"mysql-secrets"` |  |
| mysql.enabled | bool | `true` |  |
| mysqlSetupJob.enabled | bool | `true` |  |
| mysqlSetupJob.image.repository | string | `"acryldata/datahub-mysql-setup"` |  |
| mysqlSetupJob.initContainers[0].command[0] | string | `"/bin/sh"` |  |
| mysqlSetupJob.initContainers[0].command[1] | string | `"-c"` |  |
| mysqlSetupJob.initContainers[0].command[2] | string | `"mysqlUrl={{ printf \"%s:%s\" .Values.global.sql.datasource.hostForMysqlClient .Values.global.sql.datasource.port }}\ndockerize -wait \"tcp://${mysqlUrl}/\" -timeout 360s\n"` |  |
| mysqlSetupJob.initContainers[0].image | string | `"jwilder/dockerize:latest"` |  |
| mysqlSetupJob.initContainers[0].name | string | `"wait-for-mysql"` |  |
| mysqlSetupJob.podAnnotations | object | `{}` |  |
| mysqlSetupJob.podSecurityContext.fsGroup | int | `1000` |  |
| mysqlSetupJob.resources.limits.cpu | string | `"500m"` |  |
| mysqlSetupJob.resources.limits.memory | string | `"512Mi"` |  |
| mysqlSetupJob.resources.requests.cpu | string | `"300m"` |  |
| mysqlSetupJob.resources.requests.memory | string | `"256Mi"` |  |
| mysqlSetupJob.securityContext.runAsUser | int | `1000` |  |
| neo4j-community.acceptLicenseAgreement | string | `"yes"` |  |
| neo4j-community.defaultDatabase | string | `"graph.db"` |  |
| neo4j-community.enabled | bool | `false` |  |
| neo4j-community.existingPasswordSecret | string | `"neo4j-secrets"` |  |
| neo4j.acceptLicenseAgreement | string | `"yes"` |  |
| neo4j.core.standalone | bool | `true` |  |
| neo4j.defaultDatabase | string | `"graph.db"` |  |
| neo4j.enabled | bool | `false` |  |
| neo4j.neo4jPassword | string | `"datahub"` |  |
| postgresql.auth.existingSecret | string | `"postgresql-secrets"` |  |
| postgresql.enabled | bool | `false` |  |
| postgresqlSetupJob.enabled | bool | `false` |  |
| postgresqlSetupJob.image.repository | string | `"acryldata/datahub-postgres-setup"` |  |
| postgresqlSetupJob.initContainers[0].command[0] | string | `"/bin/sh"` |  |
| postgresqlSetupJob.initContainers[0].command[1] | string | `"-c"` |  |
| postgresqlSetupJob.initContainers[0].command[2] | string | `"export postgresqlUrl={{ printf \"%s:%s\" .Values.global.sql.datasource.hostForpostgresqlClient .Values.global.sql.datasource.port }}\ndockerize -wait \"tcp://${postgresqlUrl}/\" -timeout 360s\n"` |  |
| postgresqlSetupJob.initContainers[0].image | string | `"jwilder/dockerize:latest"` |  |
| postgresqlSetupJob.initContainers[0].name | string | `"wait-for-postgresql"` |  |
| postgresqlSetupJob.podAnnotations | object | `{}` |  |
| postgresqlSetupJob.podSecurityContext.fsGroup | int | `1000` |  |
| postgresqlSetupJob.resources.limits.cpu | string | `"500m"` |  |
| postgresqlSetupJob.resources.limits.memory | string | `"512Mi"` |  |
| postgresqlSetupJob.resources.requests.cpu | string | `"300m"` |  |
| postgresqlSetupJob.resources.requests.memory | string | `"256Mi"` |  |
| postgresqlSetupJob.securityContext.runAsUser | int | `1000` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
