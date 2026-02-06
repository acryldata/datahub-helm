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
Create image registry, name and tag for a datahub component
*/}}
{{- define "datahub.image" -}}
{{- $registry := .image.registry | default .imageRegistry -}}
{{ $registry }}/{{ .image.repository }}:{{ required "Global or specific tag is required" (.image.tag | default .version) -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for the implementation of the monitoring CRDs.
*/}}
{{- define "datahub.monitoring.monitoringApiVersion" -}}
{{- .Values.global.datahub.monitoring.monitoringApiVersion | default "monitoring.coreos.com/v1"}}
{{- end -}}

{{/*
Generate Python environment variables from global.python configuration
*/}}
{{- define "datahub.python.env" -}}
{{- if .Values.global.python }}
{{- $auth := .Values.global.python.auth -}}
{{- $hasAuth := and $auth (or $auth.username.value $auth.username.secretRef) (or $auth.password.value $auth.password.secretRef) -}}
{{- $indexUrl := .Values.global.python.index | default .Values.global.python.mirror -}}
{{- if $indexUrl -}}
- name: PIP_INDEX_URL
  value: {{ include "datahub.python.authenticatedUrl" (dict "url" $indexUrl "auth" $auth) | quote }}
- name: UV_INDEX_URL
  value: {{ include "datahub.python.authenticatedUrl" (dict "url" $indexUrl "auth" $auth) | quote }}
{{- end }}
{{- if .Values.global.python.trustedHost }}
- name: PIP_TRUSTED_HOST
  value: {{ .Values.global.python.trustedHost | quote }}
{{- end }}
{{- if .Values.global.python.extraIndex }}
- name: PIP_EXTRA_INDEX_URL
  value: {{ include "datahub.python.processExtraIndexUrls" (dict "extraIndex" .Values.global.python.extraIndex "auth" $auth) | quote }}
- name: UV_EXTRA_INDEX_URL
  value: {{ include "datahub.python.processExtraIndexUrls" (dict "extraIndex" .Values.global.python.extraIndex "auth" $auth) | quote }}
{{- /* Generate secret refs for per-URL auth in extraIndex */ -}}
{{- if kindIs "slice" .Values.global.python.extraIndex }}
{{- range $index, $item := .Values.global.python.extraIndex }}
{{- if kindIs "map" $item }}
{{- if and $item.username $item.username.secretRef }}
- name: {{ printf "DATAHUB_PYTHON_EXTRA_%d_USERNAME" $index }}
  valueFrom:
    secretKeyRef:
      name: {{ $item.username.secretRef | quote }}
      key: {{ $item.username.secretKey | quote }}
{{- end }}
{{- if and $item.password $item.password.secretRef }}
- name: {{ printf "DATAHUB_PYTHON_EXTRA_%d_PASSWORD" $index }}
  valueFrom:
    secretKeyRef:
      name: {{ $item.password.secretRef | quote }}
      key: {{ $item.password.secretKey | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- if $hasAuth }}
{{- if $auth.username.secretRef }}
- name: DATAHUB_PYTHON_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ $auth.username.secretRef | quote }}
      key: {{ $auth.username.secretKey | quote }}
{{- end }}
{{- if $auth.password.secretRef }}
- name: DATAHUB_PYTHON_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ $auth.password.secretRef | quote }}
      key: {{ $auth.password.secretKey | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Helper to construct authenticated URLs for Python package repositories
*/}}
{{- define "datahub.python.authenticatedUrl" -}}
{{- $url := .url -}}
{{- $auth := .auth -}}
{{- $index := .index -}}
{{- if and $auth (or $auth.username.value $auth.username.secretRef) (or $auth.password.value $auth.password.secretRef) -}}
{{- $username := "" -}}
{{- $password := "" -}}
{{- if $auth.username.value -}}
{{- $username = $auth.username.value -}}
{{- else if $auth.username.secretRef -}}
{{- if ne $index nil -}}
{{- $username = printf "${DATAHUB_PYTHON_EXTRA_%d_USERNAME}" $index -}}
{{- else -}}
{{- $username = "${DATAHUB_PYTHON_USERNAME}" -}}
{{- end -}}
{{- end -}}
{{- if $auth.password.value -}}
{{- $password = $auth.password.value -}}
{{- else if $auth.password.secretRef -}}
{{- if ne $index nil -}}
{{- $password = printf "${DATAHUB_PYTHON_EXTRA_%d_PASSWORD}" $index -}}
{{- else -}}
{{- $password = "${DATAHUB_PYTHON_PASSWORD}" -}}
{{- end -}}
{{- end -}}
{{- if hasPrefix "http://" $url -}}
{{- printf "http://%s:%s@%s" $username $password (trimPrefix "http://" $url) -}}
{{- else if hasPrefix "https://" $url -}}
{{- printf "https://%s:%s@%s" $username $password (trimPrefix "https://" $url) -}}
{{- else -}}
{{- $url -}}
{{- end -}}
{{- else -}}
{{- $url -}}
{{- end -}}
{{- end -}}

