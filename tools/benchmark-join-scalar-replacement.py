#!/usr/bin/env python3
"""Benchmark fresh-branch scalar replacement across if and match joins."""

from __future__ import annotations

import argparse
import json
import statistics
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TMP = ROOT / ".tmp" / "join-scalar-replacement-benchmark"

OPTIMIZED = """struct Pair {
  left: I32
  right: I32
}

pub fn main(value: I32) -> I32 {
  let pair = if value == 0 {
    Pair::{
      left: value + 1
      right: value + 2
    }
  } else {
    Pair::{
      left: value + 3
      right: value + 4
    }
  }
  pair.right
}
"""

BASELINE = """struct Pair {
  left: I32
  right: I32
}

fn retain(value: Pair) -> Pair {
  value
}

pub fn main(value: I32) -> I32 {
  let pair = if value == 0 {
    Pair::{
      left: value + 1
      right: value + 2
    }
  } else {
    retain(Pair::{
      left: value + 3
      right: value + 4
    })
  }
  pair.right
}
"""

MATCH = """enum Choice {
  First
  Second
}

struct Pair {
  left: I32
  right: I32
}

pub fn main(value: I32) -> I32 {
  let choice = if value == 0 {
    Choice::First
  } else {
    Choice::Second
  }
  let pair = match choice {
    Choice::First => Pair::{
      left: value + 1
      right: value + 2
    }
    Choice::Second => Pair::{
      left: value + 3
      right: value + 4
    }
  }
  pair.right
}
"""

MATCH_BASELINE = """enum Choice {
  First
  Second
}

struct Pair {
  left: I32
  right: I32
}

fn retain(value: Pair) -> Pair {
  value
}

pub fn main(value: I32) -> I32 {
  let choice = if value == 0 {
    Choice::First
  } else {
    Choice::Second
  }
  let pair = match choice {
    Choice::First => Pair::{
      left: value + 1
      right: value + 2
    }
    Choice::Second => retain(Pair::{
      left: value + 3
      right: value + 4
    })
  }
  pair.right
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
    for (let i = 0; i < 10000; i++) if (instance.exports.main(7) !== 11) throw new Error('bad result');
    instances.push(instance);
    report[path] = [];
  }
  for (let sample = 0; sample < samples; sample++) {
    for (let offset = 0; offset < paths.length; offset++) {
      const index = (sample + offset) % paths.length;
      const start = performance.now();
      for (let iteration = 0; iteration < batch; iteration++) {
        if (instances[index].exports.main(7) !== 11) throw new Error('bad result');
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


def wat_count(path: Path, instruction: str) -> int:
    wat = subprocess.run(
        ["wasm-tools", "print", str(path)],
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
    optimized = build("optimized", OPTIMIZED)
    baseline = build("baseline", BASELINE)
    match = build("match", MATCH)
    match_baseline = build("match-baseline", MATCH_BASELINE)
    raw = measure(
        [optimized, baseline, match, match_baseline],
        args.samples,
        args.batch,
    )
    optimized_median = statistics.median(raw[str(optimized)])
    baseline_median = statistics.median(raw[str(baseline)])
    match_median = statistics.median(raw[str(match)])
    match_baseline_median = statistics.median(raw[str(match_baseline)])
    print(json.dumps({
        "samples": args.samples,
        "batch": args.batch,
        "optimized_median_us": round(optimized_median, 4),
        "baseline_median_us": round(baseline_median, 4),
        "ratio": round(optimized_median / baseline_median, 4),
        "match_median_us": round(match_median, 4),
        "match_baseline_median_us": round(match_baseline_median, 4),
        "match_ratio": round(match_median / match_baseline_median, 4),
        "optimized_wasm_bytes": optimized.stat().st_size,
        "baseline_wasm_bytes": baseline.stat().st_size,
        "match_wasm_bytes": match.stat().st_size,
        "match_baseline_wasm_bytes": match_baseline.stat().st_size,
        "optimized_struct_new": wat_count(optimized, "struct.new"),
        "optimized_struct_get": wat_count(optimized, "struct.get"),
        "baseline_struct_new": wat_count(baseline, "struct.new"),
        "baseline_struct_get": wat_count(baseline, "struct.get"),
        "match_struct_new": wat_count(match, "struct.new"),
        "match_struct_get": wat_count(match, "struct.get"),
        "match_baseline_struct_new": wat_count(match_baseline, "struct.new"),
        "match_baseline_struct_get": wat_count(match_baseline, "struct.get"),
    }, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
