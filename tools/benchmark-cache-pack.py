#!/usr/bin/env python3
"""Compare unified cache-pack warm startup with legacy files and fresh work."""

from __future__ import annotations

import json
import os
import shutil
import statistics
import subprocess
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WORK = ROOT / ".tmp" / "cache-pack-benchmark"
MODULE_COUNT = 100
SAMPLES = 7


def write_modules() -> list[tuple[str, Path]]:
    modules: list[tuple[str, Path]] = []
    source_root = WORK / "sources"
    source_root.mkdir(parents=True)
    for index in range(MODULE_COUNT):
        name = f"bench.m{index:03d}"
        path = source_root / f"m{index:03d}.dew"
        lines: list[str] = []
        if index:
            lines.append(f"open bench.m{index - 1:03d}")
        lines.extend(
            (
                f"struct Item_{index} {{",
                "  value: I32",
                "  next: I64",
                "}",
                f"pub fn value_{index}() -> I32 {{",
                f"  {'value_' + str(index - 1) + '() + 1' if index else '0'}",
                "}",
            )
        )
        path.write_text("\n".join(lines) + "\n", encoding="utf-8")
        modules.append((name, path))
    return modules


def command(modules: list[tuple[str, Path]], mode: str) -> list[str]:
    result = [str(ROOT / "tools" / "dew"), "check", "--cache-report"]
    if mode == "pack-exact":
        result.extend(("--body-cache", "--plan-cache"))
    elif mode == "pack-phase":
        result.extend(("--body-cache", "--plan-cache", "--no-program-cache"))
    elif mode == "legacy-phase":
        result.extend(
            (
                "--body-cache",
                "--plan-cache",
                "--no-program-cache",
                "--no-cache-pack",
            )
        )
    elif mode == "disabled":
        result.extend(
            (
                "--no-program-cache",
                "--no-cache-pack",
                "--no-parse-event-cache",
                "--no-interface-cache",
                "--no-body-cache",
                "--no-plan-cache",
            )
        )
    else:
        raise ValueError(mode)
    for name, path in modules:
        result.extend(("--module", name, str(path)))
    result.extend(("--root", modules[-1][0]))
    return result


def run(modules: list[tuple[str, Path]], mode: str, cache: Path) -> tuple[float, str]:
    environment = os.environ.copy()
    environment["DEW_CACHE_DIR"] = str(cache)
    started = time.perf_counter()
    completed = subprocess.run(
        command(modules, mode),
        cwd=ROOT,
        env=environment,
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    return (time.perf_counter() - started) * 1000, completed.stdout


def benchmark(modules: list[tuple[str, Path]], mode: str) -> dict[str, object]:
    cache = WORK / mode
    shutil.rmtree(cache, ignore_errors=True)
    cold_ms, cold_report = run(modules, mode, cache)
    samples: list[float] = []
    warm_report = ""
    for _ in range(SAMPLES):
        elapsed, warm_report = run(modules, mode, cache)
        samples.append(elapsed)
    files = [path for path in cache.rglob("*") if path.is_file()]
    return {
        "cold_ms": round(cold_ms, 3),
        "warm_median_ms": round(statistics.median(samples), 3),
        "warm_min_ms": round(min(samples), 3),
        "cache_files": len(files),
        "cache_bytes": sum(path.stat().st_size for path in files),
        "cold_report": cold_report.strip().splitlines(),
        "warm_report": warm_report.strip().splitlines(),
    }


def main() -> None:
    shutil.rmtree(WORK, ignore_errors=True)
    WORK.mkdir(parents=True)
    modules = write_modules()
    results = {
        mode: benchmark(modules, mode)
        for mode in ("pack-exact", "pack-phase", "legacy-phase", "disabled")
    }
    exact = float(results["pack-exact"]["warm_median_ms"])
    legacy = float(results["legacy-phase"]["warm_median_ms"])
    fresh = float(results["disabled"]["warm_median_ms"])
    results["comparison"] = {
        "pack_exact_vs_legacy_ratio": round(exact / legacy, 4),
        "pack_exact_vs_fresh_ratio": round(exact / fresh, 4),
        "pack_exact_vs_legacy_percent": round((exact / legacy - 1.0) * 100.0, 2),
        "pack_exact_vs_fresh_percent": round((exact / fresh - 1.0) * 100.0, 2),
    }
    print(json.dumps(results, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