{{/*
Helper to process extraIndex URLs - handles multiple formats:
1. Single string: "https://url.com"
2. List of strings: ["https://url1.com", "https://url2.com"]
3. List of objects with per-URL auth: [{"url": "https://url.com", "username": {...}, "password": {...}}]
*/}}
{{- define "datahub.python.processExtraIndexUrls" -}}
{{- $extraIndex := .extraIndex -}}
{{- $globalAuth := .auth -}}
{{- if kindIs "slice" $extraIndex -}}
{{- $urls := list -}}
{{- range $index, $item := $extraIndex -}}
{{- if kindIs "map" $item -}}
{{- /* Object format with per-URL auth */ -}}
{{- $url := $item.url -}}
{{- $perUrlAuth := dict -}}
{{- if $item.username -}}
{{- $perUrlAuth = merge $perUrlAuth (dict "username" $item.username) -}}
{{- end -}}
{{- if $item.password -}}
{{- $perUrlAuth = merge $perUrlAuth (dict "password" $item.password) -}}
{{- end -}}
{{- $urls = append $urls (include "datahub.python.authenticatedUrl" (dict "url" $url "auth" $perUrlAuth "index" $index)) -}}
{{- else -}}
{{- /* String format - no per-URL auth */ -}}
{{- $urls = append $urls $item -}}
{{- end -}}
{{- end -}}
{{- join " " $urls -}}
{{- else -}}
{{- /* Single string format - no auth for extraIndex */ -}}
{{- $extraIndex -}}
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
Kafka IAM environment variables for AWS MSK authentication if enabled.
For non-Spring Java services that use Kafka directly (e.g., Gobblin).
Sets KAFKA_PROPERTIES_* format instead of SPRING_KAFKA_PROPERTIES_*.

USAGE: Include in Java services that use Kafka but don't use Spring:
- gobblin jobs

NOTE: Gobblin uses Kafka 0.9 client which may have limited IAM support.
For newer Kafka clients, these properties should work with AWS MSK IAM.
*/}}
{{- define "datahub.kafka.iam.java.env" -}}
{{- if .Values.global.kafka.iam.enabled -}}
- name: KAFKA_PROPERTIES_SASL_CLIENT_CALLBACK_HANDLER_CLASS
  value: software.amazon.msk.auth.iam.IAMClientCallbackHandler
- name: KAFKA_PROPERTIES_SASL_JAAS_CONFIG
  value: software.amazon.msk.auth.iam.IAMLoginModule required;
- name: KAFKA_PROPERTIES_SASL_MECHANISM
  value: AWS_MSK_IAM
- name: KAFKA_PROPERTIES_SSL_PROTOCOL
  value: TLS
- name: KAFKA_PROPERTIES_SECURITY_PROTOCOL
  value: SASL_SSL
{{- if .Values.global.kafka.iam.awsRegion }}
- name: AWS_REGION
  value: {{ .Values.global.kafka.iam.awsRegion | quote }}
{{- end }}
{{- end -}}
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
Sets OPENSEARCH_USE_AWS_IAM_AUTH=true and AWS_REGION when IAM authentication is enabled.

USAGE: Only include in services that DIRECTLY connect to OpenSearch/Elasticsearch:
- datahub-gms (primary writer)
- datahub-mae-consumer (writes search indices)
- datahub-mce-consumer (writes search indices, runIds)
- datahub-system-update-job (index setup/migration)

