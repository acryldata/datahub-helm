"""
Numeric secondary search cluster settings must render when they are 0.

datahub.elasticsearch.clusters.env used to gate numShards, numReplicas, dataNodeCount and threadCount
with "with", which drops 0. numReplicas: 0 is the normal setting for a single-node OpenSearch 3 cluster,
so the app would silently fall back to its default replica count and leave new indices yellow.

Checks:
- explicit 0 renders as "0" for each numeric secondary setting on GMS
- unset numeric settings are not rendered

Run from repo root: python3 .github/scripts/test_search_v3_numeric_zero.py
Requires: helm CLI; chart deps available (helm dependency build charts/datahub).
"""

from __future__ import annotations

import subprocess
import sys
import tempfile

import yaml

CHART_PATH = "charts/datahub"
VALUES_FILE = "charts/datahub/values.yaml"
RELEASE_NAME = "numeric-zero-test"
GMS_DEPLOYMENT = f"{RELEASE_NAME}-datahub-gms"

BASE_SET_FLAGS = [
    "--set",
    "global.enableServiceLinks=false",
    "--set",
    "global.kafka.bootstrap.server=kafka:9092",
    "--set",
    "global.sql.datasource.host=mysql",
    "--set",
    "global.elasticsearch.host=elasticsearch",
]

NUMERIC_ENV = {
    "numShards": "ELASTICSEARCH_CLUSTERS_SECONDARY_NUM_SHARDS",
    "numReplicas": "ELASTICSEARCH_CLUSTERS_SECONDARY_NUM_REPLICAS",
    "dataNodeCount": "ELASTICSEARCH_CLUSTERS_SECONDARY_DATA_NODE_COUNT",
    "threadCount": "ELASTICSEARCH_CLUSTERS_SECONDARY_THREAD_COUNT",
}


def _gms_env(secondary: dict) -> dict:
    values = {
        "global": {
            "elasticsearch": {
                "clusters": {"secondary": {"enabled": True, "host": "opensearch3-cluster-master", **secondary}}
            }
        }
    }
    with tempfile.NamedTemporaryFile("w", suffix=".yaml") as handle:
        yaml.safe_dump(values, handle)
        handle.flush()
        cmd = ["helm", "template", RELEASE_NAME, CHART_PATH, "-f", VALUES_FILE, "-f", handle.name]
        result = subprocess.run(cmd + BASE_SET_FLAGS, capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError(f"helm template failed:\n{result.stderr}")
    for doc in yaml.safe_load_all(result.stdout):
        if doc and doc.get("kind") == "Deployment" and doc["metadata"]["name"] == GMS_DEPLOYMENT:
            env = doc["spec"]["template"]["spec"]["containers"][0]["env"]
            return {item["name"]: item.get("value") for item in env}
    raise AssertionError(f"{GMS_DEPLOYMENT} not rendered")


def test_explicit_zero_numeric_settings_render() -> None:
    env = _gms_env({key: 0 for key in NUMERIC_ENV})
    problems = [
        f"{var}: expected '0', got {env.get(var)!r}"
        for var in NUMERIC_ENV.values()
        if env.get(var) != "0"
    ]
    assert not problems, "explicit zero dropped:\n  " + "\n  ".join(problems)


def test_unset_numeric_settings_are_omitted() -> None:
    env = _gms_env({})
    leaked = [var for var in NUMERIC_ENV.values() if var in env]
    assert not leaked, f"unset numeric settings rendered: {leaked}"


def main() -> int:
    tests = [test_explicit_zero_numeric_settings_render, test_unset_numeric_settings_are_omitted]
    failed = 0
    for test in tests:
        try:
            test()
            print(f"PASS {test.__name__}")
        except Exception as exc:
            failed += 1
            print(f"FAIL {test.__name__}: {exc}")
    if failed:
        print(f"{failed}/{len(tests)} failed")
        return 1
    print(f"All {len(tests)} passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
