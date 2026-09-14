#!/usr/bin/env python3
"""Time two linked self-host compilers on one request and require equal output."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import statistics
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parent.parent


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("before", type=Path)
    parser.add_argument("after", type=Path)
    parser.add_argument("request", type=Path)
    parser.add_argument("output", type=Path, help="the output path encoded in the request")
    parser.add_argument("--runs", type=int, default=3)
    args = parser.parse_args()
    if args.runs < 1:
        parser.error("runs must be positive")
    output = args.output.resolve()
    if not output.is_relative_to(ROOT / ".tmp"):
        parser.error("benchmark output must be inside the repository .tmp directory")
    work = ROOT / ".tmp/self-host-compile-benchmark"
    work.mkdir(parents=True, exist_ok=True)
    compilers = {}
    for label, source in [("before", args.before), ("after", args.after)]:
        exported = work / f"{label}.wasm"
        start = time.perf_counter()
        subprocess.run([sys.executable, str(ROOT / "tools/export-wasm-memory.py"),
                        str(source.resolve()), str(exported)], cwd=ROOT, check=True)
        print(f"prepare {label}: {time.perf_counter() - start:.3f} s", file=sys.stderr)
        compilers[label] = exported
    samples = {label: [] for label in compilers}
    expected = None
    env = dict(os.environ, NODE_NO_WARNINGS="1")
    for run in range(args.runs + 1):
        for label in (["before", "after"] if run % 2 == 0 else ["after", "before"]):
            output.unlink(missing_ok=True)
            start = time.perf_counter()
            subprocess.run(["node", "--stack-size=65500", str(ROOT / "tools/run-dew-facet.mjs"),
                            str(compilers[label]), str(args.request.resolve())],
                           cwd=ROOT, env=env, check=True, timeout=30)
            seconds = time.perf_counter() - start
            digest = hashlib.sha256(output.read_bytes()).hexdigest()
            if expected is None:
                expected = digest
            elif expected != digest:
                raise ValueError(f"{label} run {run}: compiler output differs")
            print(f"{label} run={run} seconds={seconds:.3f}", file=sys.stderr, flush=True)
            if run:
                samples[label].append(seconds)
    medians = {label: statistics.median(values) for label, values in samples.items()}
    print(json.dumps({"runs": args.runs, "warmup_pairs": 1, "samples_seconds": samples,
                      "median_seconds": medians, "speedup": medians["before"] / medians["after"],
                      "output_sha256": expected}, indent=2))


if __name__ == "__main__":
    main()
