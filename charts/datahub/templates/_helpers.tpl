{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "datahub.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "datahub.fullname" -}}
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
{{- define "datahub.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "datahub.labels" -}}
helm.sh/chart: {{ include "datahub.chart" . }}
{{ include "datahub.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "datahub.selectorLabels" -}}
app.kubernetes.io/name: {{ include "datahub.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "datahub.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "datahub.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for cronjob.
*/}}
{{- define "datahub.cronjob.apiVersion" -}}
{{- if semverCompare ">=1.21-0" .Capabilities.KubeVersion.Version -}}
{{- print "batch/v1" -}}
{{- else -}}
{{- print "batch/v1beta1" -}}
{{- end -}}
{{- end -}}

{{/*
Create general image registry, name and tag
*/}}
{{- define "datahub.image" -}}
{{- $registry := .Values.global.imageRegistry | default .Values.image.registry -}}
{{ $registry }}/{{ .Values.image.repository }}:{{ required "Global or specific tag is required" (.Values.image.tag | default .Values.global.datahub.version) -}}
{{- end -}}

{{/*
Create image registry, name and tag for elasticsearch setup job
*/}}
{{- define "elasticsearchSetupJob.image" -}}
{{- $registry := .Values.global.imageRegistry | default .Values.elasticsearchSetupJob.image.registry -}}
{{ $registry }}/{{ .Values.elasticsearchSetupJob.image.repository }}:{{ required "Global or specific tag is required" (.Values.elasticsearchSetupJob.image.tag | default .Values.global.datahub.version) -}}
{{- end -}}

{{/*
Create image registry, name and tag for kafka setup job
*/}}
{{- define "kafkaSetupJob.image" -}}
{{- $registry := .Values.global.imageRegistry | default .Values.kafkaSetupJob.image.registry -}}
{{ $registry }}/{{ .Values.kafkaSetupJob.image.repository }}:{{ required "Global or specific tag is required" (.Values.kafkaSetupJob.image.tag | default .Values.global.datahub.version) -}}
{{- end -}}

{{/*
Create image registry, name and tag for mysql setup job
*/}}
{{- define "mysqlSetupJob.image" -}}
{{- $registry := .Values.global.imageRegistry | default .Values.mysqlSetupJob.image.registry -}}
{{ $registry }}/{{ .Values.mysqlSetupJob.image.repository }}:{{ required "Global or specific tag is required" (.Values.mysqlSetupJob.image.tag | default .Values.global.datahub.version) -}}
{{- end -}}

{{/*
Create image registry, name and tag for postgres setup job
*/}}
{{- define "postgresqlSetupJob.image" -}}
{{- $registry := .Values.global.imageRegistry | default .Values.postgresqlSetupJob.image.registry -}}
{{ $registry }}/{{ .Values.postgresqlSetupJob.image.repository }}:{{ required "Global or specific tag is required" (.Values.postgresqlSetupJob.image.tag | default .Values.global.datahub.version) -}}
{{- end -}}
