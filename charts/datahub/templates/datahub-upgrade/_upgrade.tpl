{{/* vim: set filetype=mustache: */}}
{{/*
Return the env variables for upgrade jobs
*/}}
{{- define "datahub.upgrade.env" -}}
{{- if .Values.global.basePath.enabled }}
- name: DATAHUB_BASE_PATH
  value: {{ .Values.global.basePath.frontend | quote }}
- name: DATAHUB_GMS_BASE_PATH
  value: {{ .Values.global.basePath.gms | quote }}
{{- end }}
- name: ENTITY_REGISTRY_CONFIG_PATH
  value: /datahub/datahub-gms/resources/entity-registry.yml
- name: DATAHUB_GMS_HOST
  value: {{ (((.Values.datahub).gms).host | default ((.Values.global.datahub).gms).host) | default (printf "%s-%s" .Release.Name "datahub-gms") | trunc 63 | trimSuffix "-"}}
- name: DATAHUB_GMS_PORT
  value: "{{ ((.Values.datahub).gms).port | default .Values.global.datahub.gms.port }}"
- name: DATAHUB_MAE_CONSUMER_HOST
  value: {{ printf "%s-%s" .Release.Name "datahub-mae-consumer" }}
- name: DATAHUB_MAE_CONSUMER_PORT
  value: "{{ .Values.global.datahub.mae_consumer.port }}"
{{- include "datahub.sql.connection.env" . | nindent 0 }}
{{- include "datahub.sql.iam.env" . | nindent 0 }}
- name: KAFKA_BOOTSTRAP_SERVER
  value: "{{ .Values.global.kafka.bootstrap.server }}"
{{- with .Values.global.kafka.maxMessageBytes }}
- name: MAX_MESSAGE_BYTES
  value: {{ . | quote }}
{{- end }}
{{- if or (eq .Values.global.kafka.schemaregistry.type "INTERNAL") (eq .Values.global.kafka.schemaregistry.type "AWS_GLUE") }}
- name: USE_CONFLUENT_SCHEMA_REGISTRY
  value: "false"
{{- else if eq .Values.global.kafka.schemaregistry.type "KAFKA" }}
- name: USE_CONFLUENT_SCHEMA_REGISTRY
  value: "true"
{{- end }}
{{- with .Values.global.kafka.partitions }}
- name: PARTITIONS
  value: {{ . | quote }}
{{- end }}
{{- with .Values.global.kafka.replicationFactor }}
- name: REPLICATION_FACTOR
  value: {{ . | quote }}
{{- end }}
{{- with .Values.global.kafka.producer.compressionType }}
- name: KAFKA_PRODUCER_COMPRESSION_TYPE
  value: "{{ . }}"
{{- end }}
{{- with .Values.global.kafka.producer.maxRequestSize }}
- name: KAFKA_PRODUCER_MAX_REQUEST_SIZE
  value: {{ . | quote }}
{{- end }}
{{- with .Values.global.kafka.consumer.maxPartitionFetchBytes }}
- name: KAFKA_CONSUMER_MAX_PARTITION_FETCH_BYTES
  value: {{ . | quote }}
{{- end }}
{{- if eq .Values.global.kafka.schemaregistry.type "INTERNAL" }}
- name: KAFKA_SCHEMAREGISTRY_URL
  value: {{ printf "http://%s-%s:%s%s/schema-registry/api/" .Release.Name "datahub-gms" .Values.global.datahub.gms.port (ternary .Values.global.basePath.gms "" .Values.global.basePath.enabled) }}
{{- else if eq .Values.global.kafka.schemaregistry.type "KAFKA" }}
- name: KAFKA_SCHEMAREGISTRY_URL
  value: "{{ .Values.global.kafka.schemaregistry.url }}"
{{- end }}
{{- with .Values.global.kafka.schemaregistry.type }}
- name: SCHEMA_REGISTRY_TYPE
  value: "{{ . }}"
{{- end }}
{{- with .Values.global.kafka.schemaregistry.glue }}
- name: AWS_GLUE_SCHEMA_REGISTRY_REGION
  value: "{{ .region }}"
{{- with .registry }}
- name: AWS_GLUE_SCHEMA_REGISTRY_NAME
  value: "{{ . }}"
{{- end }}
{{- end }}
- name: SPRING_KAFKA_PRODUCER_PROPERTIES_MAX_REQUEST_SIZE
  value: {{ .Values.global.kafkaMaxSize | quote }}
{{- include "datahub.elasticsearch.connection.env" . | nindent 0 }}
- name: GRAPH_SERVICE_IMPL
  value: {{ $.Values.global.graph_service_impl | quote }}
{{- include "datahub.neo4j.connection.env" . | nindent 0 }}
{{- include "datahub.kafka.iam.env" . | nindent 0 }}
{{- include "datahub.spring.kafka.overrides" . | nindent 0 }}
{{- include "datahub.spring.kafka.credentials.env" . | nindent 0 }}
{{- include "datahub.elasticsearch.iam.env" . | nindent 0 }}
{{- with .Values.global.kafka.topics }}
- name: METADATA_CHANGE_EVENT_NAME
  value: {{ .metadata_change_event_name }}
