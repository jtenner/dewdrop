#!/usr/bin/env python3
"""Measure module and declaration-family body-inference reuse."""

from __future__ import annotations

import json
import os
import re
import shutil
import statistics
import subprocess
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WORK = ROOT / ".tmp" / "body-inference-cache-benchmark"
CACHE = WORK / "cache"
FUNCTION_COUNT = 192


def write_sources() -> tuple[Path, Path]:
    sources = WORK / "sources"
    sources.mkdir(parents=True, exist_ok=True)
    library = sources / "library.dew"
    lines = ["pub fn base(value: I32) -> I32 {", "  value + 1", "}"]
    for index in range(FUNCTION_COUNT):
        lines.extend(
            (
                f"fn private_{index:03d}(value: I32) -> I32 {{",
                f"  value + {index}",
                "}",
            )
        )
    lines.extend(("pub fn answer() -> I32 {", "  base(41)", "}"))
    library.write_text("\n".join(lines) + "\n", encoding="utf-8")
    root = sources / "main.dew"
    root.write_text(
        "open bench.library\npub fn main() -> I32 {\n  answer()\n}\n",
        encoding="utf-8",
    )
    return library, root


def command(library: Path, root: Path, output: Path, *, body_cache: bool = True) -> list[str]:
    result = [
        str(ROOT / "tools" / "dew"),
        "build",
        "--no-build-cache",
        "--cache-report",
    ]
    if body_cache:
        result.append("--body-family-cache")
    else:
        result.append("--no-body-cache")
    result.extend(("--module", "bench.library", str(library)))
    result.extend(("--module", "bench.main", str(root)))
    result.extend(("--root", "bench.main", "-o", str(output)))
    return result


def run_build(library: Path, root: Path, output: Path, *, body_cache: bool = True) -> tuple[float, str]:
    environment = os.environ.copy()
    environment["DEW_CACHE_DIR"] = str(CACHE)
    started = time.perf_counter()
    completed = subprocess.run(
        command(library, root, output, body_cache=body_cache),
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
    library, root = write_sources()
    cold_ms, cold_report = run_build(library, root, WORK / "cold.wasm")
    warm_samples: list[float] = []
    warm_report = ""
    for index in range(5):
        elapsed, warm_report = run_build(library, root, WORK / f"warm-{index}.wasm")
        warm_samples.append(elapsed)
    text = library.read_text(encoding="utf-8")
    library.write_text(text.replace("value + 191", "value + 190", 1), encoding="utf-8")
    private_ms, private_report = run_build(library, root, WORK / "private.wasm")
    private_status = next(
        line for line in private_report.splitlines() if line.startswith("body inference cache:")
    )
    match = re.fullmatch(
        r"body inference cache: module hits (\d+), module misses (\d+), "
        r"family hits (\d+), family misses (\d+)",
        private_status,
    )
    if match is None:
        raise RuntimeError(f"unexpected body-cache status: {private_status}")
    module_hits, module_misses, family_hits, family_misses = map(int, match.groups())
    if module_misses != 2 or family_hits != FUNCTION_COUNT + 2 or family_misses != 1:
        raise RuntimeError(
            "private edit did not isolate one declaration family: "
            f"{private_status}"
        )
    private_uncached_samples: list[float] = []
    for index in range(3):
        elapsed, _ = run_build(
            library,
            root,
            WORK / f"private-uncached-{index}.wasm",
            body_cache=False,
        )
        private_uncached_samples.append(elapsed)
    if (WORK / "private.wasm").read_bytes() != (
        WORK / "private-uncached-2.wasm"
    ).read_bytes():
        raise RuntimeError("family-cached private edit differs from uncached output")
    root.write_text(
        "open bench.library\npub fn main() -> I32 {\n  answer() + 0\n}\n",
        encoding="utf-8",
    )
    root_ms, root_report = run_build(library, root, WORK / "root.wasm")
    run_build(library, root, WORK / "root-uncached.wasm", body_cache=False)
    if (WORK / "root.wasm").read_bytes() != (WORK / "root-uncached.wasm").read_bytes():
        raise RuntimeError("body-cached output differs from uncached output")
    result = {
        "private_functions": FUNCTION_COUNT,
        "cold_ms": round(cold_ms, 3),
        "warm_median_ms": round(statistics.median(warm_samples), 3),
        "private_body_change_ms": round(private_ms, 3),
        "private_body_change_uncached_median_ms": round(
            statistics.median(private_uncached_samples), 3
        ),
        "root_body_change_ms": round(root_ms, 3),
        "cold_report": cold_report.strip().splitlines(),
        "warm_report": warm_report.strip().splitlines(),
        "private_body_change_report": private_report.strip().splitlines(),
        "private_body_change_module_hits": module_hits,
        "private_body_change_module_misses": module_misses,
        "private_body_change_family_hits": family_hits,
        "private_body_change_family_misses": family_misses,
        "root_body_change_report": root_report.strip().splitlines(),
        "module_artifacts": len(list((CACHE / "body-inference").glob("v1-*.dbi"))),
        "family_artifacts": len(
            list((CACHE / "body-inference-families").glob("v1-*.dbf"))
        ),
        "module_artifact_bytes": sum(
            path.stat().st_size
            for path in (CACHE / "body-inference").glob("v1-*.dbi")
        ),
        "family_artifact_bytes": sum(
            path.stat().st_size
            for path in (CACHE / "body-inference-families").glob("v1-*.dbf")
        ),
        "changed_output_matches_uncached": True,
    }
    print(json.dumps(result, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
