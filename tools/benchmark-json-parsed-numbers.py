#!/usr/bin/env python3
"""Compare legacy and validated-number parse/canonicalize paths."""

from __future__ import annotations

import argparse
import json
import platform
import statistics
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TMP = ROOT / ".tmp" / "json-parsed-number-benchmark"


def document(count: int) -> str:
    values = [f"{index}.{index % 10}e{(index % 7) - 3}" for index in range(1, count + 1)]
    return "[" + ",".join(values) + "]"


def literal(value: str) -> str:
    return json.dumps(value)


def source(value: str) -> str:
    return f"""open dew.std.json
open dew.std.string

fn document() -> String {{
  {literal(value)}
}}

fn legacy_repeat(remaining: U32, total: U32) -> U32 {{
  if remaining == 0u32 {{
    total
  }} else {{
    match json_parse_retained(document()) {{
      Result::Ok(value) => match json_stringify(value) {{
        Result::Ok(output) => legacy_repeat(remaining - 1u32, total + output.byte_length())
        Result::Err(_) => total
      }}
      Result::Err(_) => total
    }}
  }}
}}

fn validated_repeat(remaining: U32, total: U32) -> U32 {{
  if remaining == 0u32 {{
    total
  }} else {{
    match json_parse_retained_validated_numbers(document()) {{
      Result::Ok(value) => match json_stringify(value) {{
        Result::Ok(output) => validated_repeat(remaining - 1u32, total + output.byte_length())
        Result::Err(_) => total
      }}
      Result::Err(_) => total
    }}
  }}
}}

pub fn legacy(iterations: U32) -> U32 {{
  legacy_repeat(iterations, 0u32)
}}

pub fn validated(iterations: U32) -> U32 {{
  validated_repeat(iterations, 0u32)
}}
"""


def run(command: list[str], *, capture: bool = False) -> subprocess.CompletedProcess[str]:
    return subprocess.run(command, cwd=ROOT, check=True, text=True, capture_output=capture)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--numbers", type=int, default=128)
    parser.add_argument("--samples", type=int, default=101)
    parser.add_argument("--rounds", type=int, default=5)
    parser.add_argument("--iterations", type=int, default=64)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    if min(args.numbers, args.samples, args.rounds, args.iterations) < 1:
        parser.error("all numeric arguments must be positive")
    TMP.mkdir(parents=True, exist_ok=True)
    source_path = TMP / "benchmark.dew"
    wasm_path = TMP / "benchmark.wasm"
    value = document(args.numbers)
    source_path.write_text(source(value), encoding="utf-8")
    run([str(ROOT / "tools" / "dew"), "build", str(source_path), "-o", str(wasm_path)], capture=True)
    runner = r"""
const fs=require('fs'),{performance}=require('perf_hooks');
(async()=>{const i=(await WebAssembly.instantiate(fs.readFileSync(process.argv[1]),{})).instance,samples=+process.argv[2],rounds=+process.argv[3],iterations=+process.argv[4],out={legacy:[],validated:[]};
for(const op of ['legacy','validated'])for(let w=0;w<30;w++)i.exports[op](iterations);
for(let r=0;r<rounds;r++){for(const op of ['legacy','validated']){const xs=[];for(let n=0;n<samples;n++){const t=performance.now();i.exports[op](iterations);xs.push((performance.now()-t)*1e6/iterations)}out[op].push(xs)}}process.stdout.write(JSON.stringify(out))})().catch(e=>{console.error(e);process.exit(1)});
"""
    raw = json.loads(run(["node", "-e", runner, str(wasm_path), str(args.samples),
                          str(args.rounds), str(args.iterations)], capture=True).stdout)
    legacy = statistics.median([statistics.median(row) for row in raw["legacy"]])
    validated = statistics.median([statistics.median(row) for row in raw["validated"]])
    report = {
        "methodology": {"numbers": args.numbers, "samples_per_round": args.samples,
                        "rounds": args.rounds, "iterations_per_sample": args.iterations,
                        "warmups": 30},
        "environment": {"platform": platform.platform(),
                        "node": run(["node", "--version"], capture=True).stdout.strip()},
        "input_bytes": len(value.encode()),
        "legacy_ns_per_op": round(legacy, 2),
        "validated_ns_per_op": round(validated, 2),
        "delta_percent": round((validated / legacy - 1) * 100, 2),
        "wasm_bytes": wasm_path.stat().st_size,
    }
    encoded = json.dumps(report, indent=2, sort_keys=True) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(encoded, encoding="utf-8")
    print(encoded, end="")


if __name__ == "__main__":
    main()
