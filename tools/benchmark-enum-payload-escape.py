#!/usr/bin/env python3
"""Benchmark direct fresh tuple-variant payload escape elimination."""

from __future__ import annotations

import argparse
import json
import statistics
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TMP = ROOT / ".tmp" / "enum-payload-escape-benchmark"

OPTIMIZED = """enum Maybe {
  Some(I32)
  None
}

pub fn main(value: I32) -> I32 {
  match Maybe::Some(value) {
    Maybe::Some(item) => item
    Maybe::None => 0
  }
}
"""

ARM_ORDER = """enum Maybe {
  Some(I32)
  None
}

pub fn main(value: I32) -> I32 {
  match Maybe::Some(value) {
    Maybe::None => 0
    Maybe::Some(item) => item
  }
}
"""

ALTERNATIVE = """enum Choice {
  First(I32)
  Second(I32)
  Empty
}

pub fn main(value: I32) -> I32 {
  match Choice::First(value) {
    Choice::First(item), Choice::Second(item) => item
    Choice::Empty => 0
  }
}
"""

CONSTANT_GUARD = """enum Maybe {
  Some(I32)
  None
}

pub fn main(value: I32) -> I32 {
  match Maybe::Some(value) {
    Maybe::Some(item) if false => 0
    Maybe::Some(item) if 1 < 2 => item
    Maybe::None => 0
  }
}
"""

FALSE_CATCHALL = """enum Maybe {
  Some(I32)
  None
}

pub fn main(value: I32) -> I32 {
  match Maybe::Some(value) {
    _ if false => 0
    ignored if false => 1
    Maybe::Some(item) => item
    Maybe::None => 0
  }
}
"""

CATCHALL = """enum Maybe {
  Some(I32, I32)
  None
}

pub fn main(value: I32) -> I32 {
  match Maybe::Some(value + 1, value) {
    _ => 42
    Maybe::Some(first, second) => second
    Maybe::None => 0
  }
}
"""

BINDING_FORWARD = """enum Maybe {
  Some(I32)
  None
}

pub fn main(value: I32) -> I32 {
  let forwarded = match Maybe::Some(value) {
    whole => whole
    Maybe::Some(item) => Maybe::Some(item)
    Maybe::None => Maybe::None
  }
  match forwarded {
    Maybe::Some(item) => item
    Maybe::None => 0
  }
}
"""

BINDING_PROJECTION = """enum Maybe {
  Some(I32, I32)
  None
}

pub fn main(value: I32) -> I32 {
  match Maybe::Some(value + 1, value) {
    whole => match whole {
      Maybe::Some(first, second) => second
      Maybe::None => 0
    }
    Maybe::Some(first, second) => first
    Maybe::None => 0
  }
}
"""

LOCAL = """enum Maybe {
  Some(I32)
  None
}

pub fn main(value: I32) -> I32 {
  let wrapped = Maybe::Some(value)
  match wrapped {
    Maybe::Some(item) => item
    Maybe::None => 0
  }
}
"""

STRUCT = """enum RecordMaybe {
  Some {
    left: I32
    right: I32
  }
  None
}

pub fn main(value: I32) -> I32 {
  match (RecordMaybe::Some {
    left: value + 1
    right: value
  }) {
    RecordMaybe::Some {
      left
      right
    } => right
    RecordMaybe::None => 0
  }
}
"""

STRUCT_BASELINE = """enum RecordMaybe {
  Some {
    left: I32
    right: I32
  }
  None
}

fn retain(value: RecordMaybe) -> RecordMaybe {
  value
}

pub fn main(value: I32) -> I32 {
  match retain(RecordMaybe::Some {
    left: value + 1
    right: value
  }) {
    RecordMaybe::Some {
      left
      right
    } => right
    RecordMaybe::None => 0
  }
}
"""

NESTED = """struct Box {
  left: I32
  right: I32
}

enum Wrapped {
  Some(Box)
  None
}

pub fn main(value: I32) -> I32 {
  match Wrapped::Some(Box {
    left: value + 1
    right: value
  }) {
    Wrapped::Some(Box {
      left
      right
    }) => right
    Wrapped::None => 0
  }
}
"""

NESTED_BASELINE = """struct Box {
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
  match retain(Wrapped::Some(Box {
    left: value + 1
    right: value
  })) {
    Wrapped::Some(Box {
      left
      right
    }) => right
    Wrapped::None => 0
  }
}
"""

