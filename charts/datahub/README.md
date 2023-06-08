DataHub
=======
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/datahub)](https://artifacthub.io/packages/search?repo=datahub)

A Helm chart for LinkedIn DataHub

## Install DataHub
Run the following command to install datahub with default configuration.

```
helm repo add datahub https://helm.datahubproject.io
helm install datahub datahub/datahub
```
If the default configuration is not applicable, you can update the values listed below in a `values.yaml` file and run
```
helm install datahub datahub/datahub --values <<path-to-values-file>>
```

## Chart Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| datahub-frontend.enabled | bool | `true` | Enable Datahub Front-end |
| datahub-frontend.image.repository | string | `"linkedin/datahub-frontend-react"` | Image repository for datahub-frontend |
| datahub-frontend.image.tag | string | `"v0.10.0"` | Image tag for datahub-frontend |
| datahub-frontend.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy for datahub-frontend |
| datahub-gms.enabled | bool | `true` | Enable GMS |
| datahub-gms.image.repository | string | `"linkedin/datahub-gms"` | Image repository for datahub-gms |
| datahub-gms.image.tag | string | `"v0.10.0"` | Image tag for datahub-gms |
| datahub-gms.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy for datahub-gms |
| datahub-mae-consumer.image.repository | string | `"linkedin/datahub-mae-consumer"` | Image repository for datahub-mae-consumer |
| datahub-mae-consumer.image.tag | string | `"v0.10.0"` | Image tag for datahub-mae-consumer |
| datahub-mae-consumer.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy for datahub-mae-consumer |
| datahub-mce-consumer.image.repository | string | `"linkedin/datahub-mce-consumer"` | Image repository for datahub-mce-consumer |
| datahub-mce-consumer.image.tag | string | `"v0.10.0"` | Image tag for datahub-mce-consumer |
| datahub-mce-consumer.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy for datahub-mce-consumer |
| datahub-ingestion-cron.enabled | bool | `false` | Enable cronjob for periodic ingestion |
| datahubUpgrade.podSecurityContext | object | `{}` | Pod security context for datahubUpgrade jobs |
| datahubUpgrade.securityContext | object | `{}` | Container security context for datahubUpgrade jobs |
| datahubUpgrade.podAnnotations | object | `{}` | Pod annotations for datahubUpgrade jobs |
| datahubUpgrade.cleanupJob.resources | object | '{}' | Kube Resource definitions for the datahub upgrade job 'cleanupJob' |
| datahubUpgrade.cleanupJob.extraSidecars | list | `[]` | Add additional sidecar containers to the job pod |
| datahubUpgrade.restoreIndices.resources | object | '{}' | Kube Resource definitions for the datahub upgrade job 'restore indices' |
| datahubUpgrade.restoreIndices.extraSidecars | list | `[]` | Add additional sidecar containers to the job pod |
| elasticsearchSetupJob.enabled | bool | `true` | Enable setup job for elasicsearch |
| elasticsearchSetupJob.image.repository | string | `"linkedin/datahub-elasticsearch-setup"` | Image repository for elasticsearchSetupJob |
| elasticsearchSetupJob.image.tag | string | `"v0.10.0"` | Image repository for elasticsearchSetupJob |
| elasticsearchSetupJob.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy for elasticsearchSetupJob |
| elasticsearchSetupJob.resources | object | '{}' | Kube Resource definitions for elasticsearchSetupJob |
| elasticsearchSetupJob.podSecurityContext | object | `{"fsGroup": 1000}` | Pod security context for elasticsearchSetupJob |
| elasticsearchSetupJob.securityContext | object | `{"runAsUser": 1000}` | Container security context for elasticsearchSetupJob |
| elasticsearchSetupJob.podAnnotations | object | `{}` | Pod annotations for elasticsearchSetupJob |
| elasticsearchSetupJob.extraSidecars | list | `[]` | Add additional sidecar containers to the job pod |
| kafkaSetupJob.enabled | bool | `true` | Enable setup job for kafka |
| kafkaSetupJob.image.repository | string | `"linkedin/datahub-kafka-setup"` | Image repository for kafkaSetupJob |
| kafkaSetupJob.image.tag | string | `"v0.10.0"` | Image repository for kafkaSetupJob |
| kafkaSetupJob.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy for kafkaSetupJob|
| kafkaSetupJob.resources | object | '{}' | Kube Resource definitions for kafkaSetupJob |
| kafkaSetupJob.podSecurityContext | object | `{"fsGroup": 1000}` | Pod security context for kafkaSetupJob |
| kafkaSetupJob.securityContext | object | `{"runAsUser": 1000}` | Container security context for kafkaSetupJob |
| kafkaSetupJob.podAnnotations | object | `{}` | Pod annotations for kafkaSetupJob |
| kafkaSetupJob.extraSidecars | list | `[]` | Add additional sidecar containers to the job pod |
| mysqlSetupJob.enabled | bool | `false` | Enable setup job for mysql |
| mysqlSetupJob.image.repository | string | `"acryldata/datahub-mysql-setup"` | Image repository for mysqlSetupJob |
| mysqlSetupJob.image.tag | string | `"v0.10.0"` | Image repository for mysqlSetupJob |
| mysqlSetupJob.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy for mysqlSetupJob|
| mysqlSetupJob.resources | object | '{}' | Kube Resource definitions for mysqlSetupJob |
| mysqlSetupJob.podSecurityContext | object | `{"fsGroup": 1000}` | Pod security context for mysqlSetupJob |
| mysqlSetupJob.securityContext | object | `{"runAsUser": 1000}` | Container security context for mysqlSetupJob |
| mysqlSetupJob.podAnnotations | object | `{}` | Pod annotations for mysqlSetupJob |
| mysqlSetupJob.extraSidecars | list | `[]` | Add additional sidecar containers to the job pod |
| postgresqlSetupJob.enabled | bool | `false` | Enable setup job for postgresql |
| postgresqlSetupJob.image.repository | string | `"acryldata/datahub-postgres-setup"` | Image repository for postgresqlSetupJob |
| postgresqlSetupJob.image.tag | string | `"v0.10.0"` | Image repository for postgresqlSetupJob |
| postgresqlSetupJob.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy for postgresqlSetupJob|
| postgresqlSetupJob.resources | object | '{}' | Kube Resource definitions for postgresqlSetupJob |
| postgresqlSetupJob.podSecurityContext | object | `{"fsGroup": 1000}` | Pod security context for mysqlSetupJob |
| postgresqlSetupJob.securityContext | object | `{"runAsUser": 1000}` | Container security context for mysqlSetupJob |
| postgresqlSetupJob.podAnnotations | object | `{}` | Pod annotations for mysqlSetupJob |
| postgresqlSetupJob.extraSidecars | list | `[]` | Add additional sidecar containers to the job pod |
| datahubSystemUpdate.extraSidecars | list | `[]` | Add additional sidecar containers to the job pod |
| global.strict_mode | boolean | true | Enables validations in helm charts to ensure features work as expected. Recommended NOT TO CHANGE. |
| global.datahub_standalone_consumers_enabled | boolean | true | Enable standalone consumers for kafka |
| global.datahub_analytics_enabled | boolean | true | Enable datahub usage analytics |
| global.datahub.appVersion | string | `"1.0"` | App version for annotation |
| global.datahub.gms.port | string | `"8080"` | Port of GMS service |
| global.elasticsearch.host | string | `"elasticsearch-master"` | Elasticsearch host name (endpoint) |
| global.elasticsearch.port | string | `"9200"` | Elasticsearch port |
| global.kafka.bootstrap.server | string | `"prerequisites-broker:9092"` | Kafka bootstrap servers (with port) |
| global.kafka.zookeeper.server | string | `"prerequisites-zookeeper:2181"` | Kafka zookeeper servers (with port) |
| global.kafka.topics.metadata_change_event_name | string | `"MetadataChangeEvent_v4"` | Kafka topic name for Metadata Change Events (deprecated) |
| global.kafka.topics.failed_metadata_change_event_name | string | `"FailedMetadataChangeEvent_v4"` | Kafka topic name for Failed Metadata Change events (deprecated) |
| global.kafka.topics.metadata_audit_event_name | string | `"MetadataAuditEvent_v4"` | Kafka topic name for Metadata Audit events (deprecated) |
| global.kafka.topics.datahub_usage_event_name | string | `"DataHubUsageEvent_v1"` | Kafka topic name for DataHub Usage events |
| global.kafka.topics.metadata_change_proposal_topic_name | string | `"MetadataChangeProposal_v1"` | Kafka topic name for Metadata Change Proposal events |
| global.kafka.topics.failed_metadata_change_proposal_topic_name | string | `"FailedMetadataChangeProposal_v1"` | Kafka topic name for Failed Metadata Change Proposal events |
| global.kafka.topics.metadata_change_log_versioned_topic_name | string | `"MetadataChangeLog_Versioned_v1"` | Kafka topic name for Versioned Metadata Change Log events |
| global.kafka.topics.metadata_change_log_timeseries_topic_name | string | `"MetadataChangeLog_Timeseries_v1"` | Kafka topic name for Timeseries Metadata Change Log events |
| global.kafka.topics.platform_event_topic_name | string | `"PlatformEvent_v1"` | Kafka topic name for Platform events |
| global.kafka.schemaregistry.url | string | `` | URL to kafka schema registry if using `KAFKA` type |
| global.neo4j.host | string | `"prerequisites-neo4j:7474"` | Neo4j host address (with port) |
| global.neo4j.uri | string | `"bolt://prerequisites-neo4j"` | Neo4j URI |
| global.neo4j.username | string | `"neo4j"` | Neo4j user name |
| global.neo4j.password.secretRef | string | `"neo4j-secrets"` | Secret that contains the Neo4j password |
| global.neo4j.password.secretKey | string | `"neo4j-password"` | Secret key that contains the Neo4j password |
| global.sql.datasource.driver | string | `"com.mysql.cj.jdbc.Driver"` | Driver for the SQL database |
| global.sql.datasource.host | string | `"prerequisites-mysql:3306"` | SQL database host (with port) |
| global.sql.datasource.hostForMysqlClient | string | `"prerequisites-mysql"` | SQL database host (without port) |
| global.sql.datasource.port | string | `"3306"` | SQL database port |
| global.sql.datasource.url | string | `"jdbc:mysql://prerequisites-mysql:3306/datahub?verifyServerCertificate=false\u0026useSSL=true"` | URL to access SQL database |
| global.sql.datasource.username | string | `"root"` | SQL user name |
| global.sql.datasource.username.secretRef | string | `"mysql-secrets"` | Secret that contains the MySQL username |
| global.sql.datasource.username.secretKey | string | `"mysql-username"` | Secret key that contains the MySQL username |
| global.sql.datasource.password.secretRef | string | `"mysql-secrets"` | Secret that contains the MySQL password |
| global.sql.datasource.password.secretKey | string | `"mysql-password"` | Secret key that contains the MySQL password |
| global.sql.datasource.password.value | string | `"mysql-password"` | Alternative to using the secret above, uses raw string value instead |
| global.graph_service_impl | string | `neo4j` | One of `neo4j` or `elasticsearch`. Determines which backend to use for the GMS graph service. Elastic is recommended for a simplified deployment. Neo4j will be the default for now to maintain backwards compatibility |

## Optional Chart Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| datahub-gms.sql.datasource.username | string | `root` | SQL username for GMS (overrides global value) |
| datahub-gms.sql.datasource.username.secretRef | string | `"mysql-secrets"` | Secret that contains the GMS SQL username (overrides global value) |
| datahub-gms.sql.datasource.username.secretKey | string | `"mysql-username"` | Secret key that contains the GMS SQL username (overrides global value) |
| datahub-gms.sql.datasource.password.secretRef | string | `"mysql-secrets"` | Secret that contains the GMS SQL password (overrides global value) |
| datahub-gms.sql.datasource.password.secretKey | string | `"mysql-password"` | Secret key that contains the GMS SQL password (overrides global value) |
| datahub-gms.sql.datasource.password.value | string | `"mysql-password"` | Alternative to using the secret above, uses raw string value for GMS SQL login (overrides global value) |
| mysqlSetupJob.username | string | `root` | SQL username for mysqlSetupJob (overrides global value) |
| mysqlSetupJob.password.secretRef | string | `"mysql-secrets"` | Secret that contains the mysqlSetupJob SQL password (overrides global value) |
| mysqlSetupJob.password.secretKey | string | `"mysql-password"` | Secret key that contains the mysqlSetupJob SQL password (overrides global value) |
| mysqlSetupJob.password.value | string | `"mysql-password"` | Alternative to using the secret above, uses raw string value for mysqlSetupJob SQL login (overrides global value) |
| postgresqlSetupJob.username | string | `root` | SQL username for postgresqlSetupJob (overrides global value) |
| postgresqlSetupJob.password.secretRef | string | `"mysql-secrets"` | Secret that contains the postgresqlSetupJob SQL password (overrides global value) |
| postgresqlSetupJob.password.secretKey | string | `"mysql-password"` | Secret key that contains the postgresqlSetupJob SQL password (overrides global value) |
| postgresqlSetupJob.password.value | string | `"mysql-password"` | Alternative to using the secret above, uses raw string value for postgresqlSetupJob SQL login (overrides global value) |
| acryl-datahub-actions.ingestionSecretFiles.name | string | `""` | Name of the k8s secret that holds any secret files (e.g., SSL certificates and private keys) that are used in your ingestion recipes. The keys in the secret will be mounted as individual files under `/etc/datahub/ingestion-secret-files` |
| acryl-datahub-actions.ingestionSecretFiles.defaultMode | string | `""` | The permission mode for the volume that mounts k8s secret under `/etc/datahub/ingestion-secret-files`, default value is 0444 which allows read access by owner, group, and other users |
| global.credentialsAndCertsSecrets.name | string | `""` | Name of the secret that holds SSL certificates (keystores, truststores) |
| global.credentialsAndCertsSecrets.path | string | `"/mnt/certs"` | Path to mount the SSL certificates |
| global.credentialsAndCertsSecrets.secureEnv | map | `{}` | Map of SSL config name and the corresponding value in the secret |
| global.springKafkaConfigurationOverrides | map | `{}` | Map of configuration overrides for accessing kafka |
| global.elasticsearch.useSSL | bool | `false` | Whether to enable SSL for accessing elasticsearch |
| global.elasticsearch.auth.username | string | `""` | Elasticsearch username |
| global.elasticsearch.auth.password.secretRef | string | `""` | Secret that contains the elasticsearch password |
| global.elasticsearch.auth.password.secretKey | string | `""` | Secret key that contains the elasticsearch password |
| global.elasticsearch.auth.password.value | string | `""` | Alternative to using the secret above, uses raw string value instead |
| global.kafka.schemaregistry.type | string | `"INTERNAL"` | Type of schema registry (INTERNAL, KAFKA, or AWS_GLUE) |
| global.kafka.schemaregistry.glue.region | string | `""` | Region of the AWS Glue schema registry |
| global.kafka.schemaregistry.glue.registry | string | `""` | Name of the AWS Glue schema registry |
| datahub.metadata_service_authentication.enabled | bool | `false` | Whether Metadata Service Authentication is enabled. |
| global.datahub.metadata_service_authentication.systemClientId | string | `"__datahub_system"` | The internal system id that is used to communicate with DataHub GMS. Required if metadata_service_authentication is 'true'. |
| global.datahub.metadata_service_authentication.systemClientSecret.secretRef | string | `datahub-auth-secrets` | The reference to a secret containing the internal system secret that is used to communicate with DataHub GMS. If a secret reference is not provided, a random one will be generated for you in a Kubernetes secret called `datahub-auth-secrets`. |
| global.datahub.metadata_service_authentication.systemClientSecret.secretKey | string | `system_client_secret` | The key of a secret containing the internal system secret that is used to communicate with DataHub GMS. If a secret reference is not provided, a random one will be generated for you in a Kubernetes secret value named `system_client_secret` within a secret named `datahub-auth-secrets`. |
| global.datahub.metadata_service_authentication.tokenService.signingKey.secretRef | string | `datahub-auth-secrets` | The reference to a secret containing the internal system secret that is used to sign JWT auth tokens issued by DataHub GMS. If a secret reference is not provided, a random one will be generated for you in a Kubernetes secret called `datahub-auth-secrets`. |
| global.datahub.metadata_service_authentication.tokenService.signingKey.secretKey | string | `token_service_signing_key` | The key of a secret containing the internal system secret that is used to sign JWT auth tokens issued by DataHub GMS. If a secret reference is not provided, a random one will be generated for you in a Kubernetes secret value named `token_service_signing_key` within a secret named `datahub-auth-secrets`. | 
| global.datahub.metadata_service_authentication.tokenService.salt.secretRef | string | `datahub-auth-secrets` | The reference to a secret containing the internal system secret that is used to salt JWT auth tokens signatures issued by DataHub GMS that is part of the metadata graph. If a secret reference is not provided, a random one will be generated for you in a Kubernetes secret called `datahub-auth-secrets`. |
| global.datahub.metadata_service_authentication.tokenService.salt.secretKey | string | `token_service_salt` | The key of a secret containing the internal system secret that is used to salt JWT auth tokens signatures issued by DataHub GMS that is part of the metadata graph. If a secret reference is not provided, a random one will be generated for you in a Kubernetes secret value named `token_service_salt` within a secret named `datahub-auth-secrets`. |
| global.datahub.metadata_service_authentication.provisionSecrets.enabled | bool | `true` | Whether auth secrets (system client secret, token signing key & token service salt) should be provisioned on the first deployment for you. Set this to false if you are overriding `global.datahub.metadata_service_authentication.tokenService.signingKey.secretRef` or `global.datahub.metadata_service_authentication systemClientSecret.secretRef`. |
| global.datahub.metadata_service_authentication.provisionSecrets.autoGenerate | bool | `true` | Whether auth secrets (token signing key, system client secret & token service salt) should be provisioned on the first deployment for you **with a random seed** on the first deployment for you. Set this to false and use `global.datahub.metadata_service_authentication.provisionSecrets.secretValues.*` if you would like to specify the secret values directly. |
| global.datahub.encryptionKey.provisionSecrets.secretValues.secret | string | `` | The system client secret key value to be used if specified directly. |
| global.datahub.encryptionKey.provisionSecrets.secretValues.signingkey | string | `` | The system signing key value to be used if specified directly. |
| global.datahub.encryptionKey.provisionSecrets.secretValues.salt | string | `` | The token service salt value to be used if specified directly. |
| global.datahub.managed_ingestion.enabled | bool | `true` | Whether or not UI-based ingestion experience is enabled. |
| global.datahub.encryptionKey.secretRef | string | `datahub-encryption-secrets` | The reference to a secret containing an alpha-numeric encryption key, which is used to encrypt Secrets on DataHub. If a secret reference is not provided, a random one will be generated for you in a Kubernetes secret named `datahub-encryption-secrets`. |
| global.datahub.encryptionKey.secretKey | string | `encryption_key_secret` | The key of a secret containing an alpha-numeric encryption key, which is used to encrypt Secrets on DataHub. If a secret reference is not provided, a random one will be generated for you in a Kubernetes secret value named `encryption_key_secret` within a secret named `datahub-encryption-secrets`. |
| global.datahub.managed_ingestion.defaultCliVersion | string | `` |0.10.0 This is the version of the DataHub CLI to use for UI ingestion, by default. |
| global.datahub.encryptionKey.provisionSecret.enabled | bool | `true` | Whether an encryption key secret should be provisioned on the first deployment for you. Set this to false if you are overriding global.datahub.encryptionKey.secretRef. |
| global.datahub.encryptionKey.provisionSecret.autoGenerate | bool | `true` | Whether an encryption key secret should be provisioned for you **with a random seed** on the first deployment for you. Set this to false and use `global.datahub.encryptionKey.provisionSecret.secretValues.encryptionKey` if you would like to specify the secret values directly. |
| global.datahub.encryptionKey.provisionSecret.secretValues.encryptionKey | string | `` | The encryption key value to be used if specified directly. |
| global.datahub.enable_retention | bool | `false` | Whether or not to enable retention on local DB |
| global.sql.datasource.hostForpostgresqlClient | string | `""` | SQL database host (without port) when using postgresqlSetupJob |
