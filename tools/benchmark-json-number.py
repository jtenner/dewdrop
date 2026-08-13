#!/usr/bin/env python3
"""Benchmark legacy String JSON numbers versus validated JsonNumber values."""

from __future__ import annotations

import argparse
import json
import platform
import statistics
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TMP = ROOT / ".tmp" / "json-number-benchmark"

SOURCE = """open dew.std.array
open dew.std.json
open dew.std.string

fn legacy_value() -> JsonValue {
  let values = json_array()
  values.push(JsonValue::Number("-12.5e2"))
  values.push(JsonValue::Number("0.125E+2"))
  values.push(JsonValue::Number("123456789012345678901234567890"))
  JsonValue::Array(values)
}

fn validated_value() -> JsonValue {
  let values = json_array()
  match json_number("-12.5e2") {
    Result::Ok(value) => values.push(value.value())
    Result::Err(_) => {
    }
  }
  match json_number("0.125E+2") {
    Result::Ok(value) => values.push(value.value())
    Result::Err(_) => {
    }
  }
  match json_number("123456789012345678901234567890") {
    Result::Ok(value) => values.push(value.value())
    Result::Err(_) => {
    }
  }
  JsonValue::Array(values)
}

fn legacy_repeat(value: JsonValue, remaining: U32, total: U32) -> U32 {
  if remaining == 0u32 {
    total
  } else {
    match json_stringify(value) {
      Result::Ok(output) => legacy_repeat(value, remaining - 1u32, total + output.byte_length())
      Result::Err(_) => total
    }
  }
}

fn validated_repeat(value: JsonValue, remaining: U32, total: U32) -> U32 {
  if remaining == 0u32 {
    total
  } else {
    match json_stringify(value) {
      Result::Ok(output) => validated_repeat(value, remaining - 1u32, total + output.byte_length())
      Result::Err(_) => total
    }
  }
}

pub fn legacy(iterations: U32) -> U32 {
  legacy_repeat(legacy_value(), iterations, 0u32)
}

pub fn validated(iterations: U32) -> U32 {
  validated_repeat(validated_value(), iterations, 0u32)
}
"""


def run(command: list[str], *, capture: bool = False) -> subprocess.CompletedProcess[str]:
    return subprocess.run(command, cwd=ROOT, check=True, text=True, capture_output=capture)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--samples", type=int, default=101)
    parser.add_argument("--rounds", type=int, default=5)
    parser.add_argument("--iterations", type=int, default=512)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    if args.samples < 4 or args.rounds < 1 or args.iterations < 1:
        parser.error("samples >= 4, rounds >= 1, and positive iterations are required")
    TMP.mkdir(parents=True, exist_ok=True)
    source = TMP / "benchmark.dew"
    wasm = TMP / "benchmark.wasm"
    source.write_text(SOURCE, encoding="utf-8")
    run([str(ROOT / "tools" / "dew"), "build", str(source), "-o", str(wasm)], capture=True)
    runner = r"""
const fs=require('fs'),{performance}=require('perf_hooks');
(async()=>{const wasm=process.argv[1],samples=+process.argv[2],rounds=+process.argv[3],iterations=+process.argv[4],i=(await WebAssembly.instantiate(fs.readFileSync(wasm),{})).instance,out={legacy:[],validated:[]};
for(const op of ['legacy','validated'])for(let w=0;w<30;w++)i.exports[op](iterations);
for(let r=0;r<rounds;r++)for(const op of ['legacy','validated']){let xs=[];for(let n=0;n<samples;n++){let t=performance.now();i.exports[op](iterations);xs.push((performance.now()-t)*1e6/iterations)}out[op].push(xs)}
process.stdout.write(JSON.stringify(out))})().catch(e=>{console.error(e);process.exit(1)});
"""
    raw = json.loads(run(["node", "-e", runner, str(wasm), str(args.samples), str(args.rounds),
                          str(args.iterations)], capture=True).stdout)
    legacy = statistics.median([statistics.median(row) for row in raw["legacy"]])
    validated = statistics.median([statistics.median(row) for row in raw["validated"]])
    report = {
        "methodology": {"samples_per_round": args.samples, "rounds": args.rounds,
                        "warmups": 30, "iterations_per_sample": args.iterations},
        "environment": {"platform": platform.platform(),
                        "node": run(["node", "--version"], capture=True).stdout.strip()},
        "legacy_ns_per_op": round(legacy, 2),
        "validated_ns_per_op": round(validated, 2),
        "delta_percent": round((validated / legacy - 1) * 100, 2),
        "wasm_bytes": wasm.stat().st_size,
    }
    encoded = json.dumps(report, indent=2, sort_keys=True) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(encoded, encoding="utf-8")
    print(encoded, end="")


if __name__ == "__main__":
    main()