DO NOT include in services that only connect to GMS (Frontend, Actions, Integrations, PE consumers).
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
SQL IAM authentication environment variables for AWS RDS IAM authentication.
Supports both MySQL and PostgreSQL with automatic cloud provider detection.
Sets EBEAN_USE_IAM_AUTH=true and EBEAN_CLOUD_PROVIDER when IAM authentication is enabled.

USAGE: Only include in services that DIRECTLY connect to SQL databases:
- datahub-gms (primary SQL client)
- datahub-mce-consumer (writes to SQL via Ebean)
- datahub-system-update-job (database setup/migration)

DO NOT include in services that only connect to GMS or Kafka (Frontend, Actions, MAE/PE consumers).
*/}}
{{- define "datahub.sql.iam.env" -}}
{{- if .Values.global.sql.iam.enabled }}
- name: EBEAN_POSTGRES_USE_AWS_IAM_AUTH
  value: "true"
- name: EBEAN_USE_IAM_AUTH
  value: "true"
{{- if .Values.global.sql.iam.cloudProvider }}
- name: EBEAN_CLOUD_PROVIDER
  value: {{ .Values.global.sql.iam.cloudProvider | quote }}
{{- else }}
- name: EBEAN_CLOUD_PROVIDER
  value: "auto"
{{- end }}
{{- end }}
{{- end -}}

{{/*
Neo4j graph database connection environment variables.
Only sets variables if Neo4j is configured as the graph service implementation.

USAGE: Include ONLY in services that DIRECTLY connect to Neo4j graph database:
- datahub-gms (primary graph service client)
- datahub-mae-consumer (writes graph indices)
- datahub-system-update-job (graph migration/setup tasks)

NOTE: datahub-system-update runs as a separate Kubernetes Job and needs explicit configuration.
*/}}
{{- define "datahub.neo4j.connection.env" -}}
{{- if eq .Values.global.graph_service_impl "neo4j" }}
- name: NEO4J_HOST
  value: "{{ .Values.global.neo4j.host }}"
- name: NEO4J_URI
  value: "{{ .Values.global.neo4j.uri }}"
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
{{- end -}}

{{/*
SQL database connection environment variables (non-IAM).
Complements datahub.sql.iam.env with connection details and credentials.

USAGE: Include in services that directly connect to SQL:
- datahub-gms
- datahub-mce-consumer
- datahub-system-update-job

This helper handles username/password configuration. For IAM authentication,
also include datahub.sql.iam.env helper after this one.
*/}}
{{- define "datahub.sql.connection.env" -}}
- name: EBEAN_DATASOURCE_HOST
  value: "{{ .Values.global.sql.datasource.host }}"
- name: EBEAN_DATASOURCE_URL
  value: "{{ .Values.global.sql.datasource.url }}"
- name: EBEAN_DATASOURCE_DRIVER
  value: "{{ .Values.global.sql.datasource.driver }}"
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
{{- if not .Values.global.sql.iam.enabled }}
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
{{- end }}
{{- end -}}

{{/*
ElasticSearch/OpenSearch connection environment variables.
Includes host, port, SSL, credentials, and index prefix.

USAGE: Include in services that directly connect to ElasticSearch/OpenSearch:
- datahub-gms
- datahub-mae-consumer
- datahub-mce-consumer
- datahub-system-update-job

For IAM authentication, also include datahub.elasticsearch.iam.env helper after this one.

NOTE: ELASTICSEARCH_THREAD (without _COUNT) is NOT used by the application.
      MAE Consumer sets ELASTICSEARCH_THREAD_COUNT separately in its deployment.
*/}}
{{- define "datahub.elasticsearch.connection.env" -}}
- name: ELASTICSEARCH_HOST
  value: "{{ .Values.global.elasticsearch.host }}"