- name: FAILED_METADATA_CHANGE_EVENT_NAME
  value: {{ .failed_metadata_change_event_name }}
- name: METADATA_AUDIT_EVENT_NAME
  value: {{ .metadata_audit_event_name }}
- name: METADATA_CHANGE_PROPOSAL_TOPIC_NAME
  value: {{ .metadata_change_proposal_topic_name }}
- name: FAILED_METADATA_CHANGE_PROPOSAL_TOPIC_NAME
  value: {{ .failed_metadata_change_proposal_topic_name }}
- name: METADATA_CHANGE_LOG_VERSIONED_TOPIC_NAME
  value: {{ .metadata_change_log_versioned_topic_name }}
- name: METADATA_CHANGE_LOG_TIMESERIES_TOPIC_NAME
  value: {{ .metadata_change_log_timeseries_topic_name }}
- name: DATAHUB_UPGRADE_HISTORY_TOPIC_NAME
  value: {{ .datahub_upgrade_history_topic_name }}
- name: PLATFORM_EVENT_TOPIC_NAME
  value: {{ .platform_event_topic_name }}
- name: DATAHUB_USAGE_EVENT_NAME
  value: {{ .datahub_usage_event_name }}
{{- end }}

{{- if .Values.global.cdc.enabled }}
- name: CDC_MCL_PROCESSING_ENABLED
  value: {{ .Values.global.cdc.enabled | quote }}
- name: CDC_CONFIGURE_SOURCE
  value: {{ .Values.global.cdc.configureSource | quote }}
- name: CDC_URN_KEY_SPEC
  value: {{ .Values.global.cdc.urnKeySpec | quote }}
- name: CDC_DB_TYPE
  value: {{ .Values.global.cdc.database.type | quote }}
- name: CDC_USER
  {{- $cdcUsernameValue := .Values.global.cdc.database.username }}
  {{- if and (kindIs "string" $cdcUsernameValue) $cdcUsernameValue }}
  value: {{ $cdcUsernameValue | quote }}
  {{- else }}
  valueFrom:
    secretKeyRef:
      name: "{{ .Values.global.cdc.database.username.secretRef }}"
      key: "{{ .Values.global.cdc.database.username.secretKey }}"
  {{- end }}
- name: CDC_PASSWORD
  {{- $cdcPasswordValue := .Values.global.cdc.database.password.value }}
  {{- if $cdcPasswordValue }}
  value: {{ $cdcPasswordValue | quote }}
  {{- else }}
  valueFrom:
    secretKeyRef:
      name: "{{ .Values.global.cdc.database.password.secretRef }}"
      key: "{{ .Values.global.cdc.database.password.secretKey }}"
  {{- end }}
- name: DATAHUB_CDC_CONNECTOR_NAME
  value: {{ .Values.global.cdc.debezium.connectorName | quote }}
- name: CDC_KAFKA_CONNECT_URL
  value: {{ .Values.global.cdc.debezium.kafkaConnectUrl | quote }}
