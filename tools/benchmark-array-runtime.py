#!/usr/bin/env python3
"""Benchmark geometric Array growth against exact upfront reservation in Node."""

from __future__ import annotations

import argparse
import json
import statistics
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TMP = ROOT / ".tmp" / "array-benchmark"


def source(pushes: int, reserved: bool) -> str:
    constructor = (
        f"Array::with_capacity({pushes}u32)" if reserved else "Array::new()"
    )
    statements = "\n".join(f"  values.push({index})" for index in range(pushes))
    return f"""open dew.std.array

fn values() -> Array<I32> {{
  {constructor}
}}

pub fn main() -> I32 {{
  let values = values()
{statements}
  values[0u32] + values[{pushes - 1}u32]
}}
"""


def build(name: str, text: str) -> Path:
    source_path = TMP / f"{name}.dew"
    wasm_path = TMP / f"{name}.wasm"
    source_path.write_text(text, encoding="utf-8")
    subprocess.run(
        [str(ROOT / "tools" / "dew"), "build", str(source_path), "-o", str(wasm_path)],
        cwd=ROOT,
        check=True,
    )
    return wasm_path


def measure(paths: list[Path], samples: int) -> dict[str, list[float]]:
    runner = r"""
const fs = require('fs');
const { performance } = require('perf_hooks');
(async () => {
  const samples = Number(process.argv[1]);
  const report = {};
  for (const path of process.argv.slice(2)) {
    const { instance } = await WebAssembly.instantiate(fs.readFileSync(path), {});
    for (let i = 0; i < 20; i++) instance.exports.main();
    const values = [];
    for (let i = 0; i < samples; i++) {
      const start = performance.now();
      const result = instance.exports.main();
      const end = performance.now();
      if (result < 0) throw new Error('unexpected benchmark result');
      values.push((end - start) * 1000);
    }
    report[path] = values;
  }
  process.stdout.write(JSON.stringify(report));
})().catch(error => { console.error(error); process.exit(1); });
"""
    completed = subprocess.run(
        ["node", "-e", runner, str(samples), *(str(path) for path in paths)],
        cwd=ROOT,
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(completed.stdout)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--pushes", type=int, default=256)
    parser.add_argument("--samples", type=int, default=200)
    args = parser.parse_args()
    if args.pushes < 1 or args.samples < 1:
        parser.error("--pushes and --samples must be positive")
    TMP.mkdir(parents=True, exist_ok=True)
    geometric = build("geometric", source(args.pushes, False))
    reserved = build("reserved", source(args.pushes, True))
    raw = measure([geometric, reserved], args.samples)
    geometric_values = raw[str(geometric)]
    reserved_values = raw[str(reserved)]
    geometric_median = statistics.median(geometric_values)
    reserved_median = statistics.median(reserved_values)
    print(
        json.dumps(
            {
                "pushes": args.pushes,
                "samples": args.samples,
                "geometric_median_us": round(geometric_median, 3),
                "reserved_median_us": round(reserved_median, 3),
                "geometric_overhead_us": round(
                    geometric_median - reserved_median, 3
                ),
                "geometric_overhead_ratio": round(
                    geometric_median / reserved_median, 4
                )
                if reserved_median > 0
                else None,
            },
            indent=2,
            sort_keys=True,
        )
    )


if __name__ == "__main__":
    main()