- name: ELASTICSEARCH_PORT
  value: "{{ .Values.global.elasticsearch.port }}"
{{- with .Values.global.elasticsearch.implementation }}
- name: ELASTICSEARCH_IMPLEMENTATION
  value: {{ . | quote }}
{{- end }}
- name: SKIP_ELASTICSEARCH_CHECK
  value: "{{ .Values.global.elasticsearch.skipcheck }}"
{{- with .Values.global.elasticsearch.useSSL }}
- name: ELASTICSEARCH_USE_SSL
  value: {{ . | quote }}
{{- end }}
{{- with .Values.global.elasticsearch.auth }}
- name: ELASTICSEARCH_USERNAME
  value: {{ .username }}
{{- if not $.Values.global.elasticsearch.iam.enabled }}
- name: ELASTICSEARCH_PASSWORD
  {{- if .password.value }}
  value: {{ .password.value | quote }}
  {{- else }}
  valueFrom:
    secretKeyRef:
      name: "{{ .password.secretRef }}"
      key: "{{ .password.secretKey }}"
  {{- end }}
{{- else }}
# When IAM auth is enabled, set a dummy auth header to trigger IAM auth logic
- name: ELASTICSEARCH_AUTH_HEADER
  value: junk-header-to-enable-iam-auth
{{- end }}
{{- end }}
{{- with .Values.global.elasticsearch.indexPrefix }}
- name: INDEX_PREFIX
  value: {{ . }}
{{- end }}
- name: ELASTICSEARCH_INSECURE
  value: "{{ .Values.global.elasticsearch.insecure }}"
{{- end -}}

{{/*
Render template values with proper context. This is a compatibility helper
for the common.tplvalues.render pattern used in some templates.
If value is a string, it will be templated using the context.
Otherwise, it will be rendered as YAML.
*/}}
{{- define "common.tplvalues.render" -}}
{{- if typeIs "string" .value }}
{{- tpl .value .context }}
{{- else }}
{{- .value | toYaml }}
{{- end }}
{{- end -}}

