datahub-gms
===========
A Helm chart for LinkedIn DataHub's datahub-gms component

Current chart version is `0.2.0`

## Chart Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| extraLabels | object | `{}` | Extra labels for deployment configuration |
| extraEnvs | Extra [environment variables][] which will be appended to the `env:` definition for the container | `[]` |
| extraSidecars | list | `[]` | Add additional sidecar containers to the deployment pod(s) |
| extraVolumes | Templatable string of additional `volumes` to be passed to the `tpl` function | "" |
| extraVolumeMounts | Templatable string of additional `volumeMounts` to be passed to the `tpl` function | "" |
| fullnameOverride | string | `"datahub-gms-deployment"` |  |
| global.datahub.appVersion | string | `"1.0"` |  |
| global.datahub.gms.port | string | `"8080"` |  |
| global.datahub.gms.nodePort | string | `""` |  |
| global.elasticsearch.host | string | `"elasticsearch"` |  |
| global.elasticsearch.port | string | `"9200"` |  |
| global.hostAliases[0].hostnames[0] | string | `"broker"` |  |
| global.hostAliases[0].hostnames[1] | string | `"mysql"` |  |
| global.hostAliases[0].hostnames[2] | string | `"elasticsearch"` |  |
| global.hostAliases[0].hostnames[3] | string | `"neo4j"` |  |
| global.hostAliases[0].ip | string | `"192.168.0.104"` |  |
| global.kafka.bootstrap.server | string | `"broker:9092"` |  |
| global.kafka.schemaregistry.url | string | `"http://schema-registry:8081"` |  |
| global.neo4j.host | string | `"neo4j:7474"` |  |
| global.neo4j.uri | string | `"bolt://neo4j"` |  |
| global.neo4j.username | string | `"neo4j"` |  |
| global.neo4j.password.secretRef | string | `"neo4j-secrets"` |  |
| global.neo4j.password.secretKey | string | `"neo4j-password"` |  |
| global.sql.datasource.driver | string | `"com.mysql.cj.jdbc.Driver"` |  |
| global.sql.datasource.host | string | `"mysql"` |  |
| global.sql.datasource.url | string | `"jdbc:mysql://mysql:3306/datahub?verifyServerCertificate=false\u0026useSSL=true"` |  |
| global.sql.datasource.username | string | `"datahub"` |  |
| global.sql.datasource.password.secretRef | string | `"mysql-secrets"` |  |
| global.sql.datasource.password.secretKey | string | `"mysql-password"` |  |
| global.graph_service_impl | string | `neo4j` | One of `neo4j` or `elasticsearch`. Determines which backend to use for the GMS graph service. Elastic is recommended for a simplified deployment. Neo4j will be the default for now to maintain backwards compatibility |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"linkedin/datahub-gms"` |  |
| image.tag | string | `"head"` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.enabled | bool | `false` |  |
| ingress.extraLabels | object | `{}` | provides extra labels for ingress configuration |
| ingress.hosts[0].host | string | `"chart-example.local"` |  |
| ingress.hosts[0].paths | list | `[]` |  |
| ingress.tls | list | `[]` |  |
| livenessProbe.initialDelaySeconds | int | `60` |  |
| livenessProbe.periodSeconds | int | `30` |  |
| livenessProbe.failureThreshold | int | `8` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| readinessProbe.initialDelaySeconds | int | `60` |  |
| readinessProbe.periodSeconds | int | `30` |  |
| readinessProbe.failureThreshold | int | `8` |  |
| replicaCount | int | `1` |  |
| revisionHistoryLimit | int | `10` |  |
| resources | object | `{}` |  |
| securityContext | object | `{}` |  |
| service.port | int | `8080` |  |
| service.type | string | `"LoadBalancer"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `nil` |  |
| serviceMonitor.create | bool | `false` | If set true and `global.datahub.monitoring.enablePrometheus` is set `true` it will create a ServiceMonitor resource |
| tolerations | list | `[]` |  |
| global.datahub.metadata_service_authentication.enabled | bool | `false` | Whether Metadata Service Authentication is enabled. |
| global.datahub.metadata_service_authentication.systemClientId | string | `"__datahub_system"` | The internal system id that is used to communicate with DataHub GMS. Required if metadata_service_authentication is 'true'. |
| global.datahub.metadata_service_authentication.systemClientSecret.secretRef | string | `nil` | The reference to a secret containing the internal system secret that is used to communicate with DataHub GMS. Required if metadata_service_authentication is 'true'. |
| global.datahub.metadata_service_authentication.systemClientSecret.secretKey | string | `nil` | The key of a secret containing the internal system secret that is used to communicate with DataHub GMS. Required if metadata_service_authentication is 'true'. |
| global.datahub.metadata_service_authentication.tokenService.signingKey.secretRef | string | `nil` | The reference to a secret containing the internal system secret that is used to sign JWT auth tokens issued by DataHub GMS. |
| global.datahub.metadata_service_authentication.tokenService.signingKey.secretKey | string | `nil` | The key of a secret containing the internal system secret that is used to sign JWT auth tokens issued by DataHub GMS. |
| global.datahub.metadata_service_authentication.tokenService.salt.secretRef | string | `nil` | The reference to a secret containing the internal system salt that is used to salt JWT auth tokens signatures issued by DataHub GMS that is part of the metadata graph. |
| global.datahub.metadata_service_authentication.tokenService.salt.secretKey | string | `nil` | The key of a secret containing the internal system secret that is used to to salt JWT auth tokens signatures issued by DataHub GMS that is part of the metadata graph. |
| global.datahub.managed_ingestion.enabled | bool | `true` | Whether or not UI-based ingestion experience is enabled. |
| global.datahub.encryptionKey.secretRef | string | `nil` | The reference to a secret containing an alpha-numeric encryption key, which is used to encrypt Secrets on DataHub. Required if managed_ingestion_enabled is 'true'. |
| global.datahub.encryptionKey.secretKey | string | `nil` | The key of a secret containing an alpha-numeric encryption key, which is used to encrypt Secrets on DataHub. Required if managed_ingestion_enabled is 'true'. |
| global.datahub.managed_ingestion.defaultCliVersion | string | `0.11.0` | This is the version of the DataHub CLI to use for UI ingestion, by default. You do not need to explicitly provide this. By default the underlying datahub-gms container will provide a latest version compatible with the server. |
| global.datahub.enable_retention | bool | `false` | Whether or not to enable retention on local DB |
