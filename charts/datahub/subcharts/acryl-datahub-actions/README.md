acryl-datahub-actions
================
A Helm chart for acryl-datahub-actions

Current chart version is `0.0.3`

## Chart Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| exporters.jmx.enabled | boolean | false |  |
| extraLabels | object | `{}` | Extra labels for deployment configuration |
| extraEnvs | Extra [environment variables][] which will be appended to the `env:` definition for the container | `[]` |
| extraSidecars | list | `[]` | Add additional sidecar containers to the deployment pod(s) |
| extraVolumes | Templatable string of additional `volumes` to be passed to the `tpl` function | "" |
| extraVolumeMounts | Templatable string of additional `volumeMounts` to be passed to the `tpl` function | "" |
| fullnameOverride | string | `"acryl-datahub-actions"` |  |
| global.datahub.gms.port | string | `"8080"` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"acryldata/datahub-actions"` |  |
| image.tag | string | `"v0.0.6"` |  |
| imagePullSecrets | list | `[]` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| securityContext | object | `{}` |  |
| service.port | int | `9093` |  |
| service.nodePort | int | `""` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.name | string | `nil` |  |
| tolerations | list | `[]` |  |
| global.kafka.bootstrap.server  | string | `nil` |  |
| global.kafka.schemaregistry.url | string | `nil` |  |
| actions.kafkaAutoOffsetPolicy | string | `"latest"` |  |
| datahub.metadata_service_authentication.enabled | bool | `false` | Whether Metadata Service Authentication is enabled. |
| global.datahub.metadata_service_authentication.systemClientId | string | `"__datahub_system"` | The internal system id that is used to communicate with DataHub GMS. Required if metadata_service_authentication is 'true'. |
| global.datahub.metadata_service_authentication.systemClientSecret.secretRef | string | `nil` | The reference to a secret containing the internal system secret that is used to communicate with DataHub GMS. Required if metadata_service_authentication is 'true'. |
| global.datahub.metadata_service_authentication.systemClientSecret.secretKey | string | `nil` | The key of a secret containing the internal system secret that is used to communicate with DataHub GMS. Required if metadata_service_authentication is 'true'. |
| ingestionSecretFiles.name | string | `""` | Name of the k8s secret that holds any secret files (e.g., SSL certificates and private keys) that are used in your ingestion recipes. The keys in the secret will be mounted as individual files under `/etc/datahub/ingestion-secret-files` |
| ingestionSecretFiles.defaultMode | string | `""` | The permission mode for the volume that mounts k8s secret under `/etc/datahub/ingestion-secret-files`, default value is 0444 which allows read access by owner, group, and other users |
