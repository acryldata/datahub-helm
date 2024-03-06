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
