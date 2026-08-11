#!/usr/bin/env python3
"""Benchmark verified final-build cache hits against ordinary cached compilation."""

from __future__ import annotations

import argparse
import json
import os
import shutil
import statistics
import subprocess
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TMP = ROOT / ".tmp" / "build-output-cache-benchmark"


def timed_build(
    source: Path, output: Path, cache: Path, *, disabled: bool
) -> float:
    command = [str(ROOT / "tools" / "dew"), "build"]
    if disabled:
        command.append("--no-build-cache")
    command.extend((str(source), "-o", str(output)))
    environment = os.environ.copy()
    environment["DEW_CACHE_DIR"] = str(cache)
    start = time.perf_counter()
    subprocess.run(
        command,
        cwd=ROOT,
        env=environment,
        check=True,
        stdout=subprocess.DEVNULL,
    )
    return (time.perf_counter() - start) * 1000


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--samples", type=int, default=10)
    args = parser.parse_args()
    if args.samples < 1:
        parser.error("samples must be positive")
    shutil.rmtree(TMP, ignore_errors=True)
    TMP.mkdir(parents=True)
    cache = TMP / "cache"
    source = TMP / "main.dew"
    source.write_text("pub fn main() -> I32 {\n  42\n}\n", encoding="utf-8")
    warm = TMP / "warm.wasm"
    timed_build(source, warm, cache, disabled=False)
    hit_times = [
        timed_build(source, TMP / f"hit-{index}.wasm", cache, disabled=False)
        for index in range(args.samples)
    ]
    uncached_times = [
        timed_build(source, TMP / f"uncached-{index}.wasm", cache, disabled=True)
        for index in range(args.samples)
    ]
    hit = statistics.median(hit_times)
    uncached = statistics.median(uncached_times)
    outputs_identical = all(
        path.read_bytes() == warm.read_bytes()
        for path in TMP.glob("*.wasm")
    )
    artifacts = list((cache / "builds").glob("v1-*.dba"))
    print(json.dumps({
        "samples": args.samples,
        "cache_hit_median_ms": round(hit, 3),
        "uncached_compile_median_ms": round(uncached, 3),
        "hit_to_uncached_ratio": round(hit / uncached, 4),
        "outputs_byte_identical": outputs_identical,
        "verified_build_artifacts": len(artifacts),
        "wasm_bytes": warm.stat().st_size,
    }, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
