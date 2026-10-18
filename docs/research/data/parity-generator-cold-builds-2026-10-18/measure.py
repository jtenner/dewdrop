#!/usr/bin/env python3
"""Measure clean test-generator builds without replacing committed evidence."""

import argparse
import hashlib
import json
import subprocess
import tempfile
import time
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, help="new output directory")
    parser.add_argument("--lane", action="append", choices=("utf", "wasi", "snapshot"))
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[4]
    if args.output:
        output = args.output.resolve()
        output.mkdir(parents=True, exist_ok=False)
    else:
        output = Path(tempfile.mkdtemp(prefix="dew-generator-builds-"))
    records = []
    for lane in args.lane or ("utf", "wasi", "snapshot"):
        target = output / f"{lane}-target"
        if lane == "snapshot":
            command = [
                "mise", "exec", "wasm-tools@1.262.0", "go@1.27.2", "--",
                "python3", "tools/module-snapshots/run.py",
                "--fixture", "text/concat", "--target-dir", str(target),
            ]
        else:
            command = ["bash", f"tools/{lane}-parity/run.sh", "--target-dir", str(target)]
        started = time.perf_counter()
        with (output / f"{lane}.stdout").open("wb") as stdout:
            with (output / f"{lane}.stderr").open("wb") as stderr:
                process = subprocess.run(command, cwd=root, stdout=stdout, stderr=stderr)
        elapsed = time.perf_counter() - started
        record = {"command": command, "seconds": elapsed, "exit": process.returncode,
                  "exceeds_30_seconds": elapsed > 30}
        if lane != "snapshot" and process.returncode == 0:
            wasm = root / f"tools/{lane}-parity/{lane}_parity.wasm"
            record["wasm_bytes"] = wasm.stat().st_size
            record["wasm_sha256"] = hashlib.sha256(wasm.read_bytes()).hexdigest()
        records.append(record)
        print(f"{lane}: {elapsed:.3f} seconds, exit {process.returncode}", flush=True)
    report = output / "results.json"
    report.write_text(json.dumps(records, indent=2) + "\n")
    print(f"Report: {report}")
    return int(any(record["exit"] != 0 for record in records))


if __name__ == "__main__":
    raise SystemExit(main())