- name: CDC_KAFKA_CONNECT_REQUEST_TIMEOUT
  value: {{ .Values.global.cdc.debezium.requestTimeout | quote }}
{{- if eq .Values.global.cdc.database.type "mysql" }}
- name: CDC_SERVER_ID
  value: {{ .Values.global.cdc.database.serverId | quote }}
{{- else if eq .Values.global.cdc.database.type "postgres" }}
- name: CDC_INCLUDE_TABLE
  value: {{ .Values.global.cdc.database.includeTable | quote }}
- name: CDC_INCLUDE_SCHEMA
  value: {{ .Values.global.cdc.database.includeSchema | quote }}
{{- end }}
{{- with .Values.global.cdc.debezium.connectorClass }}
- name: DEBEZIUM_CONNECTOR_CLASS
  value: {{ . | quote }}
{{- end }}
{{- with .Values.global.cdc.debezium.pluginName }}
- name: DEBEZIUM_PLUGIN_NAME
  value: {{ . | quote }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Set up cron hourly custom scheduling
*/}}
{{- define "datahub.upgrade.hourlyCronWindow" -}}
# Generate a random 2 digit numeric string, modulo 60
schedule: {{ printf "%d * * * * " (mod (randNumeric 2) 60) }}
{{- end -}}

{{- define "deepMerge" -}}
{{- $dst := deepCopy .dst -}}
{{- range $key, $srcValue := .src -}}
  {{- if hasKey $dst $key -}}
    {{- $dstValue := index $dst $key -}}
    {{- if and (kindIs "map" $dstValue) (kindIs "map" $srcValue) -}}
      {{- $newDst := dict "dst" $dstValue "src" $srcValue -}}
      {{- $mergedValue := include "deepMerge" $newDst | fromYaml -}}
      {{- $_ := set $dst $key $mergedValue -}}
    {{- else -}}
      {{- $_ := set $dst $key $srcValue -}}
    {{- end -}}
  {{- else -}}
    {{- $_ := set $dst $key $srcValue -}}
  {{- end -}}
{{- end -}}
{{- $dst | toYaml -}}
{{- end -}}

{{- define "randomHourInRange" -}}
{{- $start := index . 0 -}}
{{- $end := index . 1 -}}

{{- if eq $start $end -}}
  {{- $start -}}
{{- else -}}
  {{- $range := int64 0 -}}
  {{- if lt $end $start -}}
    {{- /* Range spans midnight */ -}}
    {{- $range = add (sub (int64 24) $start) $end -}}
  {{- else -}}
    {{- $range = sub $end $start -}}
  {{- end -}}
  {{- /* Generate a seed using a combination of methods */ -}}
  {{- $randomString := randAlphaNum 32 -}}
  {{- $checksum := adler32sum $randomString -}}
  {{- $currentTime := now | unixEpoch -}}
  {{- $seed := add (mod (mul $checksum 65537) 1000000) (mod $currentTime 1000000) -}}
  {{- $randomOffset := mod $seed (add $range 1) -}}
  {{- mod (add $start $randomOffset) 24 -}}
{{- end -}}
{{- end -}}

{{/*
datahubGC cron daily custom scheduling
*/}}
{{- define "datahub.systemUpdate.datahubGC.dailyCronWindow" -}}
{{- if hasKey (index .Values.datahubSystemUpdate.bootstrapMCPs.datahubGC.values "schedule" | default dict) "interval" -}}
schedule:
  interval: {{ .Values.datahubSystemUpdate.bootstrapMCPs.datahubGC.values.schedule.interval | quote }}
{{- else }}
schedule:
  interval: {{ printf "%d %s * * * " (mod (randNumeric 2) 60) (include "randomHourInRange" (list .Values.datahubSystemUpdate.bootstrapMCPs.datahubGC.dailyCronWindow.startHour .Values.datahubSystemUpdate.bootstrapMCPs.datahubGC.dailyCronWindow.endHour)) }}
{{- end }}
{{- end -}}

{{/*
  timezone
*/}}
{{- define "datahub.bootstrapMCPs.default.schedule.timezone" -}}
schedule:
  timezone: {{ .Values.global.datahub.timezone | quote }}
{{- end -}}

{{/*
  default cli version
*/}}
{{- define "datahub.bootstrapMCPs.default.ingestion.version" -}}
ingestion:
  version: {{ .Values.global.datahub.managed_ingestion.defaultCliVersion | quote }}
{{- end -}}
