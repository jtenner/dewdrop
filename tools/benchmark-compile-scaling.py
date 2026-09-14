#!/usr/bin/env python3
"""Compare two built Dew JavaScript compilers and require equal Wasm output."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import statistics
import subprocess
import time
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("before", type=Path)
    parser.add_argument("after", type=Path)
    parser.add_argument("--runs", type=int, default=5)
    parser.add_argument("--modules", type=int, default=128)
    parser.add_argument("--cache-mode", choices=("off", "warm"), default="off")
    args = parser.parse_args()
    if args.runs < 1 or args.modules < 1:
        parser.error("runs and modules must be positive")
    work = ROOT / ".tmp" / "compile-scaling"
    work.mkdir(parents=True, exist_ok=True)
    module_args = []
    for i in range(args.modules):
        source = work / f"module_{i}.dew"
        dependency = f"open bench.module_{i - 1}\n" if i else ""
        body = f"call_{i - 1}()" if i else "42"
        source.write_text(
            dependency + f"pub fn call_{i}() -> I32 {{\n  {body}\n}}\n"
        )
        module_args.extend(["--module", f"bench.module_{i}", str(source)])
    environment = os.environ.copy()
    environment.update(DEW_REPOSITORY_ROOT=str(ROOT), DEW_WORKING_DIRECTORY=str(ROOT))
    for cache in ("PROGRAM", "PARSE_EVENT", "INTERFACE", "BODY", "BODY_FAMILY", "PLAN"):
        environment[f"DEW_{cache}_CACHE"] = "0"
    environment["DEW_CACHE_PACK"] = "0"
    if args.cache_mode == "warm":
        environment["DEW_PARSE_EVENT_CACHE"] = "1"
        environment["DEW_INTERFACE_CACHE"] = "1"
        environment["DEW_CACHE_PACK"] = "1"
    samples = {"before": [], "after": []}
    hashes = {}
    with tempfile.TemporaryDirectory(prefix="cache-", dir=work) as cache_root:
        # Alternate order to reduce temperature and clock bias.
        for run in range(args.runs + 1):
            for label in (["before", "after"] if run % 2 == 0 else ["after", "before"]):
                environment["DEW_CACHE_DIR"] = str(Path(cache_root) / label)
                output = work / f"{label}.wasm"
                command = ["node", "--stack-size=65500", str(getattr(args, label).resolve()),
                           "build", "--bootstrap-std", "--cache-report", *module_args, "--root",
                           f"bench.module_{args.modules - 1}", "-o", str(output)]
                started = time.perf_counter()
                completed = subprocess.run(command, cwd=ROOT, env=environment, text=True,
                                           stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                           timeout=30)
                elapsed = (time.perf_counter() - started) * 1000
                if completed.returncode:
                    raise RuntimeError(f"{label} compile failed:\n{completed.stdout}")
                if args.cache_mode == "warm" and run:
                    status = next((line for line in completed.stdout.splitlines()
                                   if line.startswith("parse event cache:")), "")
                    if "misses 0" not in status:
                        raise RuntimeError(f"{label} expected warm parse cache: {completed.stdout}")
                digest = hashlib.sha256(output.read_bytes()).hexdigest()
                if label in hashes and hashes[label] != digest:
                    raise RuntimeError(f"{label} output changed between runs")
                hashes[label] = digest
                print(f"{label} run={run} elapsed_ms={elapsed:.3f}", flush=True)
                if run:
                    samples[label].append(elapsed)
    if hashes["before"] != hashes["after"]:
        raise RuntimeError("before and after Wasm output differs")
    medians = {label: statistics.median(values) for label, values in samples.items()}
    result = {"modules": args.modules, "cache_mode": args.cache_mode, "samples_ms": samples, "median_ms": medians,
              "speedup": medians["before"] / medians["after"], "wasm_sha256": hashes["after"]}
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
