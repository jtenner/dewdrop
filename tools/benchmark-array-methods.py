#!/usr/bin/env python3
"""Benchmark the complete Dew Array surface in isolated Wasm modules."""

from __future__ import annotations

import argparse
import json
import platform
import statistics
import subprocess
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
TMP = ROOT / ".tmp" / "array-method-benchmark"

COMMON = """open dew.std.array

fn values() -> Array<I32> {
  let output = Array::with_capacity(128u32)
  while 0u32 {
    index if index < 128u32 => {
      output.push(u32_into_i32(index % 17u32))
      continue index + 1u32
    }
    _ => break output
  }
}

fn empty_values() -> Array<I32> {
  Array::new()
}

fn reserved_values(capacity: U32) -> Array<I32> {
  Array::with_capacity(capacity)
}

fn nested_values() -> Array<Array<I32>> {
  Array::with_capacity(2u32)
}

fn pair() -> Array<I32> {
  let output = Array::with_capacity(4u32)
  output.push(7)
  output.push(3)
  output.push(11)
  output.push(5)
  output
}

fn add(left: I32, right: I32) -> I32 {
  left + right
}

fn twice(value: I32) -> I32 {
  value * 2
}

fn even(value: I32) -> Bool {
  value % 2 == 0
}

fn positive(value: I32) -> Bool {
  value >= 0
}

fn eleven(value: I32) -> Bool {
  value == 11
}

fn expand(value: I32) -> Array<I32> {
  let output = Array::with_capacity(2u32)
  output.push(value)
  output.push(value + 1)
  output
}
"""

BODIES: dict[str, str] = {
    "new": "empty_values().length()",
    "with_capacity": "reserved_values(128u32).capacity()",
    "make_baseline": "let output = reserved_values(128u32)\n  while 0u32 {\n    index if index < 128u32 => {\n      output.push(7)\n      continue index + 1u32\n    }\n    _ => break output.length()\n  }",
    "make": "Array::make(128u32, 7).length()",
    "reserve": "let output = empty_values()\n  output.reserve(128u32)\n  output.capacity()",
    "shrink_to_fit": "let output = values()\n  output.reserve(128u32)\n  output.shrink_to_fit()\n  output.capacity()",
    "truncate_baseline": "let output = values()\n  while output.length() {\n    length if length > 32u32 => {\n      output.pop()\n      continue length - 1u32\n    }\n    _ => break output.length()\n  }",
    "truncate": "let output = values()\n  output.truncate(32u32)\n  output.length()",
    "copy_baseline": "let source = values()\n  let output = reserved_values(source.length())\n  while 0u32 {\n    index if index < source.length() => {\n      output.push(source[index])\n      continue index + 1u32\n    }\n    _ => break output.length()\n  }",
    "copy": "values().copy().length()",
    "extend_baseline": "let output = values()\n  let source = values()\n  output.reserve(source.length())\n  while 0u32 {\n    index if index < source.length() => {\n      output.push(source[index])\n      continue index + 1u32\n    }\n    _ => break output.length()\n  }",
    "extend": "let output = values()\n  output.extend(values())\n  output.length()",
    "first": "u32_from_i32(values().first())",
    "last": "u32_from_i32(values().last())",
    "at": "u32_from_i32(values().at(-1))",
    "swap": "let output = values()\n  output.swap(0u32, 127u32)\n  i32_into_u32(output[0u32])",
    "shift": "let output = values()\n  output.shift()\n  output.length()",
    "unshift": "let output = values()\n  output.unshift(99)\n  output.length()",
    "insert": "let output = values()\n  output.insert(64u32, 99)\n  output.length()",
    "remove": "let output = values()\n  output.remove(64u32)\n  output.length()",
    "fill_baseline": "let output = values()\n  while 16u32 {\n    index if index < 112u32 => {\n      output[index] = 9\n      continue index + 1u32\n    }\n    _ => break output.length()\n  }",
    "fill": "let output = values()\n  output.fill(9, 16u32, 112u32)\n  output.length()",
    "copy_within_baseline": "let output = values()\n  while 96u32 {\n    0u32 => break output.length()\n    remaining => {\n      let index = remaining - 1u32\n      output[16u32 + index] = output[index]\n      continue index\n    }\n  }",
    "copy_within": "let output = values()\n  output.copy_within(16u32, 0u32, 96u32)\n  output.length()",
    "slice_baseline": "let source = values()\n  let output = reserved_values(96u32)\n  while 16u32 {\n    index if index < 112u32 => {\n      output.push(source[index])\n      continue index + 1u32\n    }\n    _ => break output.length()\n  }",
    "slice": "values().slice(16u32, 112u32).length()",
    "concat": "values().concat(values()).length()",
    "reverse": "let output = values()\n  output.reverse()\n  output.length()",
    "to_reversed": "values().to_reversed().length()",
    "splice": "let output = values()\n  output.splice(32u32, 32u32, pair())\n  output.length()",
    "to_spliced": "values().to_spliced(32u32, 32u32, pair()).length()",
    "includes": "if values().includes(11) {\n    1u32\n  } else {\n    0u32\n  }",
    "index_of": "u32_from_u32(values().index_of(11))",
    "last_index_of": "u32_from_u32(values().last_index_of(11))",
    "equals": "if values().equals(values()) {\n    1u32\n  } else {\n    0u32\n  }",
    "for_each": "let total = Array::make(1u32, 0)\n  values().for_each(fn(value: I32) -> Unit {\n    total[0u32] = total[0u32] + value\n  })\n  i32_into_u32(total[0u32])",
    "map": "values().map(twice).length()",
    "filter": "values().filter(even).length()",
    "every": "if values().every(positive) {\n    1u32\n  } else {\n    0u32\n  }",
    "some": "if values().some(eleven) {\n    1u32\n  } else {\n    0u32\n  }",
    "find": "u32_from_i32(values().find(eleven))",
    "reduce": "i32_into_u32(values().reduce(0, add))",
    "sort": "let output = values()\n  output.sort()\n  output.length()",
    "flat": "let nested = nested_values()\n  nested.push(values())\n  nested.push(values())\n  nested.flat().length()",
    "flat_map": "pair().flat_map(expand).length()",
    "keys": "let iter = values().keys()\n  let mut total = 0u32\n  while true {\n    true if iter.has_next() => {\n      total = total + iter.next()\n      continue true\n    }\n    _ => break total\n  }",
    "entries": "let iter = values().entries()\n  while 0u32 {\n    index if index < 128u32 => {\n      iter.next()\n      continue index + 1u32\n    }\n    _ => break 128u32\n  }",
}