{{/*
Spring Kafka configuration overrides for Java services.
Skips security.protocol and SSL keystore configs when IAM is enabled.

USAGE: Include in Spring Boot services that use Spring Kafka:
- datahub-gms (both deployment.yaml and deployment-alternatives.yaml)
- datahub-mae-consumer
- datahub-mce-consumer

NOTE: When IAM is enabled, this helper automatically skips:
- security.protocol (replaced by SASL_SSL from kafka.iam.env helper)
- ssl.keystore.* configs (keystore not needed with IAM)
- ssl.key.password (password not needed with IAM)
But keeps ssl.truststore.* configs (still needed for TLS verification)
*/}}
{{- define "datahub.spring.kafka.overrides" -}}
{{- $root := . -}}
{{- if .Values.global.springKafkaConfigurationOverrides }}
{{- range $configName, $configValue := .Values.global.springKafkaConfigurationOverrides }}
{{- /* Skip security.protocol and SSL keystore when IAM is enabled (truststore still needed for TLS) */}}
{{- $skipConfig := and $root.Values.global.kafka.iam.enabled (or (eq $configName "security.protocol") (hasPrefix "ssl.keystore" $configName) (eq $configName "ssl.key.password")) }}
{{- if not $skipConfig }}
- name: SPRING_KAFKA_PROPERTIES_{{ $configName | replace "." "_" | upper }}
  value: {{ $configValue | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Kafka credentials and certs from Kubernetes secrets for Spring services.
Skips SSL keystore configs when IAM is enabled (truststore still needed for TLS).

USAGE: Include in Spring Boot services that use Spring Kafka:
- datahub-gms (both deployment.yaml and deployment-alternatives.yaml)
- datahub-mae-consumer
- datahub-mce-consumer

NOTE: When IAM is enabled, this helper automatically skips:
- security.protocol (replaced by SASL_SSL from kafka.iam.env helper)
- ssl.keystore.* configs (keystore not needed with IAM)
- ssl.key.password and ssl.keystore.password
But keeps ssl.truststore.* configs (still needed for TLS verification)
*/}}
{{- define "datahub.spring.kafka.credentials.env" -}}
{{- $root := . -}}
{{- if .Values.global.credentialsAndCertsSecrets }}
{{- range $envVarName, $envVarValue := .Values.global.credentialsAndCertsSecrets.secureEnv }}
{{- /* Skip security.protocol and SSL keystore when IAM is enabled (truststore still needed for TLS) */}}
{{- $skipSSL := and $root.Values.global.kafka.iam.enabled (or (hasPrefix "ssl.keystore" $envVarName) ($envVarName | eq "ssl.key.password") ($envVarName | eq "ssl.keystore.password") ($envVarName | eq "ssl.keystore.location")) }}
{{- if and (ne $envVarName "security.protocol") (not $skipSSL) }}
- name: SPRING_KAFKA_PROPERTIES_{{ $envVarName | replace "." "_" | upper }}
  valueFrom:
    secretKeyRef:
      name: {{ $root.Values.global.credentialsAndCertsSecrets.name }}
      key: {{ $envVarValue }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Kafka credentials and certs from Kubernetes secrets for non-Spring services.
Skips SSL keystore configs when IAM is enabled (truststore still needed for TLS).

USAGE: Include in Python services and Java services that don't use Spring Kafka:
- datahub-frontend (both deployment.yaml and deployment-alternatives.yaml)
- acryl-datahub-actions
- kafka-setup-job

NOTE: When IAM is enabled, this helper automatically skips:
- security.protocol (replaced by SASL_SSL from kafka.iam.env helper)
- ssl.keystore.* configs (keystore not needed with IAM)
- ssl.key.password and ssl.keystore.password
But keeps ssl.truststore.* configs (still needed for TLS verification)
*/}}
{{- define "datahub.kafka.credentials.env" -}}
{{- $root := . -}}
{{- if .Values.global.credentialsAndCertsSecrets }}
{{- range $envVarName, $envVarValue := .Values.global.credentialsAndCertsSecrets.secureEnv }}
{{- /* Skip security.protocol and SSL keystore when IAM is enabled (truststore still needed for TLS) */}}
{{- $skipSSL := and $root.Values.global.kafka.iam.enabled (or (hasPrefix "ssl.keystore" $envVarName) ($envVarName | eq "ssl.key.password") ($envVarName | eq "ssl.keystore.password")) }}
{{- if and (ne $envVarName "security.protocol") (not $skipSSL) }}
- name: KAFKA_PROPERTIES_{{ $envVarName | replace "." "_" | upper }}
  valueFrom:
    secretKeyRef:
      name: {{ $root.Values.global.credentialsAndCertsSecrets.name }}
      key: {{ $envVarValue }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Kafka configuration overrides for Java services without Spring.
Skips security.protocol and SSL keystore configs when IAM is enabled.

USAGE: Include in Java services that use Kafka:
- datahub frontend

NOTE: When IAM is enabled, this helper automatically skips:
- security.protocol (replaced by SASL_SSL from kafka.iam.env helper)
- ssl.keystore.* configs (keystore not needed with IAM)
- ssl.key.password (password not needed with IAM)
But keeps ssl.truststore.* configs (still needed for TLS verification)
*/}}
{{- define "datahub.kafka.overrides" -}}
{{- $root := . -}}
{{- if .Values.global.springKafkaConfigurationOverrides }}
{{- range $configName, $configValue := .Values.global.springKafkaConfigurationOverrides }}
{{- /* Skip security.protocol and SSL keystore when IAM is enabled (truststore still needed for TLS) */}}
{{- $skipConfig := and $root.Values.global.kafka.iam.enabled (or (eq $configName "security.protocol") (hasPrefix "ssl.keystore" $configName) (eq $configName "ssl.key.password")) }}
{{- if not $skipConfig }}
- name: KAFKA_PROPERTIES_{{ $configName | replace "." "_" | upper }}
  value: {{ $configValue | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Check if a Kafka property is Java-specific and should be excluded from Python services.
Returns "true" if the property should be skipped for Python services.

Java-specific properties:
- ssl.keystore.* (Java KeyStore format)
- ssl.truststore.* (Java TrustStore format)
- sasl.jaas.config (Java JAAS format)
- sasl.client.callback.handler.class (Java class)
- sasl.login.class (Java class)
- kafkastore.* (Schema Registry Java properties)
*/}}
{{- define "datahub.kafka.is-java-only" -}}
{{- $propName := .propName -}}
{{- $isJavaOnly := or (hasPrefix "ssl.keystore" $propName) (hasPrefix "ssl.truststore" $propName) (eq $propName "sasl.jaas.config") (eq $propName "sasl.client.callback.handler.class") (eq $propName "sasl.login.class") (hasPrefix "kafkastore" $propName) -}}
{{- $isJavaOnly -}}
{{- end -}}

