#!/usr/bin/env python3
"""Benchmark a generated fixed-schema Dew decoder prototype on json-as fixtures."""

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
TMP = ROOT / ".tmp" / "json-typed-prototype"
FIXTURES = ("small", "medium", "large")


def load_comparison() -> Any:
    path = ROOT / "tools" / "benchmark-json-comparison.py"
    spec = importlib.util.spec_from_file_location("dew_json_comparison", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def run(command: list[str], *, capture: bool = False) -> subprocess.CompletedProcess[str]:
    return subprocess.run(command, cwd=ROOT, check=True, text=True, capture_output=capture)


def skip_ws(data: bytes, offset: int) -> int:
    while offset < len(data) and data[offset] in b" \t\r\n":
        offset += 1
    return offset


def scan_string(data: bytes, offset: int) -> int:
    assert data[offset] == 34
    offset += 1
    while offset < len(data):
        byte = data[offset]
        if byte == 34:
            return offset + 1
        if byte == 92:
            offset += 2
        else:
            offset += 1
    raise ValueError("unterminated string")


def scan_value(data: bytes, offset: int) -> int:
    offset = skip_ws(data, offset)
    byte = data[offset]
    if byte == 34:
        return scan_string(data, offset)
    if byte in (91, 123):
        close = 93 if byte == 91 else 125
        depth = 1
        offset += 1
        while depth:
            byte = data[offset]
            if byte == 34:
                offset = scan_string(data, offset)
            else:
                if byte == (91 if close == 93 else 123):
                    depth += 1
                elif byte == close:
                    depth -= 1
                offset += 1
        return offset
    while offset < len(data) and data[offset] not in b" \t\r\n,}":
        offset += 1
    return offset


def root_value_slices(document: str) -> list[tuple[int, int]]:
    data = document.encode()
    offset = skip_ws(data, 0)
    assert data[offset] == 123
    offset = skip_ws(data, offset + 1)
    slices = []
    while data[offset] != 125:
        offset = scan_string(data, offset)
        offset = skip_ws(data, offset)
        assert data[offset] == 58
        start = skip_ws(data, offset + 1)
        end = scan_value(data, start)
        slices.append((start, end))
        offset = skip_ws(data, end)
        if data[offset] == 44:
            offset = skip_ws(data, offset + 1)
        else:
            assert data[offset] == 125
    return slices


def source(document: str, comparison: Any) -> str:
    literal = comparison.dew_string_literal(document)
    slices = root_value_slices(document)
    fields = "\n".join(f"  field{index}: JsonValue" for index in range(len(slices)))
    parse_fields = []
    consume = []
    for index, (start, end) in enumerate(slices):
        parse_fields.append(
            f"""  let field{index} = match json_parse_retained(json_benchmark_document().view({start}u32, {end-start}u32).to_string()) {{
    Result::Ok(value) => value
    Result::Err(_) => JsonValue::Null
  }}"""
        )
        consume.append(f"  total = total + json_value_weight(value.field{index})")
    constructor = "\n".join(f"    field{index}: field{index}" for index in range(len(slices)))
    return f"""open dew.std.array
open dew.std.json
open dew.std.string

struct TypedRoot {{
{fields}
}}

fn json_benchmark_document() -> String {{
  {literal}
}}

fn json_value_weight(value: JsonValue) -> U32 {{
  match value {{
    JsonValue::Null => 1u32
    JsonValue::Bool(_) => 1u32
    JsonValue::Number(value) => value.byte_length()
    JsonValue::ValidatedNumber(value) => value.lexeme().byte_length()
    JsonValue::String(value) => value.byte_length()
    JsonValue::ValidatedString(value) => value.string().byte_length()
    JsonValue::Array(values) => values.length()
    JsonValue::Object(values) => values.length()
  }}
}}

fn decode_typed() -> TypedRoot {{
{chr(10).join(parse_fields)}
  TypedRoot {{
{constructor}
  }}
}}

fn typed_weight(value: TypedRoot) -> U32 {{
  let mut total = 0u32
{chr(10).join(consume)}
  total
}}

fn repeat(remaining: U32, total: U32) -> U32 {{
  if remaining == 0u32 {{
    total
  }} else {{
    repeat(remaining - 1u32, total + typed_weight(decode_typed()))
  }}
}}

pub fn decode(iterations: U32) -> U32 {{
  repeat(iterations, 0u32)
}}

pub fn expected() -> U32 {{
  typed_weight(decode_typed())
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
    comparison = load_comparison()
    specs = []
    for name in FIXTURES:
        document = comparison.extract_json_as_fixture(args.json_as_dir.resolve(), name)
        directory = TMP / name
        directory.mkdir(parents=True, exist_ok=True)
        source_path = directory / "benchmark.dew"
        source_path.write_text(source(document, comparison), encoding="utf-8")
        wasm = directory / "benchmark.wasm"
        run([str(ROOT/"tools"/"dew"),"build",str(source_path),"-o",str(wasm)], capture=True)
        specs.append({"name":name,"bytes":len(document.encode()),"wasm":str(wasm),"wasmBytes":wasm.stat().st_size})
    path=TMP/"specs.json";path.write_text(json.dumps(specs),encoding="utf-8")
    runner=r'''const fs=require('fs'),{performance}=require('perf_hooks');(async()=>{const ss=JSON.parse(fs.readFileSync(process.argv[1])),samples=+process.argv[2],rounds=+process.argv[3],target=+process.argv[4],out={};for(const s of ss){const i=(await WebAssembly.instantiate(fs.readFileSync(s.wasm),{})).instance,b=Math.max(1,Math.min(5000,Math.floor(target/s.bytes))),e=i.exports.expected();for(let w=0;w<30;w++)if(i.exports.decode(b)!==e*b)throw Error('bad');out[s.name]=[];for(let r=0;r<rounds;r++){let xs=[];for(let n=0;n<samples;n++){let t=performance.now(),a=i.exports.decode(b),ns=(performance.now()-t)*1e6/b;if(a!==e*b)throw Error('bad');xs.push(ns)}out[s.name].push(xs)}}process.stdout.write(JSON.stringify(out))})().catch(e=>{console.error(e);process.exit(1)})'''
    raw=json.loads(run(["node","-e",runner,str(path),str(args.samples),str(args.rounds),str(args.target_batch_bytes)],capture=True).stdout)
    fixtures={}
    for spec in specs:
        rounds=[statistics.median(row) for row in raw[spec['name']]]
        fixtures[spec['name']]={"ns_per_op":round(statistics.median(rounds),2),"wasm_bytes":spec['wasmBytes']}
    report={"environment":{"platform":platform.platform(),"node":run(["node","--version"],capture=True).stdout.strip()},"methodology":{"prototype":"generated fixed root schema using validated value slices","samples_per_round":args.samples,"rounds":args.rounds,"warmups":30},"fixtures":fixtures}
    encoded=json.dumps(report,indent=2,sort_keys=True)+"\n"
    if args.output:args.output.parent.mkdir(parents=True,exist_ok=True);args.output.write_text(encoded,encoding="utf-8")
    print(encoded,end="")

if __name__ == "__main__": main()
