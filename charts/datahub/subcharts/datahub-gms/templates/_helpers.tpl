{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "datahub-gms.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "datahub-gms.fullname" -}}
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
{{- define "datahub-gms.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Resolved GMS image / DataHub release version (subchart image.tag when set, else global.datahub.version).
Same as template "datahub.image" tag; used for datahub.acryl.io/datahub-version and Hazelcast selection.
*/}}
{{- define "datahub-gms.deploymentAppVersion" -}}
{{- .Values.image.tag | default .Values.global.datahub.version -}}
{{- end -}}

{{/*
Standard Helm/Kubernetes app version (Chart.AppVersion) plus deployed DataHub image version label.
*/}}
{{- define "datahub-gms.applicationVersionLabels" -}}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- $dv := include "datahub-gms.deploymentAppVersion" . -}}
{{- if $dv }}
datahub.acryl.io/datahub-version: {{ $dv | quote }}
{{- end }}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "datahub-gms.labels" -}}
helm.sh/chart: {{ include "datahub-gms.chart" . }}
{{ include "datahub-gms.selectorLabels" . }}
{{- include "datahub-gms.applicationVersionLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "datahub-gms.selectorLabels" -}}
app.kubernetes.io/name: {{ include "datahub-gms.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "datahub-gms.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "datahub-gms.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "datahub-gms.ingress.apiVersion" -}}
{{- if semverCompare ">=1.19-0" .Capabilities.KubeVersion.Version -}}
{{- print "networking.k8s.io/v1" -}}
{{- else if semverCompare "<1.14-0" .Capabilities.KubeVersion.Version }}
{{- print "extensions/v1beta1" -}}
{{- else -}}
{{- print "networking.k8s.io/v1beta1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for HorizontalPodAutoscaler.
*/}}
{{- define "datahub-gms.hpa.apiVersion" -}}
  {{- if and (.Capabilities.APIVersions.Has "autoscaling/v2") (semverCompare ">=1.23-0" .Capabilities.KubeVersion.Version) -}}
    {{- print "autoscaling/v2" -}}
  {{- else -}}
    {{- print "autoscaling/v2beta1" -}}
  {{- end -}}
{{- end -}}

{{/*
Create the jvm debug flag
*/}}
{{- define "acryl.debug" -}}
{{- if .Values.debug.enabled -}}
  {{- if .Values.debug.suspend -}}
    {{ "-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005" }}
  {{- else -}}
    {{ "-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005" }}
  {{- end -}}
{{- else -}}
  {{- "" -}}
{{- end -}}
{{- end -}}

{{/*
Create the jvm shadow debug flag
*/}}
{{- define "datahub-gms-alt.debug" -}}
{{- $ := index . 0 -}}
{{- $altKey := index . 1 -}}
{{- $altValue := index . 2 -}}
{{- if ($altValue.debug).enabled -}}
    {{- if ($altValue.debug).suspend -}}
    "{{- printf "%s=%s" "-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address" (default 5005 ($altValue.debug).port | toString) -}}"
    {{- else -}}
    "{{- printf "%s=%s" "-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address" (default 5005 ($altValue.debug).port | toString) -}}"
    {{- end -}}
{{- else -}}
    {{ "" }}
{{- end -}}
{{- end -}}

{{/*
Expand the name for alternatives
*/}}
{{- define "datahub-gms-alt.name" -}}
{{- $ := index . 0 -}}
{{- $altKey := index . 1 -}}
{{- $altValue := index . 2 -}}
{{- default (printf "%s-%s" $.Chart.Name $altKey) $altValue.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name for alternative components
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "datahub-gms-alt.fullname" -}}
{{- $ := index . 0 -}}
{{- $altKey := index . 1 -}}
{{- $altValue := index . 2 -}}
{{- if hasKey $altValue "fullnameOverride" -}}
  {{- $altValue.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
  {{- $name := default (printf "%s-%s" $.Chart.Name $altKey) $altValue.nameOverride -}}
  {{- if and (contains $name $.Release.Name) (contains $name $altKey) -}}
    {{- $name | trunc 63 | trimSuffix "-" -}}
  {{- else -}}
    {{- printf "%s-%s" $.Release.Name $name | trunc 63 | trimSuffix "-" -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Common alternative labels
*/}}
{{- define "datahub-gms-alt.labels" -}}
{{- $ := index . 0 -}}
{{- $altKey := index . 1 -}}
{{- $altValue := index . 2 -}}
helm.sh/chart: {{ include "datahub-gms.chart" $ }}
{{ include "datahub-gms-alt.selectorLabels" . }}
{{- if $.Chart.AppVersion }}
app.kubernetes.io/version: {{ $.Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ $.Release.Service }}
{{- end -}}

{{/*
Selector alternative labels
*/}}
{{- define "datahub-gms-alt.selectorLabels" -}}
{{- $ := index . 0 -}}
{{- $altKey := index . 1 -}}
{{- $altValue := index . 2 -}}
app.kubernetes.io/name: {{ include "datahub-gms-alt.name" . }}
app.kubernetes.io/instance: {{ $.Release.Name }}
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
Sets OPENSEARCH_USE_AWS_IAM_AUTH=true and AWS_REGION when IAM authentication is enabled.
This helper should be included in all services that access OpenSearch/Elasticsearch.
Validates that Kafka and OpenSearch regions match when both are configured with IAM.
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
GMS base path prefix for HTTP paths (matches liveness path construction).
*/}}
{{- define "datahub-gms.basePath" -}}
{{- if .Values.global.basePath.enabled }}{{ if eq .Values.global.basePath.gms "/" }}{{ else }}{{ .Values.global.basePath.gms }}{{ end }}{{ end -}}
{{- end -}}

{{/*
global.datahub.monitoring metricsMode: legacy | jmx_and_actuator | actuator_only (default legacy).
*/}}
{{- define "datahub-gms.monitoring.metricsMode" -}}
{{- .Values.global.datahub.monitoring.metricsMode | default "legacy" | trim -}}
{{- end -}}

{{- define "datahub-gms.monitoring.jmxPort" -}}
{{- int (.Values.global.datahub.monitoring.jmxPort | default 4318) -}}
{{- end -}}

{{- define "datahub-gms.monitoring.actuatorPrometheusPort" -}}
{{- int (.Values.global.datahub.monitoring.actuatorPrometheusPort | default 4319) -}}
{{- end -}}

{{- define "datahub-gms.monitoring.jmxMetricsPath" -}}
{{- (.Values.global.datahub.monitoring.jmxExporter | default dict).metricsPath | default "/metrics" -}}
{{- end -}}

{{- define "datahub-gms.monitoring.gmsScrapeActuatorOnHttp" -}}
{{- if eq (include "datahub-gms.monitoring.metricsMode" .) "legacy" }}true{{- end -}}
{{- end -}}
