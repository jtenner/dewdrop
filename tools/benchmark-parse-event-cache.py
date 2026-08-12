#!/usr/bin/env python3
"""Measure cold, warm, and one-file-changed parse-event cache builds."""

from __future__ import annotations

import os
import shutil
import statistics
import subprocess
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WORK = ROOT / ".tmp" / "parse-event-cache-benchmark"
CACHE = WORK / "cache"


def write_sources(file_count: int = 128) -> list[Path]:
    sources = WORK / "sources"
    sources.mkdir(parents=True, exist_ok=True)
    paths: list[Path] = []
    for index in range(file_count):
        path = sources / f"file_{index:03d}.dew"
        path.write_text(
            f"fn value_{index:03d}() -> I32 {{\n  {index}\n}}\n",
            encoding="utf-8",
        )
        paths.append(path)
    paths[0].write_text(
        "pub fn run() -> I32 {\n  value_127()\n}\n",
        encoding="utf-8",
    )
    return paths


def run_build(paths: list[Path], output: Path) -> tuple[float, str]:
    command = [
        str(ROOT / "tools" / "dew"),
        "build",
        "--no-build-cache",
        "--no-interface-cache",
        "--cache-report",
        *map(str, paths),
        "-o",
        str(output),
    ]
    environment = os.environ.copy()
    environment["DEW_CACHE_DIR"] = str(CACHE)
    started = time.perf_counter()
    completed = subprocess.run(
        command,
        cwd=ROOT,
        env=environment,
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    return time.perf_counter() - started, completed.stdout


def median_warm(paths: list[Path], count: int = 7) -> float:
    samples = []
    for index in range(count):
        elapsed, output = run_build(paths, WORK / f"warm-{index}.wasm")
        if "parse event cache: hits " not in output or ", misses 0" not in output:
            raise RuntimeError(f"unexpected warm cache report:\n{output}")
        samples.append(elapsed)
    return statistics.median(samples)


def main() -> None:
    shutil.rmtree(WORK, ignore_errors=True)
    WORK.mkdir(parents=True)
    paths = write_sources()
    cold, cold_report = run_build(paths, WORK / "cold.wasm")
    warm = median_warm(paths)
    paths[-1].write_text(paths[-1].read_text(encoding="utf-8") + "\n", encoding="utf-8")
    changed, changed_report = run_build(paths, WORK / "changed.wasm")
    if "misses 1" not in changed_report:
        raise RuntimeError(f"unexpected changed-file cache report:\n{changed_report}")
    if (WORK / "cold.wasm").read_bytes() != (WORK / "changed.wasm").read_bytes():
        raise RuntimeError("unchanged-semantic changed-file output is not byte-identical")
    print(cold_report.strip())
    print(changed_report.strip())
    print(f"cold: {cold * 1000:.3f} ms")
    print(f"warm median: {warm * 1000:.3f} ms")
    print(f"changed-file: {changed * 1000:.3f} ms")
    print(f"warm/cold: {warm / cold:.4f}x")


if __name__ == "__main__":
    main()
