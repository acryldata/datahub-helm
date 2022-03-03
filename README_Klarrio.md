# datahub-helm-fork
# What is it?
`datahub-helm-fork` is our own fork of the datahub-helm repo in which all the necessary helm charts are contained to start
up your own DataHub cluster. In order to allow integration with our TLS enabled Strimzi cluster modifications 
were necessary to the deployment manifests of the charts. Besides this the JMX Exporter has been enabled and Prometheus
metric scraping has been enabled via pod annotations (prometheus.io/port & prometheus.io/scrape).

# Details
## Kafka Configuration
In order to connect with Kafka two important configurations should be set: the bootstrap servers to connect to and
the TLS configuration. The bootstrap servers should be set in two locations: 
- in the values.yaml file of `charts/datahub` under `global.kafka.bootstrap.server`
- in the values.yaml file of `charts/prerequisites` under `cp-helm-charts/cp-schema-registry/kafka/bootstrapServers`

As for the TLS configuration, this needs to be set in the file `charts/datahub/values.yaml` under the sections
`credentialsAndCertsSecrets` and `springKafkaConfigurationOverrides`.

### credentialsAndCertsSecrets
These configs specify the secrets on the K8s cluster containing the truststore and keystore certificates. In our case
Strimzi automatically creates a secret containing all keystore information and a secret containing all truststore information.
Alongside the secret one also needs to define the mount path and which of the keys in the secrets are used for the password.

### springKafkaConfigurationOverrides
These configs specify the actual kafka configs, including the truststore and keystore files, the types of the stores and
the security protocol.

## Prometheus
To enable metric exporting the `global.datahub.monitoring.enablePrometheus` flag in the values.yaml file of the GMS
container should be set to true. Once this is done all the metrics are exported on port 4318 and scraping can be 
facilitated via pod annotations. Currently the configuration is setting the following two annotations which are
picked up by Prometheus:

```
prometheus.io/port: "4318"
prometheus.io/scrape: "true"
```

# Deploy
In order to deploy a version of DataHub to your kubernetes cluster, first change your working directory to `charts/datahub`.
Next build the dependencies via

`helm dependency build`

or if you've already build them and made a modification to any of the manifests do instead 

`helm dependency update`

Afterwards you can simply install the helm charts to your K8s cluster via 

`helm install datahub ./ --values values.yaml -n <namespace of kafka cluster>`