{{/*
Python Kafka Configuration with Fallback.
Priority: pythonKafkaConfigurationOverrides → springKafkaConfigurationOverrides (filtered)

USAGE: Include in Python services (executor, integrations, actions)
*/}}
{{- define "datahub.python.kafka.overrides.with.fallback" -}}
{{- $root := . -}}
{{- if .Values.global.pythonKafkaConfigurationOverrides }}
{{- range $configName, $configValue := .Values.global.pythonKafkaConfigurationOverrides }}
{{- if or (ne $configName "security.protocol") (not $root.Values.global.kafka.iam.enabled) }}
- name: KAFKA_PROPERTIES_{{ $configName | replace "." "_" | upper }}
  value: {{ $configValue | quote }}
{{- end }}
{{- end }}
{{- else if .Values.global.springKafkaConfigurationOverrides }}
{{- range $configName, $configValue := .Values.global.springKafkaConfigurationOverrides }}
{{- $isJavaOnly := include "datahub.kafka.is-java-only" (dict "propName" $configName) -}}
{{- if and (ne $isJavaOnly "true") (or (ne $configName "security.protocol") (not $root.Values.global.kafka.iam.enabled)) }}
- name: KAFKA_PROPERTIES_{{ $configName | replace "." "_" | upper }}
  value: {{ $configValue | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Python Kafka Secrets with Fallback.
Priority: pythonKafkaSecretsOverrides → credentialsAndCertsSecrets.secureEnv (filtered)

USAGE: Include in Python services (executor, integrations, actions)
*/}}
{{- define "datahub.python.kafka.secrets.with.fallback" -}}
{{- $root := . -}}
{{- if .Values.global.pythonKafkaSecretsOverrides }}
{{- range $envVarName, $secretConfig := .Values.global.pythonKafkaSecretsOverrides }}
{{- if or (ne $envVarName "security.protocol") (not $root.Values.global.kafka.iam.enabled) }}
- name: KAFKA_PROPERTIES_{{ $envVarName | replace "." "_" | upper }}
  valueFrom:
    secretKeyRef:
      name: {{ $secretConfig.secretRef }}
      key: {{ $secretConfig.secretKey }}
{{- end }}
{{- end }}
{{- else if .Values.global.credentialsAndCertsSecrets }}
{{- range $envVarName, $envVarValue := .Values.global.credentialsAndCertsSecrets.secureEnv }}
{{- $isJavaOnly := include "datahub.kafka.is-java-only" (dict "propName" $envVarName) -}}
{{- if and (ne $isJavaOnly "true") (or (ne $envVarName "security.protocol") (not $root.Values.global.kafka.iam.enabled)) }}
- name: KAFKA_PROPERTIES_{{ $envVarName | replace "." "_" | upper }}
  valueFrom:
    secretKeyRef:
      name: {{ $root.Values.global.credentialsAndCertsSecrets.name }}
      key: {{ $envVarValue }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "datahub.env.common" -}}
- name: GRAPH_SERVICE_IMPL
  value: {{ .Values.global.graph_service_impl | quote }}
{{- end -}}

{{/*
Semantic search environment variables for vector similarity search.
Only emits env vars when semantic search is enabled.

USAGE: Include in services that need semantic search configuration:
- datahub-gms
- datahub-mae-consumer
- datahub-mce-consumer
- datahub-system-update-job (both blocking and non-blocking)
For credentials only (actions pod), see datahub.semantic-search.credentials.env
*/}}
{{- define "datahub.semantic-search.env" -}}
{{- $semantic := .Values.global.semantic_search -}}
{{- if $semantic.enabled }}
{{- /* Two separate env vars control different layers of semantic search:
       ELASTICSEARCH_SEMANTIC_SEARCH_ENABLED  = index-time: creates semantic indices and dual-writes documents into them
       SEARCH_SERVICE_SEMANTIC_SEARCH_ENABLED = query-time: allows semantic search queries to execute
       Both must be true for a fully working setup, so we set them from a single toggle. */ -}}
