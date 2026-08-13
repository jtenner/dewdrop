#!/usr/bin/env python3
"""Benchmark SIMD-backed dew.std.json parsing and compact serialization."""

from __future__ import annotations

import argparse
import json
import statistics
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TMP = ROOT / ".tmp" / "json-benchmark"


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


def payload(entries: int) -> str:
    values = [
        {
            "id": index,
            "enabled": index % 3 != 0,
            "name": f"entry-{index:04d}-0123456789abcdef-λ",
            "values": [index, -index, index / 10],
        }
        for index in range(entries)
    ]
    return json.dumps(values, ensure_ascii=False, separators=(",", ":"))


def source(document: str) -> str:
    literal = dew_string_literal(document)
    length = len(document.encode("utf-8"))
    return f"""open dew.std.json
open dew.std.string

pub fn main() -> U32 {{
  match json_parse({literal}) {{
    Result::Ok(value) => {{
      match json_stringify(value) {{
        Result::Ok(output) => output.byte_length()
        Result::Err(_) => 0u32
      }}
    }}
    Result::Err(_) => 0u32
  }}
}}

pub fn expected() -> U32 {{
  {length}u32
}}
"""


def build(document: str) -> Path:
    TMP.mkdir(parents=True, exist_ok=True)
    source_path = TMP / "benchmark.dew"
    wasm_path = TMP / "benchmark.wasm"
    source_path.write_text(source(document), encoding="utf-8")
    subprocess.run(
        [str(ROOT / "tools" / "dew"), "build", str(source_path), "-o", str(wasm_path)],
        cwd=ROOT,
        check=True,
        stdout=subprocess.DEVNULL,
    )
    return wasm_path


def measure(path: Path, expected: int, samples: int, batch: int) -> list[float]:
    runner = r"""
const fs = require('fs');
const { performance } = require('perf_hooks');
(async () => {
  const path = process.argv[1];
  const expected = Number(process.argv[2]);
  const samples = Number(process.argv[3]);
  const batch = Number(process.argv[4]);
  const { instance } = await WebAssembly.instantiate(fs.readFileSync(path), {});
  for (let i = 0; i < 100; i++) if (instance.exports.main() !== expected) throw new Error('bad JSON result');
  const values = [];
  for (let sample = 0; sample < samples; sample++) {
    const start = performance.now();
    for (let iteration = 0; iteration < batch; iteration++) {
      if (instance.exports.main() !== expected) throw new Error('bad JSON result');
    }
    values.push((performance.now() - start) * 1000 / batch);
  }
  process.stdout.write(JSON.stringify(values));
})().catch(error => { console.error(error); process.exit(1); });
"""
    completed = subprocess.run(
        ["node", "-e", runner, str(path), str(expected), str(samples), str(batch)],
        cwd=ROOT,
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(completed.stdout)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--entries", type=int, default=128)
    parser.add_argument("--samples", type=int, default=200)
    parser.add_argument("--batch", type=int, default=5)
    args = parser.parse_args()
    if args.entries < 1 or args.samples < 1 or args.batch < 1:
        parser.error("entries, samples, and batch must be positive")
    document = payload(args.entries)
    encoded_length = len(document.encode("utf-8"))
    path = build(document)
    values = measure(path, encoded_length, args.samples, args.batch)
    median_us = statistics.median(values)
    print(
        json.dumps(
            {
                "entries": args.entries,
                "input_bytes": encoded_length,
                "samples": args.samples,
                "batch": args.batch,
                "parse_and_stringify_median_us": round(median_us, 3),
                "parse_and_stringify_ns_per_input_byte": round(
                    median_us * 1000 / encoded_length, 3
                ),
                "wasm_bytes": path.stat().st_size,
            },
            indent=2,
            sort_keys=True,
        )
    )


if __name__ == "__main__":
    main()
