#!/usr/bin/env python3
"""Measure deterministic type-layout and WasmGC-fragment cache costs."""

from __future__ import annotations

import json
import os
import shutil
import statistics
import subprocess
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WORK = ROOT / ".tmp" / "planning-cache-benchmark"
CACHE = WORK / "cache"
TYPE_COUNT = 512
FUNCTION_COUNT = 512


def write_source() -> Path:
    source = WORK / "main.dew"
    lines: list[str] = []
    for index in range(TYPE_COUNT):
        lines.extend(
            (
                f"struct Item_{index} {{",
                "  value: I32",
                "  next: I64",
                "}",
            )
        )
    for index in range(FUNCTION_COUNT):
        lines.extend(
            (
                f"fn value_{index}(input: I32) -> I32 {{",
                f"  input + {index}",
                "}",
            )
        )
    lines.extend(("pub fn main() -> I32 {", "  value_511(1)", "}"))
    source.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return source


def command(source: Path, *, enabled: bool) -> list[str]:
    return [
        str(ROOT / "tools" / "dew"),
        "check",
        "--bootstrap-std",
        "--no-parse-event-cache",
        "--no-interface-cache",
        "--no-body-cache",
        "--plan-cache" if enabled else "--no-plan-cache",
        "--cache-report",
        str(source),
    ]


def run(source: Path, *, enabled: bool) -> tuple[float, str]:
    environment = os.environ.copy()
    environment["DEW_CACHE_DIR"] = str(CACHE)
    environment["DEW_CACHE_PACK"] = "0"
    environment["DEW_PROGRAM_CACHE"] = "0"
    started = time.perf_counter()
    completed = subprocess.run(
        command(source, enabled=enabled),
        cwd=ROOT,
        env=environment,
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    return (time.perf_counter() - started) * 1000, completed.stdout


def status(report: str) -> str:
    return next(
        line
        for line in report.splitlines()
        if line.startswith("layout and fragment cache:")
    )


def main() -> None:
    shutil.rmtree(WORK, ignore_errors=True)
    WORK.mkdir(parents=True)
    source = write_source()
    cold_ms, cold_report = run(source, enabled=True)
    warm_samples: list[float] = []
    warm_report = ""
    for _ in range(7):
        elapsed, warm_report = run(source, enabled=True)
        warm_samples.append(elapsed)
    uncached_samples: list[float] = []
    for _ in range(7):
        elapsed, _ = run(source, enabled=False)
        uncached_samples.append(elapsed)
    warm_status = status(warm_report)
    if "layout misses 0" not in warm_status or "fragment misses 0" not in warm_status:
        raise RuntimeError(f"unexpected warm planning cache status: {warm_status}")
    layout_files = list((CACHE / "type-layouts").glob("v1-*.dtl"))
    fragment_files = list((CACHE / "wasmgc-fragments").glob("v1-*.dwf"))
    result = {
        "types": TYPE_COUNT,
        "functions": FUNCTION_COUNT,
        "cold_ms": round(cold_ms, 3),
        "warm_median_ms": round(statistics.median(warm_samples), 3),
        "uncached_median_ms": round(statistics.median(uncached_samples), 3),
        "warm_to_uncached_ratio": round(
            statistics.median(warm_samples) / statistics.median(uncached_samples),
            4,
        ),
        "cold_status": status(cold_report),
        "warm_status": warm_status,
        "layout_artifacts": len(layout_files),
        "layout_artifact_bytes": sum(path.stat().st_size for path in layout_files),
        "fragment_artifacts": len(fragment_files),
        "fragment_artifact_bytes": sum(
            path.stat().st_size for path in fragment_files
        ),
    }
    print(json.dumps(result, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