- name: SEARCH_SERVICE_SEMANTIC_SEARCH_ENABLED
  value: {{ $semantic.enabled | quote }}
- name: ELASTICSEARCH_SEMANTIC_SEARCH_ENABLED
  value: {{ $semantic.enabled | quote }}
- name: ELASTICSEARCH_SEMANTIC_SEARCH_ENTITIES
  value: {{ $semantic.enabledEntities | quote }}
- name: ELASTICSEARCH_SEMANTIC_VECTOR_DIMENSION
  value: {{ $semantic.vectorDimension | quote }}
{{- $providerType := $semantic.provider.type | default "openai" }}
- name: EMBEDDING_PROVIDER_TYPE
  value: {{ $providerType | quote }}
{{- if eq $providerType "aws-bedrock" }}
{{- with $semantic.provider.bedrock }}
- name: EMBEDDING_PROVIDER_MODEL_ID
  value: {{ .modelId | default "cohere.embed-english-v3" | quote }}
- name: EMBEDDING_PROVIDER_AWS_REGION
  value: {{ .awsRegion | default "us-west-2" | quote }}
{{- end }}
{{- end }}
{{- if eq $providerType "openai" }}
{{- with $semantic.provider.openai }}
{{- if .apiKey }}
{{- if .apiKey.secretRef }}
- name: OPENAI_API_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .apiKey.secretRef }}
      key: {{ .apiKey.secretKey }}
{{- else if .apiKey.value }}
- name: OPENAI_API_KEY
  value: {{ .apiKey.value | quote }}
{{- end }}
{{- end }}
- name: OPENAI_EMBEDDING_MODEL
  value: {{ .model | default "text-embedding-3-large" | quote }}
- name: OPENAI_EMBEDDING_ENDPOINT
  value: {{ .endpoint | default "https://api.openai.com/v1/embeddings" | quote }}
{{- end }}
{{- end }}
{{- if eq $providerType "cohere" }}
{{- with $semantic.provider.cohere }}
{{- if .apiKey }}
{{- if .apiKey.secretRef }}
- name: COHERE_API_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .apiKey.secretRef }}
      key: {{ .apiKey.secretKey }}
{{- else if .apiKey.value }}
- name: COHERE_API_KEY
  value: {{ .apiKey.value | quote }}
{{- end }}
{{- end }}
- name: COHERE_EMBEDDING_MODEL
  value: {{ .model | default "embed-english-v3.0" | quote }}
- name: COHERE_EMBEDDING_ENDPOINT
  value: {{ .endpoint | default "https://api.cohere.ai/v1/embed" | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Embedding provider credentials for the datahub-actions pod.
The datahub-documents ingestion source fetches model/provider config from
the server via GraphQL, but still needs credentials as env vars to
authenticate with the embedding API.

USAGE: Include in services that run embedding ingestion:
- acryl-datahub-actions
*/}}
{{- define "datahub.semantic-search.credentials.env" -}}
{{- $semantic := .Values.global.semantic_search -}}
{{- if $semantic.enabled }}
{{- $providerType := $semantic.provider.type | default "openai" }}
{{- if eq $providerType "openai" }}
{{- with $semantic.provider.openai }}
{{- if .apiKey }}
{{- if .apiKey.secretRef }}
- name: OPENAI_API_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .apiKey.secretRef }}
      key: {{ .apiKey.secretKey }}
{{- else if .apiKey.value }}
- name: OPENAI_API_KEY
  value: {{ .apiKey.value | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- if eq $providerType "cohere" }}
{{- with $semantic.provider.cohere }}
{{- if .apiKey }}
{{- if .apiKey.secretRef }}
- name: COHERE_API_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .apiKey.secretRef }}
      key: {{ .apiKey.secretKey }}
{{- else if .apiKey.value }}
- name: COHERE_API_KEY
  value: {{ .apiKey.value | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- if eq $providerType "aws-bedrock" }}
{{- with $semantic.provider.bedrock }}
- name: AWS_REGION
  value: {{ .awsRegion | default "us-west-2" | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}
