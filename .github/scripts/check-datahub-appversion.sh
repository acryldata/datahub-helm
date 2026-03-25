#!/usr/bin/env bash
# Ensures every charts/datahub/subcharts/*/Chart.yaml appVersion matches
# charts/datahub/Chart.yaml (single source of truth for the DataHub release).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PARENT="$ROOT/charts/datahub/Chart.yaml"

app_version() {
  ruby -ryaml -e 'puts YAML.load_file(ARGV[0])["appVersion"].to_s' "$1"
}

EXPECTED="$(app_version "$PARENT")"
if [[ -z "$EXPECTED" || "$EXPECTED" == "" ]]; then
  echo "error: missing appVersion in $PARENT" >&2
  exit 1
fi

ERR=0
for chart in "$ROOT"/charts/datahub/subcharts/*/Chart.yaml; do
  ACT="$(app_version "$chart")"
  if [[ "$ACT" != "$EXPECTED" ]]; then
    rel="${chart#"$ROOT"/}"
    echo "error: $rel has appVersion '$ACT', expected '$EXPECTED' (from charts/datahub/Chart.yaml)" >&2
    ERR=1
  fi
done

if [[ "$ERR" -ne 0 ]]; then
  echo >&2
  echo "hint: set appVersion to '$EXPECTED' in each subchart Chart.yaml listed above." >&2
fi
exit "$ERR"
