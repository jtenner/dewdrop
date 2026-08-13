#!/usr/bin/env python3
"""Compare compact-owning and source-retaining strict JSON parsing."""

from __future__ import annotations

import argparse
import importlib.util
import json
import platform
import statistics
import subprocess
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
TMP = ROOT / ".tmp" / "json-retained-benchmark"
FIXTURES = ("small", "medium", "large")


def load_comparison_module() -> Any:
    path = ROOT / "tools" / "benchmark-json-comparison.py"
    spec = importlib.util.spec_from_file_location("dew_json_comparison", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def run(command: list[str], *, capture: bool = False) -> subprocess.CompletedProcess[str]:
    return subprocess.run(command, cwd=ROOT, check=True, text=True, capture_output=capture)


def source(document: str, root_size: int, literal: str) -> str:
    return f"""open dew.std.array
open dew.std.json
open dew.std.string

fn document() -> String {{
  {literal}
}}

fn compact_repeat(remaining: U32, total: U32) -> U32 {{
  if remaining == 0u32 {{
    total
  }} else {{
    match json_parse(document()) {{
      Result::Ok(JsonValue::Object(members)) =>
        compact_repeat(remaining - 1u32, total + members.length())
      _ => total
    }}
  }}
}}

fn retained_repeat(remaining: U32, total: U32) -> U32 {{
  if remaining == 0u32 {{
    total
  }} else {{
    match json_parse_retained(document()) {{
      Result::Ok(JsonValue::Object(members)) =>
        retained_repeat(remaining - 1u32, total + members.length())
      _ => total
    }}
  }}
}}

fn validate_repeat(remaining: U32, total: U32) -> U32 {{
  if remaining == 0u32 {{
    total
  }} else {{
    match json_validate(document()) {{
      Result::Ok(_) => validate_repeat(remaining - 1u32, total + {root_size}u32)
      Result::Err(_) => total
    }}
  }}
}}

fn document_repeat(remaining: U32, total: U32) -> U32 {{
  if remaining == 0u32 {{
    total
  }} else {{
    match json_parse_document(document()) {{
      Result::Ok(value) =>
        document_repeat(remaining - 1u32, total + value.stringify_source().byte_length())
      Result::Err(_) => total
    }}
  }}
}}

fn raw_document_repeat(remaining: U32, total: U32) -> U32 {{
  if remaining == 0u32 {{
    total
  }} else {{
    match json_parse_raw_document(document()) {{
      Result::Ok(value) =>
        raw_document_repeat(remaining - 1u32, total + value.stringify_source().byte_length())
      Result::Err(_) => total
    }}
  }}
}}

fn retained_roundtrip_repeat(remaining: U32, total: U32) -> U32 {{
  if remaining == 0u32 {{
    total
  }} else {{
    match json_parse_retained(document()) {{
      Result::Ok(value) => match json_stringify(value) {{
        Result::Ok(output) =>
          retained_roundtrip_repeat(remaining - 1u32, total + output.byte_length())
        Result::Err(_) => total
      }}
      Result::Err(_) => total
    }}
  }}
}}

pub fn compact(iterations: U32) -> U32 {{
  compact_repeat(iterations, 0u32)
}}

pub fn retained(iterations: U32) -> U32 {{
  retained_repeat(iterations, 0u32)
}}

pub fn validate(iterations: U32) -> U32 {{
  validate_repeat(iterations, 0u32)
}}

pub fn document_roundtrip(iterations: U32) -> U32 {{
  document_repeat(iterations, 0u32)
}}

pub fn raw_document_roundtrip(iterations: U32) -> U32 {{
  raw_document_repeat(iterations, 0u32)
}}

pub fn retained_roundtrip(iterations: U32) -> U32 {{
  retained_roundtrip_repeat(iterations, 0u32)
}}
"""


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--json-as-dir", type=Path, default=ROOT / ".tmp" / "json-as")
    parser.add_argument("--samples", type=int, default=101)
    parser.add_argument("--rounds", type=int, default=5)
    parser.add_argument("--target-batch-bytes", type=int, default=262144)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    if args.samples < 4 or args.rounds < 1 or args.target_batch_bytes < 1:
        parser.error("samples >= 4, rounds >= 1, and positive batch bytes are required")
    comparison = load_comparison_module()
    modules = []
    TMP.mkdir(parents=True, exist_ok=True)
    for name in FIXTURES:
        document = comparison.extract_json_as_fixture(args.json_as_dir.resolve(), name)
        directory = TMP / name
        directory.mkdir(parents=True, exist_ok=True)
        source_path = directory / "benchmark.dew"
        source_path.write_text(source(document, comparison.fixture_root_size(document),
                                      comparison.dew_string_literal(document)), encoding="utf-8")
        wasm_path = directory / "benchmark.wasm"
        run([str(ROOT / "tools" / "dew"), "build", str(source_path), "-o", str(wasm_path)], capture=True)
        modules.append({"name": name, "bytes": len(document.encode()),
                        "root": comparison.fixture_root_size(document), "wasm": str(wasm_path)})
    specs = TMP / "specs.json"
    specs.write_text(json.dumps(modules), encoding="utf-8")
    runner = r"""
const fs=require('fs'),{performance}=require('perf_hooks');
(async()=>{const specs=JSON.parse(fs.readFileSync(process.argv[1])),samples=+process.argv[2],rounds=+process.argv[3],target=+process.argv[4],out={};
for(const s of specs){const i=(await WebAssembly.instantiate(fs.readFileSync(s.wasm),{})).instance,b=Math.max(1,Math.min(5000,Math.floor(target/s.bytes)));out[s.name]={};
for(const op of ['compact','retained','validate','document_roundtrip','raw_document_roundtrip','retained_roundtrip']){for(let w=0;w<30;w++)i.exports[op](b);let rs=[];for(let r=0;r<rounds;r++){let xs=[];for(let n=0;n<samples;n++){let t=performance.now();i.exports[op](b);xs.push((performance.now()-t)*1e6/b)}rs.push(xs)}out[s.name][op]=rs}}
process.stdout.write(JSON.stringify(out))})().catch(e=>{console.error(e);process.exit(1)});
"""
    raw = json.loads(run(["node", "-e", runner, str(specs), str(args.samples), str(args.rounds),
                          str(args.target_batch_bytes)], capture=True).stdout)
    fixtures = {}
    for name, operations in raw.items():
        medians = {op: statistics.median([statistics.median(row) for row in rows])
                   for op, rows in operations.items()}
        fixtures[name] = {
            "compact_ns_per_op": round(medians["compact"], 2),
            "retained_ns_per_op": round(medians["retained"], 2),
            "retained_delta_percent": round((medians["retained"] / medians["compact"] - 1) * 100, 2),
            "validate_ns_per_op": round(medians["validate"], 2),
            "document_roundtrip_ns_per_op": round(medians["document_roundtrip"], 2),
            "raw_document_roundtrip_ns_per_op": round(medians["raw_document_roundtrip"], 2),
            "retained_roundtrip_ns_per_op": round(medians["retained_roundtrip"], 2),
        }
    report = {
        "methodology": {"samples_per_round": args.samples, "rounds": args.rounds,
                        "warmups": 30, "target_batch_bytes": args.target_batch_bytes},
        "environment": {"platform": platform.platform(),
                        "node": run(["node", "--version"], capture=True).stdout.strip(),
                        "revision": run(["git", "rev-parse", "HEAD"], capture=True).stdout.strip()},
        "fixtures": fixtures,
    }
    encoded = json.dumps(report, indent=2, sort_keys=True) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(encoded, encoding="utf-8")
    print(encoded, end="")


if __name__ == "__main__":
    main()
