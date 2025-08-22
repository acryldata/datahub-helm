# Complete DataHub Helm Chart Values Reference

This document provides a comprehensive reference for every single configurable value in the DataHub Helm chart.

## Global Values

<table>
<thead>
<tr>
<th>Configuration Path</th>
<th>Type</th>
<th>Default</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>global.strict_mode</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Enable strict validation mode for Helm chart configurations. Validates that all required features and dependencies are properly configured. Recommended to keep enabled for production deployments.</td>
</tr>
<tr>
<td><code>global.graph_service_impl</code></td>
<td>string</td>
<td><code>elasticsearch</code></td>
<td>Graph service implementation backend. Choose between <code>elasticsearch</code> (recommended for simplified deployments) or <code>neo4j</code> (for advanced graph queries). Controls how DataHub stores and queries relationship data.</td>
</tr>
<tr>
<td><code>global.datahub_analytics_enabled</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Enable DataHub usage analytics collection. Tracks platform usage patterns, feature adoption, and performance metrics to improve the DataHub experience.</td>
</tr>
<tr>
<td><code>global.datahub_standalone_consumers_enabled</code></td>
<td>boolean</td>
<td><code>false</code></td>
<td>Enable standalone Kafka consumers for metadata processing. When enabled, consumers run as separate services rather than embedded within other DataHub components.</td>
</tr>
<tr>
<td><code>global.imageRegistry</code></td>
<td>string</td>
<td><code>docker.io</code></td>
<td>Default Docker registry for DataHub container images. Can be overridden for air-gapped environments or private registries.</td>
</tr>
</tbody>
</table>

### Global Elasticsearch Configuration

<table>
<thead>
<tr>
<th>Configuration Path</th>
<th>Type</th>
<th>Default</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>global.elasticsearch.host</code></td>
<td>string</td>
<td><code>elasticsearch-master</code></td>
<td>Elasticsearch/OpenSearch cluster endpoint hostname. Used for search indexing, graph queries, and metadata discovery.</td>
</tr>
<tr>
<td><code>global.elasticsearch.port</code></td>
<td>string</td>
<td><code>9200</code></td>
<td>Port number for Elasticsearch/OpenSearch cluster connection.</td>
</tr>
<tr>
<td><code>global.elasticsearch.skipcheck</code></td>
<td>string</td>
<td><code>false</code></td>
<td>Skip Elasticsearch cluster health checks during startup. Useful for development environments or when cluster health checks are handled externally.</td>
</tr>
<tr>
<td><code>global.elasticsearch.insecure</code></td>
<td>string</td>
<td><code>false</code></td>
<td>Allow insecure (non-SSL) connections to Elasticsearch. Should be disabled in production environments for security compliance.</td>
</tr>
<tr>
<td><code>global.elasticsearch.useSSL</code></td>
<td>string</td>
<td><code>false</code></td>
<td>Enable SSL/TLS encryption for Elasticsearch connections. Required for secure connections to managed services and production deployments.</td>
</tr>
<tr>
<td><code>global.elasticsearch.indexPrefix</code></td>
<td>string</td>
<td><code></code></td>
<td>Prefix for all Elasticsearch indices created by DataHub. Useful for multi-tenant deployments or when sharing Elasticsearch clusters with other applications.</td>
</tr>
</tbody>
</table>

### Global Elasticsearch Index Configuration

<table>
<thead>
<tr>
<th>Configuration Path</th>
<th>Type</th>
<th>Default</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>global.elasticsearch.index.enableMappingsReindex</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Enable automatic reindexing when Elasticsearch field mappings change. Ensures search functionality remains consistent when metadata schema evolves.</td>
</tr>
<tr>
<td><code>global.elasticsearch.index.enableSettingsReindex</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Enable automatic reindexing when Elasticsearch index settings are updated. Maintains optimal search performance when index configurations are modified.</td>
</tr>
<tr>
<td><code>global.elasticsearch.index.settingsOverrides</code></td>
<td>string/object</td>
<td><code></code></td>
<td>Custom Elasticsearch index settings to override defaults. Allows fine-tuning of index configurations for specific performance or functionality requirements.</td>
</tr>
<tr>
<td><code>global.elasticsearch.index.entitySettingsOverrides</code></td>
<td>string/object</td>
<td><code></code></td>
<td>Entity-specific Elasticsearch index settings. Enables different index configurations for different types of metadata entities (datasets, users, etc.).</td>
</tr>
<tr>
<td><code>global.elasticsearch.index.refreshIntervalSeconds</code></td>
<td>integer</td>
<td><code>1</code></td>
<td>Time interval (in seconds) between Elasticsearch index refreshes. Controls how quickly new metadata becomes searchable after ingestion. Lower values improve real-time search but increase cluster load.</td>
</tr>
<tr>
<td><code>global.elasticsearch.index.upgrade.cloneIndices</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Clone existing indices during DataHub upgrades. Preserves existing metadata and search functionality during version upgrades and schema migrations.</td>
</tr>
<tr>
<td><code>global.elasticsearch.index.upgrade.allowDocCountMismatch</code></td>
<td>boolean</td>
<td><code>false</code></td>
<td>Allow document count differences during index upgrades. Useful for development environments but may indicate data loss in production.</td>
</tr>
<tr>
<td><code>global.elasticsearch.index.upgrade.reindexOptimizationEnabled</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Enable optimized reindexing during upgrades. Improves upgrade performance by using efficient bulk operations and parallel processing.</td>
</tr>
</tbody>
</table>

### Global Elasticsearch Search Configuration

<table>
<thead>
<tr>
<th>Configuration Path</th>
<th>Type</th>
<th>Default</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>global.elasticsearch.search.maxTermBucketSize</code></td>
<td>integer</td>
<td><code>20</code></td>
<td>Maximum number of terms returned in search aggregations. Controls the breadth of search suggestions and autocomplete results.</td>
</tr>
<tr>
<td><code>global.elasticsearch.search.exactMatch.exclusive</code></td>
<td>boolean</td>
<td><code>false</code></td>
<td>Enable exclusive exact matching in search queries. When enabled, only exact matches are returned, excluding partial or fuzzy matches.</td>
</tr>
<tr>
<td><code>global.elasticsearch.search.exactMatch.withPrefix</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Include prefix matching in exact search results. Allows finding entities that start with the search term while maintaining exact match relevance.</td>
</tr>
<tr>
<td><code>global.elasticsearch.search.exactMatch.exactFactor</code></td>
<td>float</td>
<td><code>2.0</code></td>
<td>Boost factor for exact matches in search relevance scoring. Higher values prioritize exact matches over partial or fuzzy matches.</td>
</tr>
<tr>
<td><code>global.elasticsearch.search.exactMatch.prefixFactor</code></td>
<td>float</td>
<td><code>1.6</code></td>
<td>Boost factor for prefix matches in search relevance scoring. Controls how much prefix matches are prioritized in search results.</td>
</tr>
<tr>
<td><code>global.elasticsearch.search.exactMatch.caseSensitivityFactor</code></td>
<td>float</td>
<td><code>0.7</code></td>
<td>Penalty factor for case-insensitive matches. Reduces relevance score for matches that don't preserve the original case.</td>
</tr>
<tr>
<td><code>global.elasticsearch.search.exactMatch.enableStructured</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Enable structured exact matching for complex queries. Supports field-specific searches and advanced query syntax.</td>
</tr>
<tr>
<td><code>global.elasticsearch.search.graph.timeoutSeconds</code></td>
<td>integer</td>
<td><code>50</code></td>
<td>Timeout (in seconds) for graph-based search queries. Controls how long DataHub waits for complex relationship queries before timing out.</td>
</tr>
<tr>
<td><code>global.elasticsearch.search.graph.batchSize</code></td>
<td>integer</td>
<td><code>1000</code></td>
<td>Number of entities processed per batch in graph search operations. Balances memory usage with search performance for large datasets.</td>
</tr>
<tr>
<td><code>global.elasticsearch.search.graph.maxResult</code></td>
<td>integer</td>
<td><code>10000</code></td>
<td>Maximum number of results returned by graph search queries. Prevents memory issues with very large result sets.</td>
</tr>
<tr>
<td><code>global.elasticsearch.search.custom</code></td>
<td>object</td>
<td><code>{}</code></td>
<td>Custom search configurations. Allows fine-tuning of search behavior for specific use cases or data types.</td>
</tr>
</tbody>
</table>

