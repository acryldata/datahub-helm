{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "datahub-frontend.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "datahub-frontend.fullname" -}}
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
{{- define "datahub-frontend.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "datahub-frontend.labels" -}}
helm.sh/chart: {{ include "datahub-frontend.chart" . }}
{{ include "datahub-frontend.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "datahub-frontend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "datahub-frontend.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "datahub-frontend.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "datahub-frontend.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "datahub-frontend.ingress.apiVersion" -}}
{{- if semverCompare ">=1.19-0" (default "1.19-0" ((.Capabilities).KubeVersion).Version) -}}
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
{{- define "datahub-frontend.hpa.apiVersion" -}}
  {{- if and (.Capabilities.APIVersions.Has "autoscaling/v2") (semverCompare ">=1.23-0" .Capabilities.KubeVersion.Version) -}}
    {{- print "autoscaling/v2" -}}
  {{- else -}}
    {{- print "autoscaling/v2beta1" -}}
  {{- end -}}
{{- end -}}

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
Create the jvm shadow debug flag
*/}}
{{- define "datahub-frontend-alt.debug" -}}
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
{{- define "datahub-frontend-alt.name" -}}
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
{{- define "datahub-frontend-alt.fullname" -}}
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
Create a default fully qualified app name for alternative *GMS* components
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "datahub-frontend-alt.gms_fullname" -}}
{{- $ := index . 0 -}}
{{- $altKey := index . 1 -}}
{{- $altValue := index . 2 -}}
{{- if hasKey $altValue "gmsFullnameOverride" -}}
  {{- $altValue.gmsFullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
  {{- $name := default (printf "datahub-gms-%s" $altKey) $altValue.gmsNameOverride -}}
  {{- if contains $name $.Release.Name -}}
    {{- printf $name | trunc 63 | trimSuffix "-" -}}
  {{- else -}}
    {{- printf "%s-%s" $.Release.Name $name | trunc 63 | trimSuffix "-" -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Common alternative labels
*/}}
{{- define "datahub-frontend-alt.labels" -}}
{{- $ := index . 0 -}}
{{- $altKey := index . 1 -}}
{{- $altValue := index . 2 -}}
helm.sh/chart: {{ include "datahub-frontend.chart" $ }}
{{ include "datahub-frontend-alt.selectorLabels" . }}
{{- if $.Chart.AppVersion }}
app.kubernetes.io/version: {{ $.Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ $.Release.Service }}
{{- end -}}

{{/*
Selector alternative labels
*/}}
{{- define "datahub-frontend-alt.selectorLabels" -}}
{{- $ := index . 0 -}}
{{- $altKey := index . 1 -}}
{{- $altValue := index . 2 -}}
app.kubernetes.io/name: {{ include "datahub-frontend-alt.name" . }}
app.kubernetes.io/instance: {{ $.Release.Name }}
{{- end -}}
