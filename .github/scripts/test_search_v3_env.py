"""
Search V3 entity index flags must reach every entity-index writer with the same values.

Checks:
- each entityIndex.mode preset renders the expected flags on GMS, the MAE and MCE consumers, and
  both system-update jobs
- ELASTICSEARCH_ENTITY_INDEX_V3_CUTOVER_ACKNOWLEDGED is false unless cutoverAcknowledged is set;
  no mode turns it on, and an explicit value is emitted as-is
- semanticReadEnabled fails the render

Run from repo root: python3 .github/scripts/test_search_v3_env.py
Requires: helm CLI; chart deps available (helm dependency build charts/datahub).
"""

from __future__ import annotations

import subprocess
import sys
import tempfile
from typing import Dict, List, Optional, Tuple

import yaml

CHART_PATH = "charts/datahub"
VALUES_FILE = "charts/datahub/values.yaml"
RELEASE_NAME = "t"

BASE_SET_FLAGS = [
    "--set",
    "global.enableServiceLinks=false",
    "--set",
    "global.kafka.bootstrap.server=kafka:9092",
    "--set",
    "global.sql.datasource.host=mysql",
    "--set",
    "global.elasticsearch.host=elasticsearch",
    "--set",
    "global.datahub_standalone_consumers_enabled=true",
]

WRITERS = (
    ("Deployment", f"{RELEASE_NAME}-datahub-gms"),
    ("Deployment", f"{RELEASE_NAME}-datahub-mae-consumer"),
    ("Deployment", f"{RELEASE_NAME}-datahub-mce-consumer"),
    ("Job", f"{RELEASE_NAME}-system-update"),
    ("Job", f"{RELEASE_NAME}-system-update-nonblk"),
)

V2 = "ELASTICSEARCH_ENTITY_INDEX_V2_ENABLED"
V3 = "ELASTICSEARCH_ENTITY_INDEX_V3_ENABLED"
KEYWORD = "ELASTICSEARCH_ENTITY_INDEX_V3_KEYWORD_READ_ENABLED"
CUTOVER = "ELASTICSEARCH_ENTITY_INDEX_V3_CUTOVER_ACKNOWLEDGED"

Workload = Tuple[str, str]


def _helm_template(entity_index: Optional[Dict]) -> subprocess.CompletedProcess:
    values = {"global": {"elasticsearch": {"entityIndex": entity_index or {}}}}
    with tempfile.NamedTemporaryFile("w", suffix=".yaml") as handle:
        yaml.safe_dump(values, handle)
        handle.flush()
        cmd = ["helm", "template", RELEASE_NAME, CHART_PATH, "-f", VALUES_FILE, "-f", handle.name]
        return subprocess.run(cmd + BASE_SET_FLAGS, capture_output=True, text=True)


def _render(entity_index: Optional[Dict] = None) -> Dict[Workload, Dict[str, object]]:
    result = _helm_template(entity_index)
    if result.returncode != 0:
        raise RuntimeError(f"helm template failed:\n{result.stderr}")
    found: Dict[Workload, Dict[str, object]] = {}
    for doc in yaml.safe_load_all(result.stdout):
        if not doc or doc.get("kind") not in ("Deployment", "Job"):
            continue
        env: Dict[str, object] = {}
        for container in doc["spec"]["template"]["spec"].get("containers") or []:
            for item in container.get("env") or []:
                env[item["name"]] = item.get("value", item.get("valueFrom"))
        found[(doc["kind"], doc["metadata"]["name"])] = env
    return found


def _check_flags(
    envs: Dict[Workload, Dict[str, object]], v2: bool, v3: bool, keyword: bool, cutover: bool = False
) -> List[str]:
    problems = []
    for workload in WRITERS:
        env = envs.get(workload)
        if env is None:
            problems.append(f"{workload}: not rendered")
            continue
        for name, want in {V2: v2, V3: v3, KEYWORD: keyword, CUTOVER: cutover}.items():
            got = env.get(name)
            if got != str(want).lower():
                problems.append(f"{workload} {name}: expected {str(want).lower()!r}, got {got!r}")
    return problems


def _assert_no_problems(problems: List[str], context: str) -> None:
    assert not problems, f"{context}:\n  " + "\n  ".join(problems)


def test_default_mode_keeps_v2() -> None:
    _assert_no_problems(_check_flags(_render(), True, False, False), "default (v2)")


def test_migrate_mode_dual_writes() -> None:
    _assert_no_problems(_check_flags(_render({"mode": "migrate"}), True, True, False), "migrate")


def test_v3_mode_does_not_acknowledge_cutover() -> None:
    _assert_no_problems(_check_flags(_render({"mode": "v3"}), False, True, True), "v3")


def test_cutover_acknowledged_true_is_emitted_without_keyword_read() -> None:
    envs = _render({"mode": "v3", "keywordReadEnabled": False, "cutoverAcknowledged": True})
    _assert_no_problems(
        _check_flags(envs, False, True, False, cutover=True),
        "v3 with keyword read off and cutoverAcknowledged true",
    )


def test_cutover_acknowledged_false_is_emitted() -> None:
    envs = _render({"mode": "v3", "cutoverAcknowledged": False})
    _assert_no_problems(_check_flags(envs, False, True, True), "v3 with cutoverAcknowledged false")


def test_semantic_read_enabled_fails_render() -> None:
    result = _helm_template({"semanticReadEnabled": True})
    assert result.returncode != 0, "semanticReadEnabled rendered instead of failing"
    assert "semanticReadEnabled was removed" in result.stderr, result.stderr


def main() -> int:
    tests = [
        test_default_mode_keeps_v2,
        test_migrate_mode_dual_writes,
        test_v3_mode_does_not_acknowledge_cutover,
        test_cutover_acknowledged_true_is_emitted_without_keyword_read,
        test_cutover_acknowledged_false_is_emitted,
        test_semantic_read_enabled_fails_render,
    ]
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