### Global Kafka Configuration

<table>
<thead>
<tr>
<th>Configuration Path</th>
<th>Type</th>
<th>Default</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>global.kafka.bootstrap.server</code></td>
<td>string</td>
<td><code>prerequisites-kafka:9092</code></td>
<td>Kafka broker address. Used for metadata change event streaming, real-time notifications, and inter-service communication in DataHub's event-driven architecture.</td>
</tr>
<tr>
<td><code>global.kafka.zookeeper.server</code></td>
<td>string</td>
<td><code>prerequisites-zookeeper:2181</code></td>
<td>Zookeeper server address for Kafka cluster coordination.</td>
</tr>
<tr>
<td><code>global.kafka.topics.metadata_change_event_name</code></td>
<td>string</td>
<td><code>MetadataChangeEvent_v4</code></td>
<td>Kafka topic name for metadata change events.</td>
</tr>
<tr>
<td><code>global.kafka.topics.failed_metadata_change_event_name</code></td>
<td>string</td>
<td><code>FailedMetadataChangeEvent_v4</code></td>
<td>Kafka topic name for failed metadata change events.</td>
</tr>
<tr>
<td><code>global.kafka.topics.metadata_audit_event_name</code></td>
<td>string</td>
<td><code>MetadataAuditEvent_v4</code></td>
<td>Kafka topic name for metadata audit events.</td>
</tr>
<tr>
<td><code>global.kafka.topics.datahub_usage_event_name</code></td>
<td>string</td>
<td><code>DataHubUsageEvent_v1</code></td>
<td>Kafka topic name for usage events.</td>
</tr>
<tr>
<td><code>global.kafka.topics.metadata_change_proposal_topic_name</code></td>
<td>string</td>
<td><code>MetadataChangeProposal_v1</code></td>
<td>Kafka topic name for metadata change proposals.</td>
</tr>
<tr>
<td><code>global.kafka.topics.failed_metadata_change_proposal_topic_name</code></td>
<td>string</td>
<td><code>FailedMetadataChangeProposal_v1</code></td>
<td>Kafka topic name for failed metadata change proposals.</td>
</tr>
<tr>
<td><code>global.kafka.topics.metadata_change_log_versioned_topic_name</code></td>
<td>string</td>
<td><code>MetadataChangeLog_Versioned_v1</code></td>
<td>Kafka topic name for versioned metadata change logs.</td>
</tr>
<tr>
<td><code>global.kafka.topics.metadata_change_log_timeseries_topic_name</code></td>
<td>string</td>
<td><code>MetadataChangeLog_Timeseries_v1</code></td>
<td>Kafka topic name for timeseries metadata change logs.</td>
</tr>
<tr>
<td><code>global.kafka.topics.platform_event_topic_name</code></td>
<td>string</td>
<td><code>PlatformEvent_v1</code></td>
<td>Kafka topic name for platform events.</td>
</tr>
<tr>
<td><code>global.kafka.topics.datahub_upgrade_history_topic_name</code></td>
<td>string</td>
<td><code>DataHubUpgradeHistory_v1</code></td>
<td>Kafka topic name for upgrade history events.</td>
</tr>
<tr>
<td><code>global.kafka.consumer_groups.datahub_upgrade_history_kafka_consumer_group_id</code></td>
<td>object</td>
<td><code>{}</code></td>
<td>Consumer group configuration for upgrade history events.</td>
</tr>
<tr>
<td><code>global.kafka.consumer_groups.datahub_actions_doc_propagation_consumer_group_id</code></td>
<td>string</td>
<td><code>datahub_doc_propagation_action</code></td>
<td>Consumer group ID for document propagation actions.</td>
</tr>
<tr>
<td><code>global.kafka.consumer_groups.datahub_actions_ingestion_executor_consumer_group_id</code></td>
<td>string</td>
<td><code>ingestion_executor</code></td>
<td>Consumer group ID for ingestion executor actions.</td>
</tr>
<tr>
<td><code>global.kafka.consumer_groups.datahub_actions_slack_consumer_group_id</code></td>
<td>string</td>
<td><code>datahub_slack_action</code></td>
<td>Consumer group ID for Slack actions.</td>
</tr>
<tr>
<td><code>global.kafka.consumer_groups.datahub_actions_teams_consumer_group_id</code></td>
<td>string</td>
<td><code>datahub_teams_action</code></td>
<td>Consumer group ID for Teams actions.</td>
</tr>
<tr>
<td><code>global.kafka.consumer_groups.datahub_usage_event_kafka_consumer_group_id</code></td>
<td>string</td>
<td><code>datahub-usage-event-consumer-job-client</code></td>
<td>Consumer group ID for usage events.</td>
</tr>
<tr>
<td><code>global.kafka.consumer_groups.metadata_change_log_kafka_consumer_group_id</code></td>
<td>string</td>
<td><code>generic-mae-consumer-job-client</code></td>
<td>Consumer group ID for metadata change logs.</td>
</tr>
<tr>
<td><code>global.kafka.consumer_groups.platform_event_kafka_consumer_group_id</code></td>
<td>string</td>
<td><code>generic-platform-event-job-client</code></td>
<td>Consumer group ID for platform events.</td>
</tr>
<tr>
<td><code>global.kafka.consumer_groups.metadata_change_event_kafka_consumer_group_id</code></td>
<td>string</td>
<td><code>mce-consumer-job-client</code></td>
<td>Consumer group ID for metadata change events.</td>
</tr>
<tr>
<td><code>global.kafka.consumer_groups.metadata_change_proposal_kafka_consumer_group_id</code></td>
<td>string</td>
<td><code>generic-mce-consumer-job-client</code></td>
<td>Consumer group ID for metadata change proposals.</td>
</tr>
<tr>
<td><code>global.kafka.maxMessageBytes</code></td>
<td>string</td>
<td><code>5242880</code></td>
<td>Maximum message size (5MB) for Kafka topics. Controls the size limit for metadata change events.</td>
</tr>
<tr>
<td><code>global.kafka.producer.compressionType</code></td>
<td>string</td>
<td><code>none</code></td>
<td>Compression algorithm for Kafka producers. Reduces network bandwidth and storage requirements for metadata events.</td>
</tr>
<tr>
<td><code>global.kafka.producer.maxRequestSize</code></td>
<td>string</td>
<td><code>5242880</code></td>
<td>Maximum request size (5MB) for Kafka producers. Controls the size limit for bulk metadata operations.</td>
</tr>
<tr>
<td><code>global.kafka.consumer.maxPartitionFetchBytes</code></td>
<td>string</td>
<td><code>5242880</code></td>
<td>Maximum bytes fetched per partition for Kafka consumers. Controls memory usage and processing efficiency.</td>
</tr>
<tr>
<td><code>global.kafka.consumer.stopContainerOnDeserializationError</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Stop container when Kafka message deserialization fails. Prevents data corruption from malformed messages.</td>
</tr>
<tr>
<td><code>global.kafka.schemaregistry.type</code></td>
<td>string</td>
<td><code>INTERNAL</code></td>
<td>Type of schema registry (INTERNAL, KAFKA, AWS_GLUE). Controls how DataHub manages schema versions and compatibility for metadata events.</td>
</tr>
<tr>
<td><code>global.kafka.schemaregistry.url</code></td>
<td>string</td>
<td><code></code></td>
<td>URL for external Kafka Schema Registry. Required when using KAFKA schema registry type.</td>
</tr>
</tbody>
</table>

### Global Kafka Metadata Change Log Configuration

