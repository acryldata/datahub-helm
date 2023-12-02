#!/bin/zsh

rm -rf out

helm dependency update charts/datahub
helm template datahub charts/datahub \
  --output-dir out \
  --values ../datahub/deployment/charts/datahub/values-rendered.yaml \
  --kube-context data-dev-iad-2 \
  --set datahub-gms.image.tag="${GIT_COMMIT}" \
  --set datahub-frontend.image.tag="${GIT_COMMIT}" \
  --set datahubUpgrade.image.tag="${GIT_COMMIT}" \
  --set datahubSystemUpdate.image.tag="${GIT_COMMIT}" \
  --debug