{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "datahub-mce-consumer.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "datahub-mce-consumer.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "datahub-mce-consumer.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "datahub-mce-consumer.labels" -}}
helm.sh/chart: {{ include "datahub-mce-consumer.chart" . }}
{{ include "datahub-mce-consumer.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "datahub-mce-consumer.selectorLabels" -}}
app.kubernetes.io/name: {{ include "datahub-mce-consumer.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "datahub-mce-consumer.serviceAccountName" -}}
{{- if .Values.serviceAccount.name -}}
{{- .Values.serviceAccount.name -}}
{{- else if and .Values.global.datahub.appServiceAccount .Values.global.datahub.appServiceAccount.name -}}
{{- .Values.global.datahub.appServiceAccount.name -}}
{{- else if .Values.serviceAccount.create -}}
{{- default (include "datahub-mce-consumer.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{/*
Create the jvm debug flag
*/}}
{{- define "acryl.debug" -}}
{{- if .Values.debug.enabled -}}
  {{- if .Values.debug.suspend -}}
    {{ "-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005" | quote }}
  {{- else -}}
    {{ "-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005" | quote }}
  {{- end -}}
{{- else -}}
  {{- "" -}}
{{- end -}}
{{- end -}}

{{/*
Kafka IAM environment variables for AWS MSK authentication if enabled.
For Java/Spring-based services that use Spring Kafka.
*/}}
{{- define "datahub.kafka.iam.env" -}}
{{- if .Values.global.kafka.iam.enabled -}}
- name: SPRING_KAFKA_PROPERTIES_SASL_CLIENT_CALLBACK_HANDLER_CLASS
  value: software.amazon.msk.auth.iam.IAMClientCallbackHandler
- name: SPRING_KAFKA_PROPERTIES_SASL_JAAS_CONFIG
  value: software.amazon.msk.auth.iam.IAMLoginModule required;
- name: SPRING_KAFKA_PROPERTIES_SASL_MECHANISM
  value: AWS_MSK_IAM
- name: SPRING_KAFKA_PROPERTIES_SSL_PROTOCOL
  value: TLS
- name: SPRING_KAFKA_PROPERTIES_SECURITY_PROTOCOL
  value: SASL_SSL
{{- end -}}
{{- end -}}

{{/*
OpenSearch/Elasticsearch IAM authentication environment variables for AWS OpenSearch.
*/}}
{{- define "datahub.elasticsearch.iam.env" -}}
{{- if .Values.global.elasticsearch.iam.enabled }}
{{- if and .Values.global.elasticsearch.region .Values.global.kafka.region }}
{{- if ne .Values.global.elasticsearch.region .Values.global.kafka.region }}
{{- fail (printf "AWS_REGION mismatch: Kafka region (%s) differs from OpenSearch region (%s). Both must be in the same region for IAM authentication." .Values.global.kafka.region .Values.global.elasticsearch.region) }}
{{- end }}
{{- end }}
- name: OPENSEARCH_USE_AWS_IAM_AUTH
  value: "true"
{{- if .Values.global.elasticsearch.region }}
- name: AWS_REGION
  value: {{ .Values.global.elasticsearch.region | quote }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
global.datahub.monitoring metricsMode: legacy | jmx_and_actuator | actuator_only (default legacy).
*/}}
{{- define "datahub-mce-consumer.monitoring.metricsMode" -}}
{{- .Values.global.datahub.monitoring.metricsMode | default "legacy" | trim -}}
{{- end -}}

{{- define "datahub-mce-consumer.monitoring.jmxPort" -}}
{{- int (.Values.global.datahub.monitoring.jmxPort | default 4318) -}}
{{- end -}}

{{- define "datahub-mce-consumer.monitoring.actuatorPrometheusPort" -}}
{{- int (.Values.global.datahub.monitoring.actuatorPrometheusPort | default 4319) -}}
{{- end -}}

{{- define "datahub-mce-consumer.monitoring.jmxMetricsPath" -}}
{{- (.Values.global.datahub.monitoring.jmxExporter | default dict).metricsPath | default "/metrics" -}}
{{- end -}}

{{/*
Kubernetes httpGet port name for liveness/readiness: when metricsMode moves Spring actuator to actuatorPrometheusPort,
/actuator/health must be probed on the "prometheus" container port, not the main "http" port.
*/}}
{{- define "datahub-mce-consumer.monitoring.healthProbePortName" -}}
{{- $mode := include "datahub-mce-consumer.monitoring.metricsMode" . -}}
{{- if and .Values.global.datahub.monitoring.enablePrometheus (or (eq $mode "jmx_and_actuator") (eq $mode "actuator_only")) -}}
prometheus
{{- else -}}
http
{{- end -}}
{{- end -}}