<table>
<thead>
<tr>
<th>Configuration Path</th>
<th>Type</th>
<th>Default</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>global.kafka.metadataChangeLog.hooks.siblings.enabled</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Enable siblings hook for metadata change log processing.</td>
</tr>
<tr>
<td><code>global.kafka.metadataChangeLog.hooks.siblings.consumerGroupSuffix</code></td>
<td>string</td>
<td><code></code></td>
<td>Suffix for siblings hook consumer group.</td>
</tr>
<tr>
<td><code>global.kafka.metadataChangeLog.hooks.updateIndices.enabled</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Enable update indices hook for metadata change log processing.</td>
</tr>
<tr>
<td><code>global.kafka.metadataChangeLog.hooks.updateIndices.consumerGroupSuffix</code></td>
<td>string</td>
<td><code></code></td>
<td>Suffix for update indices hook consumer group.</td>
</tr>
<tr>
<td><code>global.kafka.metadataChangeLog.hooks.ingestionScheduler.enabled</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Enable ingestion scheduler hook for metadata change log processing.</td>
</tr>
<tr>
<td><code>global.kafka.metadataChangeLog.hooks.ingestionScheduler.consumerGroupSuffix</code></td>
<td>string</td>
<td><code></code></td>
<td>Suffix for ingestion scheduler hook consumer group.</td>
</tr>
<tr>
<td><code>global.kafka.metadataChangeLog.hooks.incidents.enabled</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Enable incidents hook for metadata change log processing.</td>
</tr>
<tr>
<td><code>global.kafka.metadataChangeLog.hooks.incidents.consumerGroupSuffix</code></td>
<td>string</td>
<td><code></code></td>
<td>Suffix for incidents hook consumer group.</td>
</tr>
<tr>
<td><code>global.kafka.metadataChangeLog.hooks.entityChangeEvents.enabled</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Enable entity change events hook for metadata change log processing.</td>
</tr>
<tr>
<td><code>global.kafka.metadataChangeLog.hooks.entityChangeEvents.consumerGroupSuffix</code></td>
<td>string</td>
<td><code></code></td>
<td>Suffix for entity change events hook consumer group.</td>
</tr>
<tr>
<td><code>global.kafka.metadataChangeLog.hooks.forms.enabled</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Enable forms hook for metadata change log processing.</td>
</tr>
<tr>
<td><code>global.kafka.metadataChangeLog.hooks.forms.consumerGroupSuffix</code></td>
<td>string</td>
<td><code></code></td>
<td>Suffix for forms hook consumer group.</td>
</tr>
</tbody>
</table>

### Global Neo4j Configuration

<table>
<thead>
<tr>
<th>Configuration Path</th>
<th>Type</th>
<th>Default</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>global.neo4j.host</code></td>
<td>string</td>
<td><code>prerequisites-neo4j:7474</code></td>
<td>Neo4j host and port for graph database connections.</td>
</tr>
<tr>
<td><code>global.neo4j.uri</code></td>
<td>string</td>
<td><code>bolt://prerequisites-neo4j</code></td>
<td>Neo4j bolt URI for graph database connections.</td>
</tr>
<tr>
<td><code>global.neo4j.username</code></td>
<td>string</td>
<td><code>neo4j</code></td>
<td>Neo4j username for authentication.</td>
</tr>
<tr>
<td><code>global.neo4j.password.secretRef</code></td>
<td>string</td>
<td><code>neo4j-secrets</code></td>
<td>Kubernetes secret reference containing Neo4j password.</td>
</tr>
<tr>
<td><code>global.neo4j.password.secretKey</code></td>
<td>string</td>
<td><code>neo4j-password</code></td>
<td>Secret key for Neo4j password in the referenced secret.</td>
</tr>
<tr>
<td><code>global.neo4j.password.value</code></td>
<td>string</td>
<td><code></code></td>
<td>Direct Neo4j password value (alternative to secret reference).</td>
</tr>
</tbody>
</table>

### Global SQL Configuration

<table>
<thead>
<tr>
<th>Configuration Path</th>
<th>Type</th>
<th>Default</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>global.sql.datasource.host</code></td>
<td>string</td>
<td><code>prerequisites-mysql:3306</code></td>
<td>SQL database host and port for metadata storage.</td>
</tr>
<tr>
<td><code>global.sql.datasource.hostForMysqlClient</code></td>
<td>string</td>
<td><code>prerequisites-mysql</code></td>
<td>MySQL client host for database connections.</td>
</tr>
<tr>
<td><code>global.sql.datasource.port</code></td>
<td>string</td>
<td><code>3306</code></td>
<td>SQL database port for connections.</td>
</tr>
<tr>
<td><code>global.sql.datasource.url</code></td>
<td>string</td>
<td><code>jdbc:mysql://prerequisites-mysql:3306/datahub?verifyServerCertificate=false&useSSL=true&useUnicode=yes&characterEncoding=UTF-8&enabledTLSProtocols=TLSv1.2</code></td>
<td>JDBC connection URL for SQL database.</td>
</tr>
<tr>
<td><code>global.sql.datasource.driver</code></td>
<td>string</td>
<td><code>com.mysql.cj.jdbc.Driver</code></td>
<td>JDBC driver class for SQL database.</td>
</tr>
<tr>
<td><code>global.sql.datasource.username</code></td>
<td>string</td>
<td><code>root</code></td>
<td>SQL database username for authentication.</td>
</tr>
<tr>
<td><code>global.sql.datasource.password.secretRef</code></td>
<td>string</td>
<td><code>mysql-secrets</code></td>
<td>Kubernetes secret reference containing SQL database password.</td>
</tr>
<tr>
<td><code>global.sql.datasource.password.secretKey</code></td>
<td>string</td>
<td><code>mysql-root-password</code></td>
<td>Secret key for SQL database password in the referenced secret.</td>
</tr>
<tr>
<td><code>global.sql.datasource.password.value</code></td>
<td>string</td>
<td><code></code></td>
<td>Direct SQL database password value (alternative to secret reference).</td>
</tr>
</tbody>
</table>

### Global DataHub Configuration

