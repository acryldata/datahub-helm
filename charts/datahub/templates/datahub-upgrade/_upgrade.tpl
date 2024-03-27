{{/* vim: set filetype=mustache: */}}
{{/*
Return the env variables for upgrade jobs
*/}}
{{- define "datahub.upgrade.env" -}}
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
- name: EBEAN_DATASOURCE_USERNAME
  {{- $usernameValue := (.Values.sql).datasource.username | default .Values.global.sql.datasource.username }}
  {{- if and (kindIs "string" $usernameValue) $usernameValue }}
  value: {{ $usernameValue | quote }}
  {{- else }}
  valueFrom:
    secretKeyRef:
      name: "{{ (.Values.sql).datasource.username.secretRef | default .Values.global.sql.datasource.username.secretRef }}"
      key: "{{ (.Values.sql).datasource.username.secretKey | default .Values.global.sql.datasource.username.secretKey }}"
  {{- end }}
- name: EBEAN_DATASOURCE_PASSWORD
  {{- $passwordValue := (.Values.sql).datasource.password.value | default .Values.global.sql.datasource.password.value }}
  {{- if $passwordValue }}
  value: {{ $passwordValue | quote }}
  {{- else }}
  valueFrom:
    secretKeyRef:
      name: "{{ (.Values.sql).datasource.password.secretRef | default .Values.global.sql.datasource.password.secretRef }}"
      key: "{{ (.Values.sql).datasource.password.secretKey | default .Values.global.sql.datasource.password.secretKey }}"
  {{- end }}
- name: EBEAN_DATASOURCE_HOST
  value: "{{ .Values.global.sql.datasource.host }}"
- name: EBEAN_DATASOURCE_URL
  value: "{{ .Values.global.sql.datasource.url }}"
- name: EBEAN_DATASOURCE_DRIVER
  value: "{{ .Values.global.sql.datasource.driver }}"
- name: KAFKA_BOOTSTRAP_SERVER
  value: "{{ .Values.global.kafka.bootstrap.server }}"
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
  value: {{ printf "http://%s-%s:%s/schema-registry/api/" .Release.Name "datahub-gms" .Values.global.datahub.gms.port }}
{{- else if eq .Values.global.kafka.schemaregistry.type "KAFKA" }}
- name: KAFKA_SCHEMAREGISTRY_URL
  value: "{{ .Values.global.kafka.schemaregistry.url }}"
{{- end }}
- name: ELASTICSEARCH_HOST
  value: {{ .Values.global.elasticsearch.host | quote }}
- name: ELASTICSEARCH_PORT
  value: {{ .Values.global.elasticsearch.port | quote }}
- name: SKIP_ELASTICSEARCH_CHECK
  value: {{ .Values.global.elasticsearch.skipcheck | quote }}
- name: ELASTICSEARCH_INSECURE
  value: {{ .Values.global.elasticsearch.insecure | quote }}
{{- with .Values.global.elasticsearch.useSSL }}
- name: ELASTICSEARCH_USE_SSL
  value: {{ . | quote }}
{{- end }}
{{- with .Values.global.elasticsearch.auth }}
- name: ELASTICSEARCH_USERNAME
  value: {{ .username }}
- name: ELASTICSEARCH_PASSWORD
  {{- if .password.value }}
  value: {{ .password.value | quote }}
  {{- else }}
  valueFrom:
    secretKeyRef:
      name: "{{ .password.secretRef }}"
      key: "{{ .password.secretKey }}"
  {{- end }}
{{- end }}
{{- with .Values.global.elasticsearch.indexPrefix }}
- name: INDEX_PREFIX
  value: {{ . }}
{{- end }}
- name: GRAPH_SERVICE_IMPL
  value: {{ .Values.global.graph_service_impl }}
{{- if eq .Values.global.graph_service_impl "neo4j" }}
- name: NEO4J_HOST
  value: "{{ .Values.global.neo4j.host }}"
- name: NEO4J_URI
  value: "{{ .Values.global.neo4j.uri }}"
- name: NEO4J_DATABASE
  value: "{{ .Values.global.neo4j.database | default "graph.db" }}"
- name: NEO4J_USERNAME
  value: "{{ .Values.global.neo4j.username }}"
- name: NEO4J_PASSWORD
  {{- if .Values.global.neo4j.password.value }}
  value: {{ .Values.global.neo4j.password.value | quote }}
  {{- else }}
  valueFrom:
    secretKeyRef:
      name: "{{ .Values.global.neo4j.password.secretRef }}"
      key: "{{ .Values.global.neo4j.password.secretKey }}"
  {{- end }}
{{- end }}
{{- if .Values.global.springKafkaConfigurationOverrides }}
{{- range $configName, $configValue := .Values.global.springKafkaConfigurationOverrides }}
- name: SPRING_KAFKA_PROPERTIES_{{ $configName | replace "." "_" | upper }}
  value: {{ $configValue | quote }}
{{- end }}
{{- end }}
{{- if .Values.global.credentialsAndCertsSecrets }}
{{- range $envVarName, $envVarValue := .Values.global.credentialsAndCertsSecrets.secureEnv }}
- name: SPRING_KAFKA_PROPERTIES_{{ $envVarName | replace "." "_" | upper }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.global.credentialsAndCertsSecrets.name }}
      key: {{ $envVarValue }}
{{- end }}
{{- end }}
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
{{- end }}
{{- end -}}
