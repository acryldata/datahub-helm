{{/*
IAM Authentication Validation
This template validates IAM authentication configuration and requirements.
*/}}

{{- define "datahub.validate.iam.setup" -}}

{{/*
Validate: SQL IAM authentication requires datahubSystemUpdate.sql.setup.enabled=true
*/}}
{{- if and .Values.global.sql.iam.enabled (not .Values.datahubSystemUpdate.sql.setup.enabled) (not (.Values.global.datahub.systemUpdate.consolidatedUpgrade | default true)) -}}
{{- fail "ERROR: datahubSystemUpdate.sql.setup.enabled must be true when global.sql.iam.enabled is true (or set global.datahub.systemUpdate.consolidatedUpgrade=true). When using IAM authentication, SQL setup must be handled by the system-update job. Please set datahubSystemUpdate.sql.setup.enabled=true." -}}
{{- end -}}

{{/*
Validate: MySQL/PostgreSQL Setup Job cannot be enabled with SQL IAM authentication
*/}}
{{- if and .Values.global.sql.iam.enabled .Values.mysqlSetupJob.enabled (not (.Values.global.datahub.systemUpdate.consolidatedUpgrade | default true)) -}}
{{- fail "ERROR: mysqlSetupJob.enabled cannot be true when global.sql.iam.enabled is true. When using IAM authentication, SQL setup is handled by the system-update job via datahubSystemUpdate.sql.setup.enabled. Please set mysqlSetupJob.enabled=false." -}}
{{- end -}}

{{- if and .Values.global.sql.iam.enabled .Values.postgresqlSetupJob.enabled (not (.Values.global.datahub.systemUpdate.consolidatedUpgrade | default true)) -}}
{{- fail "ERROR: postgresqlSetupJob.enabled cannot be true when global.sql.iam.enabled is true. When using IAM authentication, SQL setup is handled by the system-update job via datahubSystemUpdate.sql.setup.enabled. Please set postgresqlSetupJob.enabled=false." -}}
{{- end -}}

{{/*
Validate: Elasticsearch Setup Job cannot be enabled with OpenSearch IAM authentication
*/}}
{{- if and .Values.global.elasticsearch.iam.enabled .Values.elasticsearchSetupJob.enabled (not (.Values.global.datahub.systemUpdate.consolidatedUpgrade | default true)) -}}
{{- fail "ERROR: elasticsearchSetupJob.enabled cannot be true when global.elasticsearch.iam.enabled is true. When using IAM authentication, index setup is handled automatically by the system-update job via BuildIndices. Please set elasticsearchSetupJob.enabled=false." -}}
{{- end -}}

{{/*
Validate: Kafka Setup Job cannot be enabled with MSK IAM authentication
*/}}
{{- if and .Values.global.kafka.iam.enabled .Values.kafkaSetupJob.enabled (not (.Values.global.datahub.systemUpdate.consolidatedUpgrade | default true)) -}}
{{- fail "ERROR: kafkaSetupJob.enabled cannot be true when global.kafka.iam.enabled is true. When using IAM authentication, Kafka topic setup is handled automatically by the system-update job via KafkaSetup. Please set kafkaSetupJob.enabled=false." -}}
{{- end -}}

{{- end -}}