<table>
<thead>
<tr>
<th>Configuration Path</th>
<th>Type</th>
<th>Default</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>global.datahub.version</code></td>
<td>string</td>
<td><code>v1.2.0</code></td>
<td>DataHub version for container images and compatibility.</td>
</tr>
<tr>
<td><code>global.datahub.gms.protocol</code></td>
<td>string</td>
<td><code>http</code></td>
<td>Protocol for GMS service communication.</td>
</tr>
<tr>
<td><code>global.datahub.gms.port</code></td>
<td>string</td>
<td><code>8080</code></td>
<td>Port for GMS service communication.</td>
</tr>
<tr>
<td><code>global.datahub.gms.nodePort</code></td>
<td>string</td>
<td><code>30001</code></td>
<td>Node port for GMS service when using NodePort service type.</td>
</tr>
<tr>
<td><code>global.datahub.timezone</code></td>
<td>string</td>
<td><code>UTC</code></td>
<td>Timezone for scheduled tasks and cron jobs.</td>
</tr>
<tr>
<td><code>global.datahub.frontend.validateSignUpEmail</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Enable email validation for user sign-up process.</td>
</tr>
<tr>
<td><code>global.datahub.monitoring.enablePrometheus</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Enable Prometheus metrics collection for monitoring.</td>
</tr>
<tr>
<td><code>global.datahub.monitoring.portName</code></td>
<td>string</td>
<td><code>jmx</code></td>
<td>Custom name for the monitoring port.</td>
</tr>
<tr>
<td><code>global.datahub.mae_consumer.port</code></td>
<td>string</td>
<td><code>9091</code></td>
<td>Port for MAE consumer service.</td>
</tr>
<tr>
<td><code>global.datahub.mae_consumer.nodePort</code></td>
<td>string</td>
<td><code>30002</code></td>
<td>Node port for MAE consumer service when using NodePort service type.</td>
</tr>
<tr>
<td><code>global.datahub.appVersion</code></td>
<td>string</td>
<td><code>1.0.0</code></td>
<td>Application version identifier.</td>
</tr>
<tr>
<td><code>global.datahub.systemUpdate.enabled</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Enable system update processes including Elasticsearch index management.</td>
</tr>
<tr>
<td><code>global.datahub.encryptionKey.secretRef</code></td>
<td>string</td>
<td><code>datahub-encryption-secrets</code></td>
<td>Kubernetes secret reference containing encryption key.</td>
</tr>
<tr>
<td><code>global.datahub.encryptionKey.secretKey</code></td>
<td>string</td>
<td><code>encryption_key_secret</code></td>
<td>Secret key for encryption key in the referenced secret.</td>
</tr>
<tr>
<td><code>global.datahub.encryptionKey.provisionSecret.enabled</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Enable automatic provisioning of encryption key secret.</td>
</tr>
<tr>
<td><code>global.datahub.encryptionKey.provisionSecret.autoGenerate</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Automatically generate encryption key if not provided.</td>
</tr>
<tr>
<td><code>global.datahub.encryptionKey.provisionSecret.annotations</code></td>
<td>object</td>
<td><code>{}</code></td>
<td>Annotations for the provisioned encryption key secret.</td>
</tr>
<tr>
<td><code>global.datahub.managed_ingestion.enabled</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Enable managed ingestion capabilities.</td>
</tr>
<tr>
<td><code>global.datahub.managed_ingestion.defaultCliVersion</code></td>
<td>string</td>
<td><code>1.0.0</code></td>
<td>Default CLI version for managed ingestion.</td>
</tr>
<tr>
<td><code>global.datahub.metadata_service_authentication.enabled</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Enable metadata service authentication.</td>
</tr>
<tr>
<td><code>global.datahub.metadata_service_authentication.systemClientId</code></td>
<td>string</td>
<td><code>__datahub_system</code></td>
<td>System client ID for metadata service authentication.</td>
</tr>
<tr>
<td><code>global.datahub.metadata_service_authentication.systemClientSecret.secretRef</code></td>
<td>string</td>
<td><code>datahub-auth-secrets</code></td>
<td>Secret reference for system client secret.</td>
</tr>
<tr>
<td><code>global.datahub.metadata_service_authentication.systemClientSecret.secretKey</code></td>
<td>string</td>
<td><code>system_client_secret</code></td>
<td>Secret key for system client secret.</td>
</tr>
<tr>
<td><code>global.datahub.metadata_service_authentication.tokenService.signingKey.secretRef</code></td>
<td>string</td>
<td><code>datahub-auth-secrets</code></td>
<td>Secret reference for token service signing key.</td>
</tr>
<tr>
<td><code>global.datahub.metadata_service_authentication.tokenService.signingKey.secretKey</code></td>
<td>string</td>
<td><code>token_service_signing_key</code></td>
<td>Secret key for token service signing key.</td>
</tr>
<tr>
<td><code>global.datahub.metadata_service_authentication.tokenService.salt.secretRef</code></td>
<td>string</td>
<td><code>datahub-auth-secrets</code></td>
<td>Secret reference for token service salt.</td>
</tr>
<tr>
<td><code>global.datahub.metadata_service_authentication.tokenService.salt.secretKey</code></td>
<td>string</td>
<td><code>token_service_salt</code></td>
<td>Secret key for token service salt.</td>
</tr>
<tr>
<td><code>global.datahub.metadata_service_authentication.provisionSecrets.enabled</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Enable automatic provisioning of authentication secrets.</td>
</tr>
<tr>
<td><code>global.datahub.metadata_service_authentication.provisionSecrets.autoGenerate</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Automatically generate authentication secrets if not provided.</td>
</tr>
<tr>
<td><code>global.datahub.metadata_service_authentication.provisionSecrets.annotations</code></td>
<td>object</td>
<td><code>{}</code></td>
<td>Annotations for the provisioned authentication secrets.</td>
</tr>
<tr>
<td><code>global.datahub.alwaysEmitChangeLog</code></td>
<td>boolean</td>
<td><code>false</code></td>
<td>Always emit metadata change log events even when no changes are detected. Used for Time Based Lineage.</td>
</tr>
<tr>
<td><code>global.datahub.enableGraphDiffMode</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Enable diff mode for graph writes, producing incremental relationship changes instead of wholesale deletions.</td>
</tr>
<tr>
<td><code>global.datahub.strictUrnValidation</code></td>
<td>boolean</td>
<td><code>false</code></td>
<td>Enable stricter URN validation logic for metadata entities.</td>
</tr>
<tr>
<td><code>global.datahub.search_and_browse.show_search_v2</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Show the new search filters experience as of v0.10.5.</td>
</tr>
<tr>
<td><code>global.datahub.search_and_browse.show_browse_v2</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Show the new browse experience as of v0.10.5.</td>
</tr>
<tr>
<td><code>global.datahub.search_and_browse.backfill_browse_v2</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Run the backfill upgrade job that generates default browse paths for relevant entities.</td>
</tr>
<tr>
<td><code>global.datahub.metadataChangeProposal.consumer.batch.enabled</code></td>
<td>boolean</td>
<td><code>false</code></td>
<td>Enable batch processing for metadata change proposal consumers.</td>
</tr>
<tr>
<td><code>global.datahub.mcp.throttle.mceConsumer.enabled</code></td>
<td>boolean</td>
<td><code>false</code></td>
<td>Enable throttling for MCE consumer processing.</td>
</tr>
<tr>
<td><code>global.datahub.mcp.throttle.apiRequests.enabled</code></td>
<td>boolean</td>
<td><code>false</code></td>
<td>Enable throttling for API requests.</td>
</tr>
<tr>
<td><code>global.datahub.mcp.throttle.versioned.enabled</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Enable throttling for versioned metadata change log processing.</td>
</tr>
<tr>
<td><code>global.datahub.mcp.throttle.timeseries.enabled</code></td>
<td>boolean</td>
<td><code>false</code></td>
<td>Enable throttling for timeseries metadata change log processing.</td>
</tr>
<tr>
<td><code>global.datahub.entityVersioning.enabled</code></td>
<td>boolean</td>
<td><code>false</code></td>
<td>Enable entity versioning capabilities.</td>
</tr>
<tr>
<td><code>global.datahub.preProcessHooksUIEnabled</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Enable fast path for processing UI-sourced events with synchronous index updates.</td>
</tr>
<tr>
<td><code>global.datahub.reProcessUIEventHooks</code></td>
<td>boolean</td>
<td><code>false</code></td>
<td>Reprocess UI events at MAE Consumer. Not required when preprocess is enabled.</td>
</tr>
</tbody>
</table>

## datahub-gms Subchart Values

<table>
<thead>
<tr>
<th>Configuration Path</th>
<th>Type</th>
<th>Default</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>datahub-gms.enabled</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Enable GMS (General Metadata Service) deployment.</td>
</tr>
<tr>
<td><code>datahub-gms.image.repository</code></td>
<td>string</td>
<td><code>acryldata/datahub-gms</code></td>
<td>Docker image repository for GMS service.</td>
</tr>
<tr>
<td><code>datahub-gms.image.tag</code></td>
<td>string</td>
<td><code></code></td>
<td>Docker image tag for GMS service. Defaults to global.datahub.version if not specified.</td>
</tr>
<tr>
<td><code>datahub-gms.resources.limits.memory</code></td>
<td>string</td>
<td><code>2Gi</code></td>
<td>Memory limit for GMS pods.</td>
</tr>
<tr>
<td><code>datahub-gms.resources.requests.cpu</code></td>
<td>string</td>
<td><code>100m</code></td>
<td>CPU request for GMS pods.</td>
</tr>
<tr>
<td><code>datahub-gms.resources.requests.memory</code></td>
<td>string</td>
<td><code>1Gi</code></td>
<td>Memory request for GMS pods.</td>
</tr>
<tr>
<td><code>datahub-gms.livenessProbe.initialDelaySeconds</code></td>
<td>integer</td>
<td><code>60</code></td>
<td>Initial delay before starting liveness probe checks.</td>
</tr>
<tr>
<td><code>datahub-gms.livenessProbe.periodSeconds</code></td>
<td>integer</td>
<td><code>30</code></td>
<td>How often to perform liveness probe checks.</td>
</tr>
<tr>
<td><code>datahub-gms.livenessProbe.failureThreshold</code></td>
<td>integer</td>
<td><code>8</code></td>
<td>Number of consecutive failures before restarting the pod.</td>
</tr>
<tr>
<td><code>datahub-gms.readinessProbe.initialDelaySeconds</code></td>
<td>integer</td>
<td><code>120</code></td>
<td>Initial delay before starting readiness probe checks.</td>
</tr>
<tr>
<td><code>datahub-gms.readinessProbe.periodSeconds</code></td>
<td>integer</td>
<td><code>30</code></td>
<td>How often to perform readiness probe checks.</td>
</tr>
<tr>
<td><code>datahub-gms.readinessProbe.failureThreshold</code></td>
<td>integer</td>
<td><code>8</code></td>
<td>Number of consecutive failures before marking pod as not ready.</td>
</tr>
<tr>
<td><code>datahub-gms.theme_v2.enabled</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Enable theme V2 for GMS service.</td>
</tr>
<tr>
<td><code>datahub-gms.theme_v2.default</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Set theme V2 as default for GMS service.</td>
</tr>
<tr>
<td><code>datahub-gms.theme_v2.toggeable</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Allow toggling between theme versions.</td>
</tr>
<tr>
<td><code>datahub-gms.service.type</code></td>
<td>string</td>
<td><code>LoadBalancer</code></td>
<td>Service type for GMS (LoadBalancer, ClusterIP, or NodePort).</td>
</tr>
<tr>
<td><code>datahub-gms.sql.datasource.username</code></td>
<td>string</td>
<td><code>gms-login</code></td>
<td>GMS-specific SQL login username.</td>
</tr>
<tr>
<td><code>datahub-gms.sql.datasource.password.secretRef</code></td>
<td>string</td>
<td><code>gms-secret</code></td>
<td>Secret reference for GMS-specific SQL password.</td>
</tr>
<tr>
<td><code>datahub-gms.sql.datasource.password.secretKey</code></td>
<td>string</td>
<td><code>gms-password</code></td>
<td>Secret key for GMS-specific SQL password.</td>
</tr>
</tbody>
</table>

