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

NESTED_OPTIMIZED = """struct Box {
  left: I32
  right: I32
}

enum Wrapped {
  Some(Box)
  None
}

fn retain(value: Wrapped) -> Wrapped {
  value
}

pub fn main(value: I32) -> I32 {
  match retain(Wrapped::Some(Box::{
    left: value + 1
    right: value
  })) {
    Wrapped::Some(Box {
      left
      right
    }) if left > 0 => right
    Wrapped::Some(Box {
      left
      right
    }) => right
    Wrapped::None => 0
  }
}
"""

NESTED_BASELINE = NESTED_OPTIMIZED.replace(
    "fn retain(value: Wrapped) -> Wrapped {\n  value\n}\n",
    "fn retain(value: Wrapped) -> Wrapped {\n  value\n}\n\nfn choose(value: I32) -> Bool {\n  value > 0\n}\n",
).replace("if left > 0 => right", "if choose(left) => right")

ALTERNATIVE_OPTIMIZED = """enum Choice {
  First(I32, I32)
  Second(I32, I32)
  Empty
}

fn retain(value: Choice) -> Choice {
  value
}

pub fn main(value: I32) -> I32 {
  match retain(Choice::First(value + 1, value)) {
    Choice::First(left, right), Choice::Second(left, right) if left > 0 => right
    Choice::First(left, right), Choice::Second(left, right) => right
    Choice::Empty => 0
  }
}
"""

ALTERNATIVE_BASELINE = ALTERNATIVE_OPTIMIZED.replace(
    "fn retain(value: Choice) -> Choice {\n  value\n}\n",
    "fn retain(value: Choice) -> Choice {\n  value\n}\n\nfn choose(value: I32) -> Bool {\n  value > 0\n}\n",
).replace("if left > 0 => right", "if choose(left) => right")


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
    nested = build("nested-shared", NESTED_OPTIMIZED)
    nested_baseline = build("nested-retained", NESTED_BASELINE)
    alternative = build("alternative-shared", ALTERNATIVE_OPTIMIZED)
    alternative_baseline = build(
        "alternative-retained", ALTERNATIVE_BASELINE,
    )
    raw = measure(
        [
            optimized,
            baseline,
            nested,
            nested_baseline,
            alternative,
            alternative_baseline,
        ],
        args.samples,
        args.batch,
    )
    optimized_us = statistics.median(raw[str(optimized)])
    baseline_us = statistics.median(raw[str(baseline)])
    nested_us = statistics.median(raw[str(nested)])
    nested_baseline_us = statistics.median(raw[str(nested_baseline)])
    alternative_us = statistics.median(raw[str(alternative)])
    alternative_baseline_us = statistics.median(
        raw[str(alternative_baseline)],
    )
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
        "nested_shared_median_us": round(nested_us, 4),
        "nested_retained_median_us": round(nested_baseline_us, 4),
        "nested_ratio": round(nested_us / nested_baseline_us, 4),
        "nested_shared_wasm_bytes": nested.stat().st_size,
        "nested_retained_wasm_bytes": nested_baseline.stat().st_size,
        "nested_shared_struct_gets": instruction_count(nested, "struct.get"),
        "nested_retained_struct_gets": instruction_count(
            nested_baseline, "struct.get",
        ),
        "nested_shared_ref_casts": instruction_count(nested, "ref.cast"),
        "nested_retained_ref_casts": instruction_count(
            nested_baseline, "ref.cast",
        ),
        "alternative_shared_median_us": round(alternative_us, 4),
        "alternative_retained_median_us": round(alternative_baseline_us, 4),
        "alternative_ratio": round(
            alternative_us / alternative_baseline_us, 4,
        ),
        "alternative_shared_wasm_bytes": alternative.stat().st_size,
        "alternative_retained_wasm_bytes": alternative_baseline.stat().st_size,
        "alternative_shared_struct_gets": instruction_count(
            alternative, "struct.get",
        ),
        "alternative_retained_struct_gets": instruction_count(
            alternative_baseline, "struct.get",
        ),
        "alternative_shared_ref_casts": instruction_count(
            alternative, "ref.cast",
        ),
        "alternative_retained_ref_casts": instruction_count(
            alternative_baseline, "ref.cast",
        ),
    }, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
