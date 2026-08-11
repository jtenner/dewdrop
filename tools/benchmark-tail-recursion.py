#!/usr/bin/env python3
"""Benchmark optimized direct tail recursion against a functional loop."""

from __future__ import annotations

import argparse
import json
import statistics
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TMP = ROOT / ".tmp" / "tail-recursion-benchmark"


def recursive_source(count: int) -> str:
    return f"""fn countdown(value: U32) -> U32 {{
  if value == 0u32 {{
    0u32
  }} else {{
    countdown(value - 1u32)
  }}
}}

pub fn main() -> U32 {{
  countdown({count}u32)
}}
"""


def loop_source(count: int) -> str:
    return f"""pub fn main() -> U32 {{
  while {count}u32 {{
    value if value > 0u32 => continue value - 1u32
    _ => break 0u32
  }}
}}
"""


def build(name: str, source: str) -> Path:
    source_path = TMP / f"{name}.dew"
    wasm_path = TMP / f"{name}.wasm"
    source_path.write_text(source, encoding="utf-8")
    subprocess.run(
        [str(ROOT / "tools" / "dew"), "build", str(source_path), "-o", str(wasm_path)],
        cwd=ROOT,
        check=True,
        stdout=subprocess.DEVNULL,
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
    for (let i = 0; i < 1000; i++) if (instance.exports.main() !== 0) throw new Error('bad result');
    const values = [];
    for (let i = 0; i < samples; i++) {
      const start = performance.now();
      if (instance.exports.main() !== 0) throw new Error('bad result');
      values.push((performance.now() - start) * 1000);
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
    parser.add_argument("--count", type=int, default=128)
    parser.add_argument("--deep-count", type=int, default=100000)
    parser.add_argument("--samples", type=int, default=10000)
    args = parser.parse_args()
    if args.count < 1 or args.deep_count < 1 or args.samples < 1:
        parser.error("counts and samples must be positive")
    TMP.mkdir(parents=True, exist_ok=True)
    recursive = build("recursive", recursive_source(args.count))
    loop = build("loop", loop_source(args.count))
    deep = build("recursive-deep", recursive_source(args.deep_count))
    raw = measure([recursive, loop], args.samples)
    recursive_us = statistics.median(raw[str(recursive)])
    loop_us = statistics.median(raw[str(loop)])
    subprocess.run(
        [
            "node",
            "-e",
            "WebAssembly.instantiate(require('fs').readFileSync(process.argv[1]),{}).then(x=>{if(x.instance.exports.main()!==0)process.exit(1)})",
            str(deep),
        ],
        cwd=ROOT,
        check=True,
    )
    print(json.dumps({
        "count": args.count,
        "deep_count": args.deep_count,
        "samples": args.samples,
        "tail_recursive_median_us": round(recursive_us, 3),
        "functional_loop_median_us": round(loop_us, 3),
        "tail_to_loop_ratio": round(recursive_us / loop_us, 4),
        "tail_recursive_wasm_bytes": recursive.stat().st_size,
        "functional_loop_wasm_bytes": loop.stat().st_size,
        "deep_tail_recursion_completed": True,
    }, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