## datahub-frontend Subchart Values

<table>
<thead>
<tr>
<th>Configuration Path</th>
<th>Type</th>
<th>Default</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>datahub-frontend.enabled</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Enable frontend deployment.</td>
</tr>
<tr>
<td><code>datahub-frontend.replicaCount</code></td>
<td>integer</td>
<td><code>1</code></td>
<td>Number of frontend replicas to deploy.</td>
</tr>
<tr>
<td><code>datahub-frontend.hpa.enabled</code></td>
<td>boolean</td>
<td><code>false</code></td>
<td>Enable Horizontal Pod Autoscaler for automatic scaling.</td>
</tr>
<tr>
<td><code>datahub-frontend.hpa.minReplicas</code></td>
<td>integer</td>
<td><code>2</code></td>
<td>Minimum number of replicas when HPA is enabled.</td>
</tr>
<tr>
<td><code>datahub-frontend.hpa.maxReplicas</code></td>
<td>integer</td>
<td><code>3</code></td>
<td>Maximum number of replicas when HPA is enabled.</td>
</tr>
<tr>
<td><code>datahub-frontend.hpa.targetCPUUtilizationPercentage</code></td>
<td>integer</td>
<td><code>70</code></td>
<td>Target CPU utilization percentage for HPA scaling.</td>
</tr>
<tr>
<td><code>datahub-frontend.hpa.targetMemoryUtilizationPercentage</code></td>
<td>integer</td>
<td><code>70</code></td>
<td>Target memory utilization percentage for HPA scaling.</td>
</tr>
<tr>
<td><code>datahub-frontend.image.repository</code></td>
<td>string</td>
<td><code>acryldata/datahub-frontend-react</code></td>
<td>Docker image repository for frontend service.</td>
</tr>
<tr>
<td><code>datahub-frontend.image.tag</code></td>
<td>string</td>
<td><code></code></td>
<td>Docker image tag for frontend service. Defaults to global.datahub.version if not specified.</td>
</tr>
<tr>
<td><code>datahub-frontend.resources.limits.memory</code></td>
<td>string</td>
<td><code>1400Mi</code></td>
<td>Memory limit for frontend pods.</td>
</tr>
<tr>
<td><code>datahub-frontend.resources.requests.cpu</code></td>
<td>string</td>
<td><code>100m</code></td>
<td>CPU request for frontend pods.</td>
</tr>
<tr>
<td><code>datahub-frontend.resources.requests.memory</code></td>
<td>string</td>
<td><code>512Mi</code></td>
<td>Memory request for frontend pods.</td>
</tr>
<tr>
<td><code>datahub-frontend.ingress.enabled</code></td>
<td>boolean</td>
<td><code>false</code></td>
<td>Enable ingress for frontend service.</td>
</tr>
<tr>
<td><code>datahub-frontend.ingress.className</code></td>
<td>string</td>
<td><code></code></td>
<td>Ingress class name for frontend ingress.</td>
</tr>
<tr>
<td><code>datahub-frontend.ingress.hosts</code></td>
<td>array</td>
<td><code>[]</code></td>
<td>Host configurations for frontend ingress.</td>
</tr>
<tr>
<td><code>datahub-frontend.ingress.tls</code></td>
<td>array</td>
<td><code>[]</code></td>
<td>TLS configuration for frontend ingress.</td>
</tr>
<tr>
<td><code>datahub-frontend.defaultUserCredentials.randomAdminPassword</code></td>
<td>boolean</td>
<td><code>false</code></td>
<td>Generate random admin password for default users.</td>
</tr>
<tr>
<td><code>datahub-frontend.defaultUserCredentials.manualValues</code></td>
<td>string</td>
<td><code></code></td>
<td>Manual password values for default users.</td>
</tr>
<tr>
<td><code>datahub-frontend.service.type</code></td>
<td>string</td>
<td><code>LoadBalancer</code></td>
<td>Service type for frontend (LoadBalancer, ClusterIP, or NodePort).</td>
</tr>
<tr>
<td><code>datahub-frontend.service.extraLabels</code></td>
<td>object</td>
<td><code>{}</code></td>
<td>Extra labels for frontend service.</td>
</tr>
</tbody>
</table>

## acryl-datahub-actions Subchart Values

<table>
<thead>
<tr>
<th>Configuration Path</th>
<th>Type</th>
<th>Default</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>acryl-datahub-actions.enabled</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Enable DataHub actions deployment.</td>
</tr>
<tr>
<td><code>acryl-datahub-actions.image.repository</code></td>
<td>string</td>
<td><code>acryldata/datahub-actions</code></td>
<td>Docker image repository for actions service.</td>
</tr>
<tr>
<td><code>acryl-datahub-actions.image.tag</code></td>
<td>string</td>
<td><code></code></td>
<td>Docker image tag for actions service. Defaults to global.datahub.version if not specified.</td>
</tr>
<tr>
<td><code>acryl-datahub-actions.ingestionSecretFiles.name</code></td>
<td>string</td>
<td><code></code></td>
<td>Kubernetes secret name to mount as volume for ingestion secret files.</td>
</tr>
<tr>
<td><code>acryl-datahub-actions.ingestionSecretFiles.defaultMode</code></td>
<td>string</td>
<td><code>0444</code></td>
<td>Default file mode for mounted secret files.</td>
</tr>
<tr>
<td><code>acryl-datahub-actions.resources.limits.memory</code></td>
<td>string</td>
<td><code>512Mi</code></td>
<td>Memory limit for actions pods.</td>
</tr>
<tr>
<td><code>acryl-datahub-actions.resources.requests.cpu</code></td>
<td>string</td>
<td><code>300m</code></td>
<td>CPU request for actions pods.</td>
</tr>
<tr>
<td><code>acryl-datahub-actions.resources.requests.memory</code></td>
<td>string</td>
<td><code>256Mi</code></td>
<td>Memory request for actions pods.</td>
</tr>
</tbody>
</table>

## datahub-mae-consumer Subchart Values

