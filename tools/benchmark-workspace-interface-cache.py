#!/usr/bin/env python3
"""Measure cold, warm, private-change, and public-change workspace interface reuse."""

from __future__ import annotations

import json
import os
import shutil
import statistics
import subprocess
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WORK = ROOT / ".tmp" / "workspace-interface-cache-benchmark"
CACHE = WORK / "cache"
MODULE_COUNT = 96


def write_sources() -> tuple[list[tuple[str, Path]], Path]:
    sources = WORK / "sources"
    sources.mkdir(parents=True, exist_ok=True)
    modules: list[tuple[str, Path]] = []
    for index in range(MODULE_COUNT):
        path = sources / f"module_{index:03d}.dew"
        if index == 0:
            text = "pub fn value_000() -> I32 {\n  0\n}\n"
        else:
            text = (
                f"open bench.module_{index - 1:03d}\n"
                f"pub fn value_{index:03d}() -> I32 {{\n"
                f"  value_{index - 1:03d}() + 1\n"
                "}\n"
            )
        path.write_text(text, encoding="utf-8")
        modules.append((f"bench.module_{index:03d}", path))
    root = sources / "main.dew"
    root.write_text(
        f"open bench.module_{MODULE_COUNT - 1:03d}\n"
        "pub fn main() -> I32 {\n"
        f"  value_{MODULE_COUNT - 1:03d}()\n"
        "}\n",
        encoding="utf-8",
    )
    return modules, root


def command(
    modules: list[tuple[str, Path]],
    root: Path,
    output: Path,
    *,
    interface_cache: bool = True,
) -> list[str]:
    result = [
        str(ROOT / "tools" / "dew"),
        "build",
        "--no-build-cache",
        "--cache-report",
    ]
    if not interface_cache:
        result.append("--no-interface-cache")
    for name, path in modules:
        result.extend(("--module", name, str(path)))
    result.extend(("--module", "bench.main", str(root)))
    result.extend(("--root", "bench.main", "-o", str(output)))
    return result


def run_build(
    modules: list[tuple[str, Path]],
    root: Path,
    output: Path,
    *,
    interface_cache: bool = True,
) -> tuple[float, str]:
    environment = os.environ.copy()
    environment["DEW_CACHE_DIR"] = str(CACHE)
    started = time.perf_counter()
    completed = subprocess.run(
        command(modules, root, output, interface_cache=interface_cache),
        cwd=ROOT,
        env=environment,
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    return (time.perf_counter() - started) * 1000, completed.stdout


def main() -> None:
    shutil.rmtree(WORK, ignore_errors=True)
    WORK.mkdir(parents=True)
    modules, root = write_sources()
    cold_ms, cold_report = run_build(modules, root, WORK / "cold.wasm")
    warm_samples = []
    warm_report = ""
    for index in range(5):
        elapsed, warm_report = run_build(modules, root, WORK / f"warm-{index}.wasm")
        warm_samples.append(elapsed)
    modules[0][1].write_text(
        "fn private_marker() -> I32 {\n  1\n}\n"
        "pub fn value_000() -> I32 {\n  0\n}\n",
        encoding="utf-8",
    )
    private_ms, private_report = run_build(modules, root, WORK / "private.wasm")
    modules[0][1].write_text(
        "pub fn value_000() -> I32 {\n  0\n}\n"
        "pub fn added() -> I32 {\n  1\n}\n",
        encoding="utf-8",
    )
    public_ms, public_report = run_build(modules, root, WORK / "public.wasm")
    run_build(
        modules,
        root,
        WORK / "public-uncached.wasm",
        interface_cache=False,
    )
    if (WORK / "public.wasm").read_bytes() != (WORK / "public-uncached.wasm").read_bytes():
        raise RuntimeError("public-change cached output differs from uncached output")
    modules[0][1].write_text(
        "fn private_marker() -> I32 {\n  1\n}\n"
        "pub fn value_000() -> I32 {\n  0\n}\n",
        encoding="utf-8",
    )
    run_build(
        modules,
        root,
        WORK / "private-uncached.wasm",
        interface_cache=False,
    )
    if (WORK / "private.wasm").read_bytes() != (WORK / "private-uncached.wasm").read_bytes():
        raise RuntimeError("private-change cached output differs from uncached output")
    result = {
        "workspace_modules": MODULE_COUNT,
        "cold_ms": round(cold_ms, 3),
        "warm_median_ms": round(statistics.median(warm_samples), 3),
        "private_change_ms": round(private_ms, 3),
        "public_change_ms": round(public_ms, 3),
        "cold_report": cold_report.strip().splitlines(),
        "warm_report": warm_report.strip().splitlines(),
        "private_change_report": private_report.strip().splitlines(),
        "public_change_report": public_report.strip().splitlines(),
        "workspace_artifacts": len(
            list((CACHE / "workspace-interfaces").glob("v1-*.dwi"))
        ),
        "changed_outputs_match_uncached": True,
    }
    print(json.dumps(result, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
