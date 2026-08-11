#!/usr/bin/env python3
"""Benchmark allocation-free String, StringView, and Bytes hashing."""

from __future__ import annotations

import argparse
import json
import statistics
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TMP = ROOT / ".tmp" / "text-hash-benchmark"


def payload(length: int) -> bytes:
    pattern = "dew-λ-".encode("utf-8")
    return (pattern * ((length + len(pattern) - 1) // len(pattern)))[:length]


def dew_literal(data: bytes, bytes_: bool) -> str:
    escaped = []
    for byte in data:
        if byte == 0x22:
            escaped.append('\\"')
        elif byte == 0x5C:
            escaped.append("\\\\")
        elif 0x20 <= byte <= 0x7E:
            escaped.append(chr(byte))
        else:
            escaped.append(f"\\x{byte:02X}")
    return ("b" if bytes_ else "") + '"' + "".join(escaped) + '"'


def fnv1a(data: bytes) -> int:
    value = 14695981039346656037
    for byte in data:
        value = ((value ^ byte) * 1099511628211) & ((1 << 64) - 1)
    return value


def source(data: bytes, kind: str) -> str:
    expected = fnv1a(data)
    if kind == "string":
        imports = "open dew.std.string"
        value = dew_literal(data, False)
    elif kind == "view":
        imports = "open dew.std.string"
        wrapped = b"x" + data + b"y"
        value = f"{dew_literal(wrapped, False)}.view(1u32, {len(data)}u32)"
    else:
        imports = "open dew.std.bytes"
        value = dew_literal(data, True)
    return f"""{imports}

pub fn main() -> I32 {{
  if {value}.hash() == {expected}u64 {{
    1
  }} else {{
    0
  }}
}}
"""


def build(name: str, text: str) -> Path:
    source_path = TMP / f"{name}.dew"
    wasm_path = TMP / f"{name}.wasm"
    source_path.write_text(text, encoding="utf-8")
    subprocess.run(
        [str(ROOT / "tools" / "dew"), "build", str(source_path), "-o", str(wasm_path)],
        cwd=ROOT,
        check=True,
        stdout=subprocess.DEVNULL,
    )
    return wasm_path


def measure(paths: list[Path], samples: int) -> dict[str, list[float]]:
    runner = r"""
const fs = require('fs');
const { performance } = require('perf_hooks');
(async () => {
  const samples = Number(process.argv[1]);
  const report = {};
  for (const path of process.argv.slice(2)) {
    const { instance } = await WebAssembly.instantiate(fs.readFileSync(path), {});
    for (let i = 0; i < 100; i++) if (instance.exports.main() !== 1) throw new Error('bad hash');
    const values = [];
    for (let i = 0; i < samples; i++) {
      const start = performance.now();
      if (instance.exports.main() !== 1) throw new Error('bad hash');
      values.push((performance.now() - start) * 1000);
    }
    report[path] = values;
  }
  process.stdout.write(JSON.stringify(report));
})().catch(error => { console.error(error); process.exit(1); });
"""
    completed = subprocess.run(
        ["node", "-e", runner, str(samples), *(str(path) for path in paths)],
        cwd=ROOT,
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(completed.stdout)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--length", type=int, default=256)
    parser.add_argument("--samples", type=int, default=500)
    args = parser.parse_args()
    if args.length < 0 or args.samples < 1:
        parser.error("--length must be nonnegative and --samples must be positive")
    TMP.mkdir(parents=True, exist_ok=True)
    data = payload(args.length)
    paths = {
        kind: build(kind, source(data, kind))
        for kind in ("string", "view", "bytes")
    }
    raw = measure(list(paths.values()), args.samples)
    medians = {
        kind: statistics.median(raw[str(path)])
        for kind, path in paths.items()
    }
    print(json.dumps({
        "length": args.length,
        "samples": args.samples,
        "string_median_us": round(medians["string"], 3),
        "string_view_median_us": round(medians["view"], 3),
        "bytes_median_us": round(medians["bytes"], 3),
        "wasm_bytes": {kind: path.stat().st_size for kind, path in paths.items()},
    }, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