<table>
<thead>
<tr>
<th>Configuration Path</th>
<th>Type</th>
<th>Default</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>datahub-mae-consumer.image.repository</code></td>
<td>string</td>
<td><code>acryldata/datahub-mae-consumer</code></td>
<td>Docker image repository for MAE consumer service.</td>
</tr>
<tr>
<td><code>datahub-mae-consumer.image.tag</code></td>
<td>string</td>
<td><code></code></td>
<td>Docker image tag for MAE consumer service. Defaults to global.datahub.version if not specified.</td>
</tr>
<tr>
<td><code>datahub-mae-consumer.resources.limits.memory</code></td>
<td>string</td>
<td><code>1536Mi</code></td>
<td>Memory limit for MAE consumer pods.</td>
</tr>
<tr>
<td><code>datahub-mae-consumer.resources.requests.cpu</code></td>
<td>string</td>
<td><code>100m</code></td>
<td>CPU request for MAE consumer pods.</td>
</tr>
<tr>
<td><code>datahub-mae-consumer.resources.requests.memory</code></td>
<td>string</td>
<td><code>256Mi</code></td>
<td>Memory request for MAE consumer pods.</td>
</tr>
</tbody>
</table>

## datahub-mce-consumer Subchart Values

<table>
<thead>
<tr>
<th>Configuration Path</th>
<th>Type</th>
<th>Default</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>datahub-mce-consumer.image.repository</code></td>
<td>string</td>
<td><code>acryldata/datahub-mce-consumer</code></td>
<td>Docker image repository for MCE consumer service.</td>
</tr>
<tr>
<td><code>datahub-mce-consumer.image.tag</code></td>
<td>string</td>
<td><code></code></td>
<td>Docker image tag for MCE consumer service. Defaults to global.datahub.version if not specified.</td>
</tr>
<tr>
<td><code>datahub-mce-consumer.resources.limits.memory</code></td>
<td>string</td>
<td><code>1536Mi</code></td>
<td>Memory limit for MCE consumer pods.</td>
</tr>
<tr>
<td><code>datahub-mce-consumer.resources.requests.cpu</code></td>
<td>string</td>
<td><code>100m</code></td>
<td>CPU request for MCE consumer pods.</td>
</tr>
<tr>
<td><code>datahub-mce-consumer.resources.requests.memory</code></td>
<td>string</td>
<td><code>256Mi</code></td>
<td>Memory request for MCE consumer pods.</td>
</tr>
</tbody>
</table>

## datahub-ingestion-cron Subchart Values

<table>
<thead>
<tr>
<th>Configuration Path</th>
<th>Type</th>
<th>Default</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>datahub-ingestion-cron.enabled</code></td>
<td>boolean</td>
<td><code>false</code></td>
<td>Enable ingestion cron job deployment.</td>
</tr>
<tr>
<td><code>datahub-ingestion-cron.image.repository</code></td>
<td>string</td>
<td><code>acryldata/datahub-ingestion</code></td>
<td>Docker image repository for ingestion cron job.</td>
</tr>
<tr>
<td><code>datahub-ingestion-cron.image.tag</code></td>
<td>string</td>
<td><code></code></td>
<td>Docker image tag for ingestion cron job. Defaults to global.datahub.version if not specified.</td>
</tr>
</tbody>
</table>

## Setup Jobs Configuration

### elasticsearchSetupJob

<table>
<thead>
<tr>
<th>Configuration Path</th>
<th>Type</th>
<th>Default</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>elasticsearchSetupJob.enabled</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Enable Elasticsearch setup job.</td>
</tr>
<tr>
<td><code>elasticsearchSetupJob.image.repository</code></td>
<td>string</td>
<td><code>acryldata/datahub-elasticsearch-setup</code></td>
<td>Docker image repository for Elasticsearch setup job.</td>
</tr>
<tr>
<td><code>elasticsearchSetupJob.image.tag</code></td>
<td>string</td>
<td><code></code></td>
<td>Docker image tag for Elasticsearch setup job. Defaults to global.datahub.version if not specified.</td>
</tr>
<tr>
<td><code>elasticsearchSetupJob.resources.limits.cpu</code></td>
<td>string</td>
<td><code>500m</code></td>
<td>CPU limit for Elasticsearch setup job.</td>
</tr>
<tr>
<td><code>elasticsearchSetupJob.resources.limits.memory</code></td>
<td>string</td>
<td><code>512Mi</code></td>
<td>Memory limit for Elasticsearch setup job.</td>
</tr>
<tr>
<td><code>elasticsearchSetupJob.resources.requests.cpu</code></td>
<td>string</td>
<td><code>300m</code></td>
<td>CPU request for Elasticsearch setup job.</td>
</tr>
<tr>
<td><code>elasticsearchSetupJob.resources.requests.memory</code></td>
<td>string</td>
<td><code>256Mi</code></td>
<td>Memory request for Elasticsearch setup job.</td>
</tr>
<tr>
<td><code>elasticsearchSetupJob.extraEnvs</code></td>
<td>array</td>
<td><code>[]</code></td>
<td>Extra environment variables for Elasticsearch setup job.</td>
</tr>
<tr>
<td><code>elasticsearchSetupJob.extraSidecars</code></td>
<td>array</td>
<td><code>[]</code></td>
<td>Extra sidecar containers for Elasticsearch setup job.</td>
</tr>
</tbody>
</table>

### kafkaSetupJob

<table>
<thead>
<tr>
<th>Configuration Path</th>
<th>Type</th>
<th>Default</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>kafkaSetupJob.enabled</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Enable Kafka setup job.</td>
</tr>
<tr>
<td><code>kafkaSetupJob.image.repository</code></td>
<td>string</td>
<td><code>acryldata/datahub-kafka-setup</code></td>
<td>Docker image repository for Kafka setup job.</td>
</tr>
<tr>
<td><code>kafkaSetupJob.image.tag</code></td>
<td>string</td>
<td><code></code></td>
<td>Docker image tag for Kafka setup job. Defaults to global.datahub.version if not specified.</td>
</tr>
<tr>
<td><code>kafkaSetupJob.resources.limits.cpu</code></td>
<td>string</td>
<td><code>500m</code></td>
<td>CPU limit for Kafka setup job.</td>
</tr>
<tr>
<td><code>kafkaSetupJob.resources.limits.memory</code></td>
<td>string</td>
<td><code>1024Mi</code></td>
<td>Memory limit for Kafka setup job.</td>
</tr>
<tr>
<td><code>kafkaSetupJob.resources.requests.cpu</code></td>
<td>string</td>
<td><code>300m</code></td>
<td>CPU request for Kafka setup job.</td>
</tr>
<tr>
<td><code>kafkaSetupJob.resources.requests.memory</code></td>
<td>string</td>
<td><code>768Mi</code></td>
<td>Memory request for Kafka setup job.</td>
</tr>
<tr>
<td><code>kafkaSetupJob.extraSidecars</code></td>
<td>array</td>
<td><code>[]</code></td>
<td>Extra sidecar containers for Kafka setup job.</td>
</tr>
</tbody>
</table>

### mysqlSetupJob

<table>
<thead>
<tr>
<th>Configuration Path</th>
<th>Type</th>
<th>Default</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>mysqlSetupJob.enabled</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Enable MySQL setup job.</td>
</tr>
<tr>
<td><code>mysqlSetupJob.image.repository</code></td>
<td>string</td>
<td><code>acryldata/datahub-mysql-setup</code></td>
<td>Docker image repository for MySQL setup job.</td>
</tr>
<tr>
<td><code>mysqlSetupJob.image.tag</code></td>
<td>string</td>
<td><code></code></td>
<td>Docker image tag for MySQL setup job. Defaults to global.datahub.version if not specified.</td>
</tr>
<tr>
<td><code>mysqlSetupJob.resources.limits.cpu</code></td>
<td>string</td>
<td><code>500m</code></td>
<td>CPU limit for MySQL setup job.</td>
</tr>
<tr>
<td><code>mysqlSetupJob.resources.limits.memory</code></td>
<td>string</td>
<td><code>512Mi</code></td>
<td>Memory limit for MySQL setup job.</td>
</tr>
<tr>
<td><code>mysqlSetupJob.resources.requests.cpu</code></td>
<td>string</td>
<td><code>300m</code></td>
<td>CPU request for MySQL setup job.</td>
</tr>
<tr>
<td><code>mysqlSetupJob.resources.requests.memory</code></td>
<td>string</td>
<td><code>256Mi</code></td>
<td>Memory request for MySQL setup job.</td>
</tr>
<tr>
<td><code>mysqlSetupJob.username</code></td>
<td>string</td>
<td><code>mysqlSetupJob-login</code></td>
<td>MySQL setup job specific username.</td>
</tr>
<tr>
<td><code>mysqlSetupJob.password.secretRef</code></td>
<td>string</td>
<td><code>mysqlSetupJob-secret</code></td>
<td>Secret reference for MySQL setup job password.</td>
</tr>
<tr>
<td><code>mysqlSetupJob.password.secretKey</code></td>
<td>string</td>
<td><code>mysqlSetupJob-password</code></td>
<td>Secret key for MySQL setup job password.</td>
</tr>
<tr>
<td><code>mysqlSetupJob.extraSidecars</code></td>
<td>array</td>
<td><code>[]</code></td>
<td>Extra sidecar containers for MySQL setup job.</td>
</tr>
</tbody>
</table>