BASELINE = """enum Maybe {
  Some(I32)
  None
}

fn retain(value: Maybe) -> Maybe {
  value
}

pub fn main(value: I32) -> I32 {
  match retain(Maybe::Some(value)) {
    Maybe::Some(item) => item
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
    arm_order = build("arm-order", ARM_ORDER)
    alternative = build("alternative", ALTERNATIVE)
    constant_guard = build("constant-guard", CONSTANT_GUARD)
    false_catchall = build("false-catchall", FALSE_CATCHALL)
    catchall = build("catchall", CATCHALL)
    binding_forward = build("binding-forward", BINDING_FORWARD)
    binding_projection = build("binding-projection", BINDING_PROJECTION)
    local = build("local", LOCAL)
    struct = build("struct", STRUCT)
    struct_baseline = build("struct-baseline", STRUCT_BASELINE)
    nested = build("nested", NESTED)
    nested_baseline = build("nested-baseline", NESTED_BASELINE)
    baseline = build("baseline", BASELINE)
    raw = measure(
        [
            optimized,
            arm_order,
            alternative,
            constant_guard,
            false_catchall,
            catchall,
            binding_forward,
            binding_projection,
            local,
            struct,
            nested,
            baseline,
            struct_baseline,
            nested_baseline,
        ],
        args.samples,
        args.batch,
    )
    optimized_median = statistics.median(raw[str(optimized)])
    arm_order_median = statistics.median(raw[str(arm_order)])
    alternative_median = statistics.median(raw[str(alternative)])
    constant_guard_median = statistics.median(raw[str(constant_guard)])
    false_catchall_median = statistics.median(raw[str(false_catchall)])
    catchall_median = statistics.median(raw[str(catchall)])
    binding_forward_median = statistics.median(raw[str(binding_forward)])
    binding_projection_median = statistics.median(
        raw[str(binding_projection)],
    )
    local_median = statistics.median(raw[str(local)])
    struct_median = statistics.median(raw[str(struct)])
    nested_median = statistics.median(raw[str(nested)])
    baseline_median = statistics.median(raw[str(baseline)])
    struct_baseline_median = statistics.median(raw[str(struct_baseline)])
    nested_baseline_median = statistics.median(raw[str(nested_baseline)])
    print(json.dumps({
        "samples": args.samples,
        "batch": args.batch,
        "optimized_median_us": round(optimized_median, 4),
        "arm_order_median_us": round(arm_order_median, 4),
        "alternative_median_us": round(alternative_median, 4),
        "constant_guard_median_us": round(constant_guard_median, 4),
        "false_catchall_median_us": round(false_catchall_median, 4),
        "catchall_median_us": round(catchall_median, 4),
        "binding_forward_median_us": round(binding_forward_median, 4),
        "binding_projection_median_us": round(binding_projection_median, 4),
        "local_median_us": round(local_median, 4),
        "struct_median_us": round(struct_median, 4),
        "nested_median_us": round(nested_median, 4),
        "baseline_median_us": round(baseline_median, 4),
        "struct_baseline_median_us": round(struct_baseline_median, 4),
        "nested_baseline_median_us": round(nested_baseline_median, 4),
        "direct_ratio": round(optimized_median / baseline_median, 4),
        "arm_order_ratio": round(arm_order_median / baseline_median, 4),
        "alternative_ratio": round(alternative_median / baseline_median, 4),
        "constant_guard_ratio": round(constant_guard_median / baseline_median, 4),
        "false_catchall_ratio": round(false_catchall_median / baseline_median, 4),
        "catchall_ratio": round(catchall_median / baseline_median, 4),
        "binding_forward_ratio": round(binding_forward_median / baseline_median, 4),
        "binding_projection_ratio": round(
            binding_projection_median / baseline_median, 4,
        ),
        "local_ratio": round(local_median / baseline_median, 4),
        "struct_ratio": round(struct_median / struct_baseline_median, 4),
        "nested_ratio": round(nested_median / nested_baseline_median, 4),
        "optimized_wasm_bytes": optimized.stat().st_size,
        "arm_order_wasm_bytes": arm_order.stat().st_size,
        "alternative_wasm_bytes": alternative.stat().st_size,
        "constant_guard_wasm_bytes": constant_guard.stat().st_size,
        "false_catchall_wasm_bytes": false_catchall.stat().st_size,
        "catchall_wasm_bytes": catchall.stat().st_size,
        "binding_forward_wasm_bytes": binding_forward.stat().st_size,
        "binding_projection_wasm_bytes": binding_projection.stat().st_size,
        "local_wasm_bytes": local.stat().st_size,
        "struct_wasm_bytes": struct.stat().st_size,
        "nested_wasm_bytes": nested.stat().st_size,
        "baseline_wasm_bytes": baseline.stat().st_size,
        "struct_baseline_wasm_bytes": struct_baseline.stat().st_size,
        "nested_baseline_wasm_bytes": nested_baseline.stat().st_size,
        "optimized_struct_new": wat_count(optimized, "struct.new"),
        "optimized_struct_get": wat_count(optimized, "struct.get"),
        "arm_order_struct_new": wat_count(arm_order, "struct.new"),
        "arm_order_struct_get": wat_count(arm_order, "struct.get"),
        "alternative_struct_new": wat_count(alternative, "struct.new"),
        "alternative_struct_get": wat_count(alternative, "struct.get"),
        "constant_guard_struct_new": wat_count(constant_guard, "struct.new"),
        "constant_guard_struct_get": wat_count(constant_guard, "struct.get"),
        "false_catchall_struct_new": wat_count(false_catchall, "struct.new"),
        "false_catchall_struct_get": wat_count(false_catchall, "struct.get"),
        "catchall_struct_new": wat_count(catchall, "struct.new"),
        "catchall_struct_get": wat_count(catchall, "struct.get"),
        "binding_forward_struct_new": wat_count(binding_forward, "struct.new"),
        "binding_forward_struct_get": wat_count(binding_forward, "struct.get"),
        "binding_projection_struct_new": wat_count(binding_projection, "struct.new"),
        "binding_projection_struct_get": wat_count(binding_projection, "struct.get"),
        "local_struct_new": wat_count(local, "struct.new"),
        "local_struct_get": wat_count(local, "struct.get"),
        "struct_struct_new": wat_count(struct, "struct.new"),
        "struct_struct_get": wat_count(struct, "struct.get"),
        "nested_struct_new": wat_count(nested, "struct.new"),
        "nested_struct_get": wat_count(nested, "struct.get"),
        "baseline_struct_new": wat_count(baseline, "struct.new"),
        "baseline_struct_get": wat_count(baseline, "struct.get"),
        "struct_baseline_struct_new": wat_count(struct_baseline, "struct.new"),
        "struct_baseline_struct_get": wat_count(struct_baseline, "struct.get"),
        "nested_baseline_struct_new": wat_count(nested_baseline, "struct.new"),
        "nested_baseline_struct_get": wat_count(nested_baseline, "struct.get"),
    }, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
