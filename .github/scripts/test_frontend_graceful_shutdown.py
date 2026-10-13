"""
Validate datahub-frontend graceful-shutdown env gating via local helm renders.

FRONTEND_WAIT_BEFORE_TERMINATION and FRONTEND_SERVER_TERMINATION_TIMEOUT are
emitted only when datahub-frontend.gracefulshutdownEnabled is true. The app
honors those variables whatever the flag says, so this template gate is the
only thing that keeps a flag-off pod from waiting 20s on stop.

The four phase env vars and the preStop sleep are always present. With the
flag off, the service-requests-done phase is the drain after SIGTERM.

Run from repo root: python3 .github/scripts/test_frontend_graceful_shutdown.py
Requires: helm CLI; chart deps available (helm dependency update charts/datahub).
"""

from __future__ import annotations

import json
import re
import subprocess
import sys
from typing import Dict, List

CHART_PATH = "charts/datahub"
VALUES_FILE = "charts/datahub/values.yaml"
RELEASE_NAME = "frontend-shutdown-test"
FRONTEND_DEPLOYMENT = f"{RELEASE_NAME}-datahub-frontend"

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

ALWAYS_PRESENT = {
    "FRONTEND_GRACEFUL_SHUTDOWN_ENABLED": None,
    "FRONTEND_BEFORE_SERVICE_UNBIND_TIMEOUT": "5s",
    "FRONTEND_SERVICE_REQUESTS_DONE_TIMEOUT": "55s",
    "FRONTEND_SERVICE_STOP_TIMEOUT": "10s",
}

FLAG_GATED = (
    "FRONTEND_WAIT_BEFORE_TERMINATION",
    "FRONTEND_SERVER_TERMINATION_TIMEOUT",
)


def _ensure_deps() -> None:
    result = subprocess.run(
        ["helm", "dependency", "update", CHART_PATH],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        raise RuntimeError(f"helm dependency update failed:\n{result.stderr}")


def _render(extra_set_flags: List[str] | None = None) -> str:
    cmd = [
        "helm",
        "template",
        RELEASE_NAME,
        CHART_PATH,
        "-f",
        VALUES_FILE,
        *BASE_SET_FLAGS,
        *(extra_set_flags or []),
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError(f"helm template failed:\n{result.stderr}\n{result.stdout}")
    return result.stdout


def _frontend_deployment(manifest: str) -> str:
    for doc in re.split(r"(?m)^---\s*$", manifest):
        if not doc.strip():
            continue
        header = "\n".join(doc.splitlines()[:16])
        kind = re.search(r"(?m)^kind:\s*(\S+)", header)
        name = re.search(r"(?m)^  name:\s*(\S+)", header)
        if kind and name and kind.group(1) == "Deployment" and name.group(1) == FRONTEND_DEPLOYMENT:
            return doc
    raise AssertionError(f"Deployment not rendered: {FRONTEND_DEPLOYMENT}")


def _env_values(doc: str) -> Dict[str, str]:
    values = {}
    for match in re.finditer(r"(?m)^\s*- name: ([A-Z0-9_]+)\n\s+value: (.*)$", doc):
        raw = match.group(2).strip()
        if raw.startswith('"') and raw.endswith('"'):
            values[match.group(1)] = json.loads(raw)
        elif raw.startswith("'") and raw.endswith("'"):
            values[match.group(1)] = raw[1:-1]
        else:
            values[match.group(1)] = raw
    return values


def _assert_common(env: Dict[str, str], doc: str) -> None:
    for key, expected in ALWAYS_PRESENT.items():
        assert key in env, key
        if expected is not None:
            assert env[key] == expected, (key, env[key])
    assert "sleep 20" in doc


def test_flag_off_omits_wait_and_termination_timeout() -> None:
    doc = _frontend_deployment(_render())
    env = _env_values(doc)
    _assert_common(env, doc)
    assert env["FRONTEND_GRACEFUL_SHUTDOWN_ENABLED"] == "false"
    for key in FLAG_GATED:
        assert key not in env, key


def test_flag_on_emits_wait_and_termination_timeout() -> None:
    doc = _frontend_deployment(_render(["--set", "datahub-frontend.gracefulshutdownEnabled=true"]))
    env = _env_values(doc)
    _assert_common(env, doc)
    assert env["FRONTEND_GRACEFUL_SHUTDOWN_ENABLED"] == "true"
    assert env["FRONTEND_WAIT_BEFORE_TERMINATION"] == "20s"
    assert env["FRONTEND_SERVER_TERMINATION_TIMEOUT"] == "30s"


def main() -> int:
    _ensure_deps()
    tests = [
        test_flag_off_omits_wait_and_termination_timeout,
        test_flag_on_emits_wait_and_termination_timeout,
    ]
    failed = 0
    for test in tests:
        try:
            test()
            print(f"PASS {test.__name__}")
        except Exception as exc:  # noqa: BLE001 — surface helm/assert failures
            failed += 1
            print(f"FAIL {test.__name__}: {exc}", file=sys.stderr)
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