### postgresqlSetupJob

<table>
<thead>
<tr>
<th>Configuration Path</th>
<th>Type</th>
<th>Default</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>postgresqlSetupJob.enabled</code></td>
<td>boolean</td>
<td><code>false</code></td>
<td>Enable PostgreSQL setup job.</td>
</tr>
<tr>
<td><code>postgresqlSetupJob.image.repository</code></td>
<td>string</td>
<td><code>acryldata/datahub-postgres-setup</code></td>
<td>Docker image repository for PostgreSQL setup job.</td>
</tr>
<tr>
<td><code>postgresqlSetupJob.image.tag</code></td>
<td>string</td>
<td><code></code></td>
<td>Docker image tag for PostgreSQL setup job. Defaults to global.datahub.version if not specified.</td>
</tr>
<tr>
<td><code>postgresqlSetupJob.resources.limits.cpu</code></td>
<td>string</td>
<td><code>500m</code></td>
<td>CPU limit for PostgreSQL setup job.</td>
</tr>
<tr>
<td><code>postgresqlSetupJob.resources.limits.memory</code></td>
<td>string</td>
<td><code>512Mi</code></td>
<td>Memory limit for PostgreSQL setup job.</td>
</tr>
<tr>
<td><code>postgresqlSetupJob.resources.requests.cpu</code></td>
<td>string</td>
<td><code>300m</code></td>
<td>CPU request for PostgreSQL setup job.</td>
</tr>
<tr>
<td><code>postgresqlSetupJob.resources.requests.memory</code></td>
<td>string</td>
<td><code>256Mi</code></td>
<td>Memory request for PostgreSQL setup job.</td>
</tr>
<tr>
<td><code>postgresqlSetupJob.username</code></td>
<td>string</td>
<td><code>postgresqlSetupJob-login</code></td>
<td>PostgreSQL setup job specific username.</td>
</tr>
<tr>
<td><code>postgresqlSetupJob.password.secretRef</code></td>
<td>string</td>
<td><code>postgresqlSetupJob-secret</code></td>
<td>Secret reference for PostgreSQL setup job password.</td>
</tr>
<tr>
<td><code>postgresqlSetupJob.password.secretKey</code></td>
<td>string</td>
<td><code>postgresqlSetupJob-password</code></td>
<td>Secret key for PostgreSQL setup job password.</td>
</tr>
<tr>
<td><code>postgresqlSetupJob.extraEnvs</code></td>
<td>array</td>
<td><code>[]</code></td>
<td>Extra environment variables for PostgreSQL setup job.</td>
</tr>
<tr>
<td><code>postgresqlSetupJob.extraSidecars</code></td>
<td>array</td>
<td><code>[]</code></td>
<td>Extra sidecar containers for PostgreSQL setup job.</td>
</tr>
</tbody>
</table>

## DataHub Upgrade Configuration

<table>
<thead>
<tr>
<th>Configuration Path</th>
<th>Type</th>
<th>Default</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>datahubUpgrade.enabled</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Enable DataHub upgrade job.</td>
</tr>
<tr>
<td><code>datahubUpgrade.image.repository</code></td>
<td>string</td>
<td><code>acryldata/datahub-upgrade</code></td>
<td>Docker image repository for upgrade job.</td>
</tr>
<tr>
<td><code>datahubUpgrade.image.tag</code></td>
<td>string</td>
<td><code></code></td>
<td>Docker image tag for upgrade job. Defaults to global.datahub.version if not specified.</td>
</tr>
<tr>
<td><code>datahubUpgrade.batchSize</code></td>
<td>integer</td>
<td><code>1000</code></td>
<td>Batch size for upgrade processing.</td>
</tr>
<tr>
<td><code>datahubUpgrade.batchDelayMs</code></td>
<td>integer</td>
<td><code>100</code></td>
<td>Delay between batches in milliseconds.</td>
</tr>
<tr>
<td><code>datahubUpgrade.restoreIndices.image.command</code></td>
<td>array</td>
<td><code>[]</code></td>
<td>Custom command for restore indices job.</td>
</tr>
<tr>
<td><code>datahubUpgrade.restoreIndices.image.args</code></td>
<td>array</td>
<td><code>[]</code></td>
<td>Custom arguments for restore indices job.</td>
</tr>
<tr>
<td><code>datahubUpgrade.restoreIndices.args.lePitEpochMs</code></td>
<td>string</td>
<td><code></code></td>
<td>Restore only rows with less than a certain epoch millisecond timestamp.</td>
</tr>
<tr>
<td><code>datahubUpgrade.restoreIndices.args.gePitEpochMs</code></td>
<td>string</td>
<td><code></code></td>
<td>Restore only rows with greater than a certain epoch millisecond timestamp.</td>
</tr>
<tr>
<td><code>datahubUpgrade.restoreIndices.args.lastUrn</code></td>
<td>string</td>
<td><code></code></td>
<td>Resume from a particular URN for urn-based pagination.</td>
</tr>
<tr>
<td><code>datahubUpgrade.restoreIndices.args.lastAspect</code></td>
<td>string</td>
<td><code></code></td>
<td>Resume from a particular aspect for urn-based pagination.</td>
</tr>
<tr>
<td><code>datahubUpgrade.restoreIndices.args.urnBasedPagination</code></td>
<td>boolean</td>
<td><code>false</code></td>
<td>Use key-based paging strategy instead of offset-based.</td>
</tr>
<tr>
<td><code>datahubUpgrade.restoreIndices.args.aspectNames</code></td>
<td>string</td>
<td><code></code></td>
<td>Comma-separated list of aspects to restore.</td>
</tr>
<tr>
<td><code>datahubUpgrade.restoreIndices.args.urnLike</code></td>
<td>string</td>
<td><code></code></td>
<td>SQL LIKE pattern for URN matching.</td>
</tr>
<tr>
<td><code>datahubUpgrade.restoreIndices.args.startingOffset</code></td>
<td>integer</td>
<td><code></code></td>
<td>Starting offset for default paging.</td>
</tr>
<tr>
<td><code>datahubUpgrade.restoreIndices.args.numThreads</code></td>
<td>integer</td>
<td><code></code></td>
<td>Number of threads for processing pages.</td>
</tr>
<tr>
<td><code>datahubUpgrade.restoreIndices.schedule</code></td>
<td>string</td>
<td><code>0 0 * * 0</code></td>
<td>Cron schedule for restore indices job.</td>
</tr>
<tr>
<td><code>datahubUpgrade.restoreIndices.concurrencyPolicy</code></td>
<td>string</td>
<td><code>Allow</code></td>
<td>Concurrency policy for restore indices job.</td>
</tr>
<tr>
<td><code>datahubUpgrade.restoreIndices.resources.limits.cpu</code></td>
<td>string</td>
<td><code>500m</code></td>
<td>CPU limit for restore indices job.</td>
</tr>
<tr>
<td><code>datahubUpgrade.restoreIndices.resources.limits.memory</code></td>
<td>string</td>
<td><code>512Mi</code></td>
<td>Memory limit for restore indices job.</td>
</tr>
<tr>
<td><code>datahubUpgrade.restoreIndices.resources.requests.cpu</code></td>
<td>string</td>
<td><code>300m</code></td>
<td>CPU request for restore indices job.</td>
</tr>
<tr>
<td><code>datahubUpgrade.restoreIndices.resources.requests.memory</code></td>
<td>string</td>
<td><code>256Mi</code></td>
<td>Memory request for restore indices job.</td>
</tr>
</tbody>
</table>

