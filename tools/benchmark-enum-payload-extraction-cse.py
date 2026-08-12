#!/usr/bin/env python3
"""Benchmark retained enum payload extraction sharing across guarded arms."""

from __future__ import annotations

import argparse
import json
import statistics
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TMP = ROOT / ".tmp" / "enum-payload-extraction-cse-benchmark"

OPTIMIZED = """enum Maybe {
  Some(I32, I32)
  None
}

fn retain(value: Maybe) -> Maybe {
  value
}

pub fn main(value: I32) -> I32 {
  match retain(Maybe::Some(value + 1, value)) {
    Maybe::Some(first, second) if first > 0 => second
    Maybe::Some(first, second) => second
    Maybe::None => 0
  }
}
"""

BASELINE = """enum Maybe {
  Some(I32, I32)
  None
}

fn retain(value: Maybe) -> Maybe {
  value
}

fn choose(value: I32) -> Bool {
  value > 0
}

pub fn main(value: I32) -> I32 {
  match retain(Maybe::Some(value + 1, value)) {
    Maybe::Some(first, second) if choose(first) => second
    Maybe::Some(first, second) => second
    Maybe::None => 0
  }
}
"""


def build(name: str, text: str) -> Path:
    source = TMP / f"{name}.dew"
    wasm = TMP / f"{name}.wasm"
    source.write_text(text, encoding="utf-8")
    subprocess.run(
        [str(ROOT / "tools" / "dew"), "build", str(source), "-o", str(wasm)],
        cwd=ROOT,
        check=True,
        stdout=subprocess.DEVNULL,
    )
    return wasm


def measure(paths: list[Path], samples: int, batch: int) -> dict[str, list[float]]:
    runner = r"""
const fs = require('fs');
const { performance } = require('perf_hooks');
(async () => {
  const samples = Number(process.argv[1]);
  const batch = Number(process.argv[2]);
  const paths = process.argv.slice(3);
  const instances = [];
  const report = {};
  for (const path of paths) {
    const { instance } = await WebAssembly.instantiate(fs.readFileSync(path), {});
    for (let i = 0; i < 10000; i++) if (instance.exports.main(42) !== 42) throw new Error('bad result');
    instances.push(instance);
    report[path] = [];
  }
  for (let sample = 0; sample < samples; sample++) {
    for (let offset = 0; offset < paths.length; offset++) {
      const index = (sample + offset) % paths.length;
      const start = performance.now();
      for (let iteration = 0; iteration < batch; iteration++) {
        if (instances[index].exports.main(42) !== 42) throw new Error('bad result');
      }
      report[paths[index]].push((performance.now() - start) * 1000 / batch);
    }
  }
  process.stdout.write(JSON.stringify(report));
})().catch(error => { console.error(error); process.exit(1); });
"""
    completed = subprocess.run(
        ["node", "-e", runner, str(samples), str(batch), *(str(path) for path in paths)],
        cwd=ROOT,
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(completed.stdout)


def instruction_count(path: Path, instruction: str) -> int:
    wat = subprocess.run(
        ["wasm-tools", "print", str(path)],
        cwd=ROOT,
        check=True,
        capture_output=True,
        text=True,
    ).stdout
    return wat.count(instruction)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--samples", type=int, default=10000)
    parser.add_argument("--batch", type=int, default=100)
    args = parser.parse_args()
    if args.samples < 1 or args.batch < 1:
        parser.error("samples and batch must be positive")
    TMP.mkdir(parents=True, exist_ok=True)
    optimized = build("shared", OPTIMIZED)
    baseline = build("retained", BASELINE)
    raw = measure([optimized, baseline], args.samples, args.batch)
    optimized_us = statistics.median(raw[str(optimized)])
    baseline_us = statistics.median(raw[str(baseline)])
    print(json.dumps({
        "samples": args.samples,
        "batch": args.batch,
        "shared_median_us": round(optimized_us, 4),
        "retained_median_us": round(baseline_us, 4),
        "shared_to_retained_ratio": round(optimized_us / baseline_us, 4),
        "shared_wasm_bytes": optimized.stat().st_size,
        "retained_wasm_bytes": baseline.stat().st_size,
        "shared_struct_gets": instruction_count(optimized, "struct.get"),
        "retained_struct_gets": instruction_count(baseline, "struct.get"),
        "shared_ref_casts": instruction_count(optimized, "ref.cast"),
        "retained_ref_casts": instruction_count(baseline, "ref.cast"),
    }, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
