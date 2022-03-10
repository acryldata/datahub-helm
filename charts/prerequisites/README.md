DataHub Prerequisites
=======
A Helm chart for installing components required to run LinkedIn DataHub

## Install Prerequisites
Run the following command to install datahub with default configuration.

```
helm repo add datahub https://helm.datahubproject.io
helm install datahub datahub/datahub-prerequisites
```

If the default configuration is not applicable, you can update the values listed below in a `values.yaml` file and run
```
helm install datahub datahub/datahub-prerequisites --values <<path-to-values-file>>
```