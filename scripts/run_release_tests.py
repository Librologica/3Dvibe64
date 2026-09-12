#!/usr/bin/env python3
"""Run public contracts in independent clean SDK copies; never write into the SDK."""
import argparse
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import time

ROOT = Path(__file__).resolve().parents[1]
TESTS = (
    "test_release_contract.py", "test_world_metrics.py", "test_gouraud_mode6.py",
    "test_optimization_gate1_lut.py", "test_optimization_gate3_span.py",
    "test_optimization_gate4_division.py", "test_mobile_yq2.py",
    "test_camera_move_step.py", "test_camera_angular_repeat.py",
    "test_object_depth_domain.py", "test_gouraud_mode6_emulators.py",
    "test_dev7_text_split.py", "test_mode7.py",
)

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("tests", nargs="*", help="Optional test filenames; omit to run all")
    args = parser.parse_args()
    unknown = set(args.tests) - set(TESTS)
    if unknown:
        parser.error("Unknown tests: " + ", ".join(sorted(unknown)))
    env = os.environ.copy()
    env["PYTHONDONTWRITEBYTECODE"] = "1"
    failures = []
    for name in args.tests or TESTS:
        started = time.monotonic()
        print(f"START {name}", flush=True)
        with tempfile.TemporaryDirectory(prefix="3dvibe64-release-test-") as temporary:
            sdk = Path(temporary) / "sdk"
            shutil.copytree(ROOT, sdk, ignore=shutil.ignore_patterns("__pycache__"))
            result = subprocess.run([sys.executable, "-B", str(sdk / "scripts" / name)], cwd=sdk, env=env)
        print(f"{'PASS' if result.returncode == 0 else 'FAIL'} {name} elapsed={time.monotonic()-started:.1f}s", flush=True)
        if result.returncode:
            failures.append(name)
    if failures:
        raise SystemExit("Failed: " + ", ".join(failures))
    print("RELEASE PUBLIC TESTS: PASS", flush=True)

if __name__ == "__main__":
    main()
