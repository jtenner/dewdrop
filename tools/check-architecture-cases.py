#!/usr/bin/env python3
"""Run declarative ABI performance and WAT architecture assertions."""

from __future__ import annotations

import argparse
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CASES = ROOT / "tests" / "architecture-cases.json"


def run_performance(cases: list[dict[str, object]]) -> None:
    for case in cases:
        label = str(case["label"])
        command = [
            "node",
            "tools/wasm-metrics.mjs",
            str(case["wat"]),
            str(case["artifact"]),
            str(case["budget"]),
        ]
        result = subprocess.run(command, cwd=ROOT, check=False, capture_output=True)
        if result.returncode != 0:
            raise SystemExit(
                f"{label} performance case failed:\n{result.stderr.decode(errors='replace')}"
            )
        report = ROOT / str(case["report"])
        report.parent.mkdir(parents=True, exist_ok=True)
        report.write_bytes(result.stdout)
        consumer = case.get("consumer")
        if isinstance(consumer, dict):
            invocation = consumer.get("invocation", [])
            if not isinstance(invocation, list):
                raise SystemExit(f"{label} consumer invocation must be an array")
            consumed = subprocess.run(
                [
                    "node",
                    "tools/dew-wasm-consumer.mjs",
                    str(case["artifact"]),
                    str(consumer["artifact"]),
                    *(str(value) for value in invocation),
                ],
                cwd=ROOT,
                check=False,
                capture_output=True,
            )
            output = consumed.stdout.decode(errors="replace")
            if consumed.returncode != 0 or str(consumer["expected"]) not in output:
                raise SystemExit(
                    f"{label} consumer case failed:\n"
                    f"{consumed.stderr.decode(errors='replace')}{output}"
                )
        print(f"checked architecture performance case: {label}")


def run_wat(cases: list[dict[str, object]]) -> None:
    for case in cases:
        label = str(case["label"])
        text = (ROOT / str(case["wat"])).read_text(encoding="utf-8")
        for pattern in case.get("forbidden", []):
            if str(pattern) in text:
                raise SystemExit(f"{label} retained forbidden WAT: {pattern}")
        for pattern in case.get("required", []):
            if str(pattern) not in text:
                raise SystemExit(f"{label} lost required WAT: {pattern}")
        counts = case.get("counts", {})
        if not isinstance(counts, dict):
            raise SystemExit(f"{label} WAT counts must be an object")
        for pattern, expected in counts.items():
            actual = text.count(pattern)
            if actual != expected:
                raise SystemExit(
                    f"{label} WAT count changed for {pattern}: "
                    f"expected {expected}, got {actual}"
                )
        print(f"checked architecture WAT case: {label}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--performance", action="store_true")
    parser.add_argument("--wat", action="store_true")
    args = parser.parse_args()
    if not args.performance and not args.wat:
        args.performance = args.wat = True
    data = json.loads(CASES.read_text(encoding="utf-8"))
    if args.performance:
        run_performance(data["performanceCases"])
    if args.wat:
        run_wat(data["watCases"])


if __name__ == "__main__":
    main()
