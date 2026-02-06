# CLAUDE.md - DataHub Helm Chart

## values.yaml Naming Conventions

The `global` section in `charts/datahub/values.yaml` follows a two-tier naming convention:

### Infrastructure backends — directly under `global`

External infrastructure dependencies that DataHub connects to are placed directly
under `global.*`:

- `global.elasticsearch` — Elasticsearch/OpenSearch cluster configuration
- `global.kafka` — Kafka broker and topic configuration
- `global.neo4j` — Neo4j graph database configuration
- `global.sql` — SQL database (MySQL/PostgreSQL) configuration

### DataHub application features — under `global.datahub`

Configuration for DataHub application behavior and features lives under
`global.datahub.*`:

- `global.datahub.gms` — GMS service settings
- `global.datahub.monitoring` — Prometheus/monitoring settings
- `global.datahub.managed_ingestion` — UI ingestion feature
- `global.datahub.metadata_service_authentication` — Auth configuration
- `global.datahub.search_and_browse` — Search UI feature flags
- `global.datahub.semantic_search` — Semantic/vector search configuration
- `global.datahub.mcp` — Metadata Change Proposal throttling
- `global.datahub.encryptionKey` — Encryption key provisioning

### Rule of thumb

If the config describes *how to connect to an external system*, put it under
`global.<system>`. If the config describes *a DataHub feature or behavior*,
put it under `global.datahub.<feature>`.
