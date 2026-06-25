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
{{- if .Values.serviceAccount.name -}}
{{- .Values.serviceAccount.name -}}
{{- else if and .Values.global.datahub.appServiceAccount .Values.global.datahub.appServiceAccount.name -}}
{{- .Values.global.datahub.appServiceAccount.name -}}
{{- else if .Values.serviceAccount.create -}}
{{- default (include "datahub-gms.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
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
global.datahub.monitoring metricsMode: legacy | jmx_and_actuator | actuator_only (default jmx_and_actuator).
*/}}
{{- define "datahub-gms.monitoring.metricsMode" -}}
{{- .Values.global.datahub.monitoring.metricsMode | default "jmx_and_actuator" | trim -}}
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

{{/*
OpenTelemetry env vars for datahub-gms.
Resolves global.otel.* with optional per-subchart override under .Values.otel.
Override semantics: explicit true/false at subchart level wins; null/missing inherits global.
*/}}
{{- define "datahub-gms.otelEnvs" -}}
{{- $g := .Values.global.otel | default dict -}}
{{- $s := .Values.otel | default dict -}}
{{- $enabled := $g.enabled | default false -}}
{{- if not (kindIs "invalid" $s.enabled) -}}{{- $enabled = $s.enabled -}}{{- end -}}
{{- if $enabled }}
- name: ENABLE_OTEL
  value: "true"
- name: OTEL_EXPORTER_OTLP_ENDPOINT
  value: {{ default $g.endpoint $s.endpoint | quote }}
- name: OTEL_EXPORTER_OTLP_PROTOCOL
  value: {{ default $g.protocol $s.protocol | quote }}
- name: OTEL_SERVICE_NAME
  value: {{ default "datahub-gms" $s.serviceName | quote }}
{{- $tracesEnabled := $g.tracesEnabled | default false -}}
{{- if not (kindIs "invalid" $s.tracesEnabled) -}}{{- $tracesEnabled = $s.tracesEnabled -}}{{- end }}
- name: OTEL_TRACES_EXPORTER
  value: {{ ternary "otlp" "none" $tracesEnabled | quote }}
{{- $metricsEnabled := $g.metricsEnabled | default false -}}
{{- if not (kindIs "invalid" $s.metricsEnabled) -}}{{- $metricsEnabled = $s.metricsEnabled -}}{{- end }}
- name: OTEL_METRICS_EXPORTER
  value: {{ ternary "otlp" "none" $metricsEnabled | quote }}
{{- $logsEnabled := $g.logsEnabled | default false -}}
{{- if not (kindIs "invalid" $s.logsEnabled) -}}{{- $logsEnabled = $s.logsEnabled -}}{{- end }}
- name: OTEL_LOGS_EXPORTER
  value: {{ ternary "otlp" "none" $logsEnabled | quote }}
{{- $graphqlTracesEnabled := $g.graphqlTracesEnabled | default false -}}
{{- if not (kindIs "invalid" $s.graphqlTracesEnabled) -}}{{- $graphqlTracesEnabled = $s.graphqlTracesEnabled -}}{{- end }}
{{- /* GraphQL traces only take effect when trace export is on. Without it, GMS would
       create per-resolver spans that are immediately dropped (exporter=none) — wasted CPU.
       Gate the effective value on both flags. */ -}}
- name: ENABLE_OTEL_GRAPHQL_TRACES
  value: {{ ternary "true" "false" (and $graphqlTracesEnabled $tracesEnabled) | quote }}
- name: OTEL_TRACES_SAMPLER
  value: {{ default $g.tracesSampler $s.tracesSampler | quote }}
- name: OTEL_TRACES_SAMPLER_ARG
  value: {{ default $g.tracesSamplerArg $s.tracesSamplerArg | quote }}
- name: OTEL_METRIC_EXPORT_INTERVAL
  value: {{ default $g.metricExportInterval $s.metricExportInterval | quote }}
{{- /* Agent-side method instrumentation: treat listed methods as @WithSpan without code.
       Format: "fqcn[method1,method2];fqcn2[method3]" — NO method wildcards. Emitted only when set.
       NOTE: STRING field — uses `default` (subchart wins when non-empty), same as endpoint/
       protocol/tracesSampler. Boolean fields MUST instead use the `kindIs "invalid"` pattern
       above, because `default` treats `false` as empty and would wrongly inherit the global. */ -}}
{{- $methodsInclude := default $g.methodsInclude $s.methodsInclude -}}
{{- if $methodsInclude }}
- name: OTEL_INSTRUMENTATION_METHODS_INCLUDE
  value: {{ $methodsInclude | quote }}
{{- end }}
{{- $svcNs := default $g.serviceNamespace $s.serviceNamespace -}}
{{- $depEnv := default $g.deploymentEnvironment $s.deploymentEnvironment -}}
{{- $extras := default $g.extraResourceAttributes $s.extraResourceAttributes -}}
{{- $attrs := list (printf "k8s.namespace.name=%s" .Release.Namespace) -}}
{{- if $svcNs }}{{- $attrs = append $attrs (printf "service.namespace=%s" $svcNs) -}}{{- end -}}
{{- if $depEnv }}{{- $attrs = append $attrs (printf "deployment.environment=%s" $depEnv) -}}{{- end -}}
{{- if $extras }}{{- $attrs = append $attrs $extras -}}{{- end -}}
{{- if $attrs }}
- name: OTEL_RESOURCE_ATTRIBUTES
  value: {{ join "," $attrs | quote }}
{{- end }}
{{- end -}}
{{- end -}}
