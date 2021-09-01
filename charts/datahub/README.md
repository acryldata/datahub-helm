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
| datahub-frontend.image.tag | string | `"v0.8.11"` | Image tag for datahub-frontend |
| datahub-gms.enabled | bool | `true` | Enable GMS |
| datahub-gms.image.repository | string | `"linkedin/datahub-gms"` | Image repository for datahub-gms |
| datahub-gms.image.tag | string | `"v0.8.11"` | Image tag for datahub-gms |
| datahub-mae-consumer.image.repository | string | `"linkedin/datahub-mae-consumer"` | Image repository for datahub-mae-consumer |
| datahub-mae-consumer.image.tag | string | `"v0.8.11"` | Image tag for datahub-mae-consumer |
| datahub-mce-consumer.image.repository | string | `"linkedin/datahub-mce-consumer"` | Image repository for datahub-mce-consumer |
| datahub-mce-consumer.image.tag | string | `"v0.8.11"` | Image tag for datahub-mce-consumer |
| datahub-ingestion-cron.enabled | bool | `false` | Enable cronjob for periodic ingestion |
| elasticsearchSetupJob.enabled | bool | `true` | Enable setup job for elasicsearch |
| elasticsearchSetupJob.image.repository | string | `"linkedin/datahub-elasticsearch-setup"` | Image repository for elasticsearchSetupJob |
| elasticsearchSetupJob.image.tag | string | `"v0.8.11"` | Image repository for elasticsearchSetupJob |
| kafkaSetupJob.enabled | bool | `true` | Enable setup job for kafka |
| kafkaSetupJob.image.repository | string | `"linkedin/datahub-kafka-setup"` | Image repository for kafkaSetupJob |
| kafkaSetupJob.image.tag | string | `"v0.8.11"` | Image repository for kafkaSetupJob |
| mysqlSetupJob.enabled | bool | `false` | Enable setup job for mysql |
| mysqlSetupJob.image.repository | string | `""` | Image repository for mysqlSetupJob |
| mysqlSetupJob.image.tag | string | `""` | Image repository for mysqlSetupJob |
| global.datahub_standalone_consumers_enabled | boolean | true | Enable standalone consumers for kafka |
| global.datahub_analytics_enabled | boolean | true | Enable datahub usage analytics |
| global.datahub.appVersion | string | `"1.0"` | App version for annotation |
| global.datahub.gms.port | string | `"8080"` | Port of GMS service |
| global.elasticsearch.host | string | `"elasticsearch-master"` | Elasticsearch host name (endpoint) |
| global.elasticsearch.port | string | `"9200"` | Elasticsearch port |
| global.kafka.bootstrap.server | string | `"prerequisites-broker:9092"` | Kafka bootstrap servers (with port) |
| global.kafka.zookeeper.server | string | `"prerequisites-zookeeper:2181"` | Kafka zookeeper servers (with port) |
| global.kafka.schemaregistry.url | string | `"http://prerequisites-cp-schema-registry:8081"` | URL to kafka schema registry |
| global.neo4j.host | string | `"prerequisites-neo4j:7474"` | Neo4j host address (with port) |
| global.neo4j.uri | string | `"bolt://prerequisites-neo4j"` | Neo4j URI |
| global.neo4j.username | string | `"neo4j"` | Neo4j user name |
| global.neo4j.password.secretRef | string | `"neo4j-secrets"` | Secret that contains the Neo4j password |
| global.neo4j.password.secretKey | string | `"neo4j-password"` | Secret key that contains the Neo4j password |
| global.sql.datasource.driver | string | `"com.mysql.jdbc.Driver"` | Driver for the SQL database |
| global.sql.datasource.host | string | `"prerequisites-mysql:3306"` | SQL database host (with port) |
| global.sql.datasource.hostForMysqlClient | string | `"prerequisites-mysql"` | SQL database host (without port) |
| global.sql.datasource.url | string | `"jdbc:mysql://prerequisites-mysql:3306/datahub?verifyServerCertificate=false\u0026useSSL=true"` | URL to access SQL database |
| global.sql.datasource.username | string | `"root"` | SQL user name |
| global.sql.datasource.password.secretRef | string | `"mysql-secrets"` | Secret that contains the MySQL password |
| global.sql.datasource.password.secretKey | string | `"mysql-password"` | Secret key that contains the MySQL password |
| global.graph_service_impl | string | `neo4j` | One of `neo4j` or `elasticsearch`. Determines which backend to use for the GMS graph service. Elastic is recommended for a simplified deployment. Neo4j will be the default for now to maintain backwards compatibility.

## Optional Chart Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.credentialsAndCertsSecrets.name | string | `""` | Name of the secret that holds SSL certificates (keystores, truststores) |
| global.credentialsAndCertsSecrets.path | string | `"/mnt/certs"` | Path to mount the SSL certificates |
| global.credentialsAndCertsSecrets.secureEnv | map | `{}` | Map of SSL config name and the corresponding value in the secret |
| global.springKafkaConfigurationOverrides | map | `{}` | Map of configuration overrides for accessing kafka |
| global.elasticsearch.useSSL | bool | `false` | Whether to enable SSL for accessing elasticsearch |
| global.elasticsearch.auth.username | string | `""` | Elasticsearch username |
| global.elasticsearch.auth.password.secretRef | string | `""` | Secret that contains the elasticsearch password |
| global.elasticsearch.auth.password.secretKey | string | `""` | Secret key that contains the elasticsearch password |
| global.kafka.schemaregistry.type | string | `"KAFKA"` | Type of schema registry (KAFKA or AWS_GLUE) |
| global.kafka.schemaregistry.glue.region | string | `""` | Region of the AWS Glue schema registry |
| global.kafka.schemaregistry.glue.registry | string | `""` | Name of the AWS Glue schema registry |
