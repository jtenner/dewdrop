#!/usr/bin/env python3
"""Benchmark adjacent let-bound scalar replacement against an escaping helper."""

from __future__ import annotations

import argparse
import json
import statistics
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TMP = ROOT / ".tmp" / "scalar-replacement-benchmark"


def source(iterations: int, replaceable: bool) -> str:
    calculation = (
        "let pair = Pair {\n    left: value\n    right: value + 1\n  }\n  pair.right"
        if replaceable
        else "read_right(Pair {\n    left: value\n    right: value + 1\n  })"
    )
    return f"""struct Pair {{
  left: I32
  right: I32
}}

fn read_right(pair: Pair) -> I32 {{
  pair.right
}}

fn calculate(value: I32) -> I32 {{
  {calculation}
}}

fn repeat(remaining: U32, total: I32) -> I32 {{
  if remaining == 0u32 {{
    total
  }} else {{
    repeat(remaining - 1u32, total + calculate(1))
  }}
}}

pub fn main() -> I32 {{
  repeat({iterations}u32, 0)
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
        stdout=subprocess.DEVNULL,
    )
    return wasm_path


def measure(
    paths: list[Path], expected: int, samples: int, batch: int
) -> dict[str, list[float]]:
    runner = r"""
const fs = require('fs');
const { performance } = require('perf_hooks');
(async () => {
  const expected = Number(process.argv[1]);
  const samples = Number(process.argv[2]);
  const batch = Number(process.argv[3]);
  const paths = process.argv.slice(4);
  const instances = [];
  const report = {};
  for (const path of paths) {
    const { instance } = await WebAssembly.instantiate(fs.readFileSync(path), {});
    for (let i = 0; i < 1000; i++) if (instance.exports.main() !== expected) throw new Error('bad result');
    instances.push(instance);
    report[path] = [];
  }
  for (let sample = 0; sample < samples; sample++) {
    for (let offset = 0; offset < paths.length; offset++) {
      const index = (sample + offset) % paths.length;
      const start = performance.now();
      for (let iteration = 0; iteration < batch; iteration++) {
        if (instances[index].exports.main() !== expected) throw new Error('bad result');
      }
      report[paths[index]].push((performance.now() - start) * 1000 / batch);
    }
  }
  process.stdout.write(JSON.stringify(report));
})().catch(error => { console.error(error); process.exit(1); });
"""
    completed = subprocess.run(
        [
            "node", "-e", runner, str(expected), str(samples), str(batch),
            *(str(path) for path in paths),
        ],
        cwd=ROOT,
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(completed.stdout)


def instruction_count(wasm: Path, instruction: str) -> int:
    completed = subprocess.run(
        ["wasm-tools", "print", str(wasm)],
        cwd=ROOT,
        check=True,
        capture_output=True,
        text=True,
    )
    return completed.stdout.count(instruction)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--iterations", type=int, default=10000)
    parser.add_argument("--samples", type=int, default=2000)
    parser.add_argument("--batch", type=int, default=20)
    args = parser.parse_args()
    if args.iterations < 1 or args.samples < 1 or args.batch < 1:
        parser.error("iterations, samples, and batch must be positive")
    TMP.mkdir(parents=True, exist_ok=True)
    optimized = build("adjacent-let", source(args.iterations, True))
    baseline = build("escaping-helper", source(args.iterations, False))
    raw = measure([optimized, baseline], args.iterations * 2, args.samples, args.batch)
    optimized_us = statistics.median(raw[str(optimized)])
    baseline_us = statistics.median(raw[str(baseline)])
    print(json.dumps({
        "iterations": args.iterations,
        "samples": args.samples,
        "batch": args.batch,
        "adjacent_let_median_us": round(optimized_us, 3),
        "escaping_helper_median_us": round(baseline_us, 3),
        "adjacent_to_escaping_ratio": round(optimized_us / baseline_us, 4),
        "adjacent_let_wasm_bytes": optimized.stat().st_size,
        "escaping_helper_wasm_bytes": baseline.stat().st_size,
        "adjacent_let_struct_news": instruction_count(optimized, "struct.new"),
        "escaping_helper_struct_news": instruction_count(baseline, "struct.new"),
    }, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