## DataHub System Update Configuration

<table>
<thead>
<tr>
<th>Configuration Path</th>
<th>Type</th>
<th>Default</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>datahubSystemUpdate.image.repository</code></td>
<td>string</td>
<td><code>acryldata/datahub-upgrade</code></td>
<td>Docker image repository for system update job.</td>
</tr>
<tr>
<td><code>datahubSystemUpdate.image.tag</code></td>
<td>string</td>
<td><code></code></td>
<td>Docker image tag for system update job. Defaults to global.datahub.version if not specified.</td>
</tr>
<tr>
<td><code>datahubSystemUpdate.nonblocking.enabled</code></td>
<td>boolean</td>
<td><code>true</code></td>
<td>Enable non-blocking system update job.</td>
</tr>
<tr>
<td><code>datahubSystemUpdate.bootstrapMCPs.default.value_configs</code></td>
<td>array</td>
<td><code>["datahub.bootstrapMCPs.default.ingestion.version", "datahub.bootstrapMCPs.default.schedule.timezone"]</code></td>
<td>Default MCP value configurations.</td>
</tr>
<tr>
<td><code>datahubSystemUpdate.bootstrapMCPs.datahubGC.dailyCronWindow.startHour</code></td>
<td>integer</td>
<td><code>18</code></td>
<td>Start hour for daily cron window.</td>
</tr>
<tr>
<td><code>datahubSystemUpdate.bootstrapMCPs.datahubGC.dailyCronWindow.endHour</code></td>
<td>integer</td>
<td><code>5</code></td>
<td>End hour for daily cron window.</td>
</tr>
<tr>
<td><code>datahubSystemUpdate.bootstrapMCPs.datahubGC.values.cleanup_expired_tokens</code></td>
<td>string</td>
<td><code>false</code></td>
<td>Clean up expired tokens.</td>
</tr>
<tr>
<td><code>datahubSystemUpdate.bootstrapMCPs.datahubGC.values.truncate_indices</code></td>
<td>string</td>
<td><code>true</code></td>
<td>Truncate indices during cleanup.</td>
</tr>
<tr>
<td><code>datahubSystemUpdate.bootstrapMCPs.datahubGC.values.truncate_indices_retention_days</code></td>
<td>integer</td>
<td><code>30</code></td>
<td>Retention days for truncated indices.</td>
</tr>
<tr>
<td><code>datahubSystemUpdate.bootstrapMCPs.datahubGC.values.dataprocess_cleanup.retention_days</code></td>
<td>integer</td>
<td><code>30</code></td>
<td>Retention days for data process cleanup.</td>
</tr>
<tr>
<td><code>datahubSystemUpdate.bootstrapMCPs.datahubGC.values.dataprocess_cleanup.delete_empty_data_jobs</code></td>
<td>string</td>
<td><code>true</code></td>
<td>Delete empty data jobs during cleanup.</td>
</tr>
<tr>
<td><code>datahubSystemUpdate.bootstrapMCPs.datahubGC.values.dataprocess_cleanup.delete_empty_data_flows</code></td>
<td>string</td>
<td><code>true</code></td>
<td>Delete empty data flows during cleanup.</td>
</tr>
<tr>
<td><code>datahubSystemUpdate.bootstrapMCPs.datahubGC.values.dataprocess_cleanup.hard_delete_entities</code></td>
<td>string</td>
<td><code>false</code></td>
<td>Hard delete entities during cleanup.</td>
</tr>
<tr>
<td><code>datahubSystemUpdate.bootstrapMCPs.datahubGC.values.dataprocess_cleanup.keep_last_n</code></td>
<td>integer</td>
<td><code>10</code></td>
<td>Keep last N entities during cleanup.</td>
</tr>
<tr>
<td><code>datahubSystemUpdate.bootstrapMCPs.datahubGC.values.soft_deleted_entities_cleanup.retention_days</code></td>
<td>integer</td>
<td><code>30</code></td>
<td>Retention days for soft deleted entities cleanup.</td>
</tr>
<tr>
<td><code>datahubSystemUpdate.resources.limits.cpu</code></td>
<td>string</td>
<td><code>500m</code></td>
<td>CPU limit for system update job.</td>
</tr>
<tr>
<td><code>datahubSystemUpdate.resources.limits.memory</code></td>
<td>string</td>
<td><code>2Gi</code></td>
<td>Memory limit for system update job.</td>
</tr>
<tr>
<td><code>datahubSystemUpdate.resources.requests.cpu</code></td>
<td>string</td>
<td><code>300m</code></td>
<td>CPU request for system update job.</td>
</tr>
<tr>
<td><code>datahubSystemUpdate.resources.requests.memory</code></td>
<td>string</td>
<td><code>2Gi</code></td>
<td>Memory request for system update job.</td>
</tr>
</tbody>
</table>

## DataHub System Cron Hourly Configuration

<table>
<thead>
<tr>
<th>Configuration Path</th>
<th>Type</th>
<th>Default</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>datahubSystemCronHourly.enabled</code></td>
<td>boolean</td>
<td><code>false</code></td>
<td>Enable hourly system cron job. Note: This feature is not ready yet, DO NOT enable.</td>
</tr>
<tr>
<td><code>datahubSystemCronHourly.image.repository</code></td>
<td>string</td>
<td><code>795586375822.dkr.ecr.us-west-2.amazonaws.com/datahub-upgrade</code></td>
<td>Docker image repository for hourly cron job.</td>
</tr>
<tr>
<td><code>datahubSystemCronHourly.image.tag</code></td>
<td>string</td>
<td><code></code></td>
<td>Docker image tag for hourly cron job. Defaults to global.datahub.version if not specified.</td>
</tr>
<tr>
<td><code>datahubSystemCronHourly.jvmOpts.XX</code></td>
<td>string</td>
<td><code>:+ExitOnOutOfMemoryError -XX:MaxRAMPercentage=75.0</code></td>
<td>JVM XX options for hourly cron job.</td>
</tr>
</tbody>
</table>

## Additional Configuration Options

### Host Aliases

<table>
<thead>
<tr>
<th>Configuration Path</th>
<th>Type</th>
<th>Default</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>hostAliases</code></td>
<td>array</td>
<td><code>[]</code></td>
<td>Custom host aliases for resolving hostnames to IP addresses.</td>
</tr>
</tbody>
</table>

### SSL Configuration for Kafka

<table>
<thead>
<tr>
<th>Configuration Path</th>
<th>Type</th>
<th>Default</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>credentialsAndCertsSecrets.name</code></td>
<td>string</td>
<td><code></code></td>
<td>Kubernetes secret name containing SSL certificates and credentials.</td>
</tr>
<tr>
<td><code>credentialsAndCertsSecrets.path</code></td>
<td>string</td>
<td><code>/mnt/datahub/certs</code></td>
<td>Path where SSL certificates are mounted in containers.</td>
</tr>
<tr>
<td><code>credentialsAndCertsSecrets.secureEnv.ssl.key.password</code></td>
<td>string</td>
<td><code></code></td>
<td>SSL key password environment variable.</td>
</tr>
<tr>
<td><code>credentialsAndCertsSecrets.secureEnv.ssl.keystore.password</code></td>
<td>string</td>
<td><code></code></td>
<td>SSL keystore password environment variable.</td>
</tr>
<tr>
<td><code>credentialsAndCertsSecrets.secureEnv.ssl.truststore.password</code></td>
<td>string</td>
<td><code></code></td>
<td>SSL truststore password environment variable.</td>
</tr>
<tr>
<td><code>springKafkaConfigurationOverrides.ssl.keystore.location</code></td>
<td>string</td>
<td><code></code></td>
<td>SSL keystore location path.</td>
</tr>
<tr>
<td><code>springKafkaConfigurationOverrides.ssl.truststore.location</code></td>
<td>string</td>
<td><code></code></td>
<td>SSL truststore location path.</td>
</tr>
<tr>
<td><code>springKafkaConfigurationOverrides.security.protocol</code></td>
<td>string</td>
<td><code></code></td>
<td>Kafka security protocol (SSL, SASL_SSL, etc.).</td>
</tr>
</tbody>
</table>
