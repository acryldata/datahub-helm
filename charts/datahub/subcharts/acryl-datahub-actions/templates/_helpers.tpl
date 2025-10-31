{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "acryl-datahub-actions.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "acryl-datahub-actions.fullname" -}}
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
{{- define "acryl-datahub-actions.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "acryl-datahub-actions.labels" -}}
helm.sh/chart: {{ include "acryl-datahub-actions.chart" . }}
{{ include "acryl-datahub-actions.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "acryl-datahub-actions.selectorLabels" -}}
app.kubernetes.io/name: {{ include "acryl-datahub-actions.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "acryl-datahub-actions.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "acryl-datahub-actions.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Datahub GMS protocol
*/}}
{{- define "acryl-datahub-actions.datahubGmsProtocol" -}}
{{ ((.Values.datahub).gms).protocol | default .Values.global.datahub.gms.protocol }}
{{- end -}}

{{/*
Datahub GMS host
*/}}
{{- define "acryl-datahub-actions.datahubGmsHost" -}}
{{ (((.Values.datahub).gms).host | default ((.Values.global.datahub).gms).host) | default (printf "%s-%s" .Release.Name "datahub-gms") | trunc 63 | trimSuffix "-"}}
{{- end -}}

{{/*
Datahub GMS port
*/}}
{{- define "acryl-datahub-actions.datahubGmsPort" -}}
{{ ((.Values.datahub).gms).port | default .Values.global.datahub.gms.port }}
{{- end -}}

{{/*
Create image registry, name and tag for a datahub component
*/}}
{{- define "datahub.image" -}}
{{- $registry := .image.registry | default .imageRegistry -}}
{{ $registry }}/{{ .image.repository }}:{{ required "Global or specific tag is required" (.image.tag | default .version) -}}
{{- end -}}

{{/*
Kafka IAM environment variables for AWS MSK authentication if enabled.
For Python-based services that use confluent_kafka/librdkafka.
Python services use OAUTHBEARER with a custom OAuth callback instead of AWS_MSK_IAM.
*/}}
{{- define "datahub.kafka.iam.python.env" -}}
{{- if .Values.global.kafka.iam.enabled -}}
{{- if .Values.global.kafka.iam.awsRegion }}
- name: AWS_REGION
  value: {{ .Values.global.kafka.iam.awsRegion | quote }}
{{- end }}
- name: KAFKA_PROPERTIES_SECURITY_PROTOCOL
  value: SASL_SSL
- name: KAFKA_PROPERTIES_SASL_MECHANISM
  value: OAUTHBEARER
- name: KAFKA_PROPERTIES_SASL_OAUTHBEARER_METHOD
  value: default
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