HELPERS = """
fn u32_from_i32(value: Option<I32>) -> U32 {
  match value {
    Option::Some(item) => i32_into_u32(item)
    Option::None => 0u32
  }
}

fn u32_from_u32(value: Option<U32>) -> U32 {
  match value {
    Option::Some(item) => item
    Option::None => 0u32
  }
}
"""


def source(body: str) -> str:
    return COMMON + HELPERS + f"""
fn one() -> U32 {{
  {body}
}}

fn repeat(remaining: U32, total: U32) -> U32 {{
  if remaining == 0u32 {{
    total
  }} else {{
    repeat(remaining - 1u32, total + one())
  }}
}}

pub fn run(iterations: U32) -> U32 {{
  repeat(iterations, 0u32)
}}
"""


def run(command: list[str], *, capture: bool = False) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        command,
        cwd=ROOT,
        check=True,
        text=True,
        capture_output=capture,
    )


def build_all() -> list[dict[str, Any]]:
    TMP.mkdir(parents=True, exist_ok=True)
    workloads = []
    for name, body in BODIES.items():
        source_path = TMP / f"{name}.dew"
        wasm_path = TMP / f"{name}.wasm"
        source_path.write_text(source(body), encoding="utf-8")
        run([str(ROOT / "tools" / "dew"), "build", str(source_path), "-o", str(wasm_path)])
        workloads.append({"name": name, "wasm": str(wasm_path), "bytes": wasm_path.stat().st_size})
    return workloads


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--iterations", type=int, default=2000)
    parser.add_argument("--samples", type=int, default=41)
    parser.add_argument("--rounds", type=int, default=3)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    if args.iterations < 1 or args.samples < 5 or args.rounds < 1:
        parser.error("positive iterations/rounds and at least five samples are required")
    workloads = build_all()
    specs = TMP / "specs.json"
    specs.write_text(json.dumps(workloads), encoding="utf-8")
    runner = r'''
const fs=require('fs'),{performance}=require('perf_hooks');
(async()=>{const specs=JSON.parse(fs.readFileSync(process.argv[1])),iterations=+process.argv[2],samples=+process.argv[3],rounds=+process.argv[4],out={};for(const spec of specs){const {instance}=await WebAssembly.instantiate(fs.readFileSync(spec.wasm),{});if(instance.exports.__dew_init)instance.exports.__dew_init();for(let i=0;i<10;i++)instance.exports.run(iterations);const rows=[];for(let r=0;r<rounds;r++){const values=[];for(let s=0;s<samples;s++){const start=performance.now();const result=instance.exports.run(iterations);const elapsed=performance.now()-start;if(result===0xffffffff)throw Error('bad checksum');values.push(elapsed*1e6/iterations)}rows.push(values)}out[spec.name]=rows}process.stdout.write(JSON.stringify(out))})().catch(e=>{console.error(e);process.exit(1)})'''
    raw = json.loads(
        run(
            ["node", "-e", runner, str(specs), str(args.iterations), str(args.samples), str(args.rounds)],
            capture=True,
        ).stdout
    )
    methods = {}
    for workload in workloads:
        rounds = [statistics.median(row) for row in raw[workload["name"]]]
        methods[workload["name"]] = {
            "median_ns_per_invocation": round(statistics.median(rounds), 2),
            "round_medians_ns": [round(value, 2) for value in rounds],
            "wasm_bytes": workload["bytes"],
        }
    comparisons = {}
    for name in ("make", "truncate", "copy", "extend", "fill", "copy_within", "slice"):
        baseline = methods[f"{name}_baseline"]["median_ns_per_invocation"]
        optimized = methods[name]["median_ns_per_invocation"]
        comparisons[name] = {
            "baseline_ns": baseline,
            "optimized_ns": optimized,
            "speedup": round(baseline / optimized, 3) if optimized else None,
            "delta_percent": round((optimized / baseline - 1) * 100, 2) if baseline else None,
        }
    report = {
        "environment": {
            "platform": platform.platform(),
            "node": run(["node", "--version"], capture=True).stdout.strip(),
        },
        "methodology": {
            "iterations_per_sample": args.iterations,
            "samples_per_round": args.samples,
            "rounds": args.rounds,
            "warmups": 10,
            "isolated_module_per_method": True,
        },
        "comparisons": comparisons,
        "methods": methods,
    }
    encoded = json.dumps(report, indent=2, sort_keys=True) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(encoded, encoding="utf-8")
    print(encoded, end="")


if __name__ == "__main__":
    main()
