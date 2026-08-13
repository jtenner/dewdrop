#!/usr/bin/env python3
"""Benchmark strict JSON clean, escaped, Unicode, and malformed string paths."""

from __future__ import annotations

import argparse
import json
import platform
import statistics
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TMP = ROOT / ".tmp" / "json-string-benchmark"


def dew_string_literal(value: str) -> str:
    pieces: list[str] = []
    for byte in value.encode("utf-8"):
        if byte == 0x22:
            pieces.append('\\"')
        elif byte == 0x5C:
            pieces.append("\\\\")
        elif byte == 0x0A:
            pieces.append("\\n")
        elif byte == 0x0D:
            pieces.append("\\r")
        elif byte == 0x09:
            pieces.append("\\t")
        elif 0x20 <= byte <= 0x7E:
            pieces.append(chr(byte))
        else:
            pieces.append(f"\\x{byte:02X}")
    return '"' + "".join(pieces) + '"'


def source() -> str:
    clean = json.dumps({"value": "abcdefghijklmnopqrstuvwxyz0123456789" * 8}, separators=(",", ":"))
    escaped = '{"value":"' + ('line\\nquote\\"slash\\\\lambda\\u03bb' * 8) + '"}'
    unicode = json.dumps({"value": "λ世界🌍" * 32}, ensure_ascii=False, separators=(",", ":"))
    return f"""open dew.std.json
open dew.std.string

fn clean_document() -> String {{
  {dew_string_literal(clean)}
}}

fn escaped_document() -> String {{
  {dew_string_literal(escaped)}
}}

fn unicode_document() -> String {{
  {dew_string_literal(unicode)}
}}

fn repeat_clean_string(remaining: U32, total: U32) -> U32 {{
  if remaining == 0u32 {{
    total
  }} else {{
    match json_parse(clean_document()) {{
      Result::Ok(_) => repeat_clean_string(remaining - 1u32, total + 1u32)
      Result::Err(_) => total
    }}
  }}
}}

fn repeat_clean_bytes(remaining: U32, total: U32) -> U32 {{
  if remaining == 0u32 {{
    total
  }} else {{
    match json_parse_bytes(clean_document().as_bytes()) {{
      Result::Ok(_) => repeat_clean_bytes(remaining - 1u32, total + 1u32)
      Result::Err(_) => total
    }}
  }}
}}

fn repeat_escaped_string(remaining: U32, total: U32) -> U32 {{
  if remaining == 0u32 {{
    total
  }} else {{
    match json_parse(escaped_document()) {{
      Result::Ok(_) => repeat_escaped_string(remaining - 1u32, total + 1u32)
      Result::Err(_) => total
    }}
  }}
}}

fn repeat_unicode_string(remaining: U32, total: U32) -> U32 {{
  if remaining == 0u32 {{
    total
  }} else {{
    match json_parse(unicode_document()) {{
      Result::Ok(_) => repeat_unicode_string(remaining - 1u32, total + 1u32)
      Result::Err(_) => total
    }}
  }}
}}

fn repeat_malformed_bytes(remaining: U32, total: U32) -> U32 {{
  if remaining == 0u32 {{
    total
  }} else {{
    match json_parse_bytes(b"{{\\\"value\\\":\\\"\\xFF\\\"}}") {{
      Result::Err(JsonParseError::InvalidUtf8) =>
        repeat_malformed_bytes(remaining - 1u32, total + 1u32)
      _ => total
    }}
  }}
}}

pub fn clean_string(iterations: U32) -> U32 {{
  repeat_clean_string(iterations, 0u32)
}}

pub fn clean_bytes(iterations: U32) -> U32 {{
  repeat_clean_bytes(iterations, 0u32)
}}

pub fn escaped_string(iterations: U32) -> U32 {{
  repeat_escaped_string(iterations, 0u32)
}}

pub fn unicode_string(iterations: U32) -> U32 {{
  repeat_unicode_string(iterations, 0u32)
}}

pub fn malformed_bytes(iterations: U32) -> U32 {{
  repeat_malformed_bytes(iterations, 0u32)
}}
"""


def run(command: list[str], *, capture: bool = False) -> subprocess.CompletedProcess[str]:
    return subprocess.run(command, cwd=ROOT, check=True, text=True, capture_output=capture)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--samples", type=int, default=101)
    parser.add_argument("--iterations", type=int, default=512)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    if args.samples < 4 or args.iterations < 1:
        parser.error("samples must be at least 4 and iterations must be positive")
    TMP.mkdir(parents=True, exist_ok=True)
    source_path = TMP / "benchmark.dew"
    wasm_path = TMP / "benchmark.wasm"
    source_path.write_text(source(), encoding="utf-8")
    run([str(ROOT / "tools" / "dew"), "build", str(source_path), "-o", str(wasm_path)], capture=True)
    runner = r"""
const fs = require('fs');
const { performance } = require('perf_hooks');
(async () => {
  const wasm = process.argv[1];
  const samples = Number(process.argv[2]);
  const iterations = Number(process.argv[3]);
  const operations = ['clean_string', 'clean_bytes', 'escaped_string', 'unicode_string', 'malformed_bytes'];
  const { instance } = await WebAssembly.instantiate(fs.readFileSync(wasm), {});
  for (const operation of operations) {
    for (let warmup = 0; warmup < 30; warmup++) {
      if (instance.exports[operation](iterations) !== iterations) throw new Error(`bad ${operation} warmup`);
    }
  }
  const values = Object.fromEntries(operations.map(operation => [operation, []]));
  for (let sample = 0; sample < samples; sample++) {
    for (let offset = 0; offset < operations.length; offset++) {
      const operation = operations[(sample + offset) % operations.length];
      const start = performance.now();
      const actual = instance.exports[operation](iterations);
      const ns = (performance.now() - start) * 1e6 / iterations;
      if (actual !== iterations) throw new Error(`bad ${operation}`);
      values[operation].push(ns);
    }
  }
  process.stdout.write(JSON.stringify(values));
})().catch(error => { console.error(error); process.exit(1); });
"""
    raw = json.loads(run(["node", "-e", runner, str(wasm_path), str(args.samples), str(args.iterations)], capture=True).stdout)
    operations: dict[str, dict[str, float]] = {}
    for name, values in raw.items():
        operations[name] = {
            "median_ns_per_op": round(statistics.median(values), 2),
            "p25_ns_per_op": round(statistics.quantiles(values, n=4)[0], 2),
            "p75_ns_per_op": round(statistics.quantiles(values, n=4)[2], 2),
        }
    report = {
        "methodology": {"samples": args.samples, "iterations_per_sample": args.iterations, "warmups": 30},
        "environment": {
            "platform": platform.platform(),
            "machine": platform.machine(),
            "node": run(["node", "--version"], capture=True).stdout.strip(),
            "dew_revision": run(["git", "rev-parse", "HEAD"], capture=True).stdout.strip(),
        },
        "wasm_bytes": wasm_path.stat().st_size,
        "operations": operations,
    }
    encoded = json.dumps(report, indent=2, sort_keys=True) + "\n"
    if args.output is not None:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(encoded, encoding="utf-8")
    print(encoded, end="")


if __name__ == "__main__":
    main()
