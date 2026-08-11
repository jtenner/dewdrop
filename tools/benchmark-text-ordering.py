#!/usr/bin/env python3
"""Benchmark deterministic lexicographic String, StringView, and Bytes comparators."""

from __future__ import annotations

import argparse
import json
import statistics
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TMP = ROOT / ".tmp" / "text-ordering-benchmark"


def source(kind: str, length: int, iterations: int) -> str:
    left = "a" * length
    right = "a" * (length - 1) + "b"
    if kind == "string":
        setup = f'let left = "{left}"\n  let right = "{right}"\n  let comparator = string_comparator()'
    elif kind == "view":
        setup = (
            f'let left_source = "0{left}1"\n'
            f'  let right_source = "0{right}1"\n'
            f'  let left = left_source.view(1u32, {length}u32)\n'
            f'  let right = right_source.view(1u32, {length}u32)\n'
            '  let comparator = string_view_comparator()'
        )
    else:
        setup = (
            f'let left = "{left}".as_bytes()\n'
            f'  let right = "{right}".as_bytes()\n'
            '  let comparator = bytes_comparator()'
        )
    return f"""open dew.std.ordering
open dew.std.string
open dew.std.bytes

pub fn main() -> U32 {{
  {setup}
  while 0u32 {{
    index if index < {iterations}u32 => if ordering_is_less(comparator.compare(left, right)) {{
      continue index + 1u32
    }} else {{
      break 4294967295u32
    }}
    _ => break {iterations}u32
  }}
}}
"""


def build(kind: str, text: str) -> Path:
    source_path = TMP / f"{kind}.dew"
    wasm_path = TMP / f"{kind}.wasm"
    source_path.write_text(text, encoding="utf-8")
    subprocess.run(
        [str(ROOT / "tools" / "dew"), "build", str(source_path), "-o", str(wasm_path)],
        cwd=ROOT,
        check=True,
        stdout=subprocess.DEVNULL,
    )
    return wasm_path


def measure(
    paths: list[Path], expected: int, samples: int, batch: int
) -> dict[str, list[float]]:
    runner = r"""
const fs = require('fs');
const { performance } = require('perf_hooks');
(async () => {
  const expected = Number(process.argv[1]);
  const samples = Number(process.argv[2]);
  const batch = Number(process.argv[3]);
  const paths = process.argv.slice(4);
  const instances = [];
  const report = {};
  for (const path of paths) {
    const { instance } = await WebAssembly.instantiate(fs.readFileSync(path), {});
    for (let i = 0; i < 1000; i++) if (instance.exports.main() !== expected) throw new Error('bad result');
    instances.push(instance);
    report[path] = [];
  }
  for (let sample = 0; sample < samples; sample++) {
    for (let offset = 0; offset < paths.length; offset++) {
      const index = (sample + offset) % paths.length;
      const start = performance.now();
      for (let iteration = 0; iteration < batch; iteration++) {
        if (instances[index].exports.main() !== expected) throw new Error('bad result');
      }
      report[paths[index]].push((performance.now() - start) * 1000 / batch);
    }
  }
  process.stdout.write(JSON.stringify(report));
})().catch(error => { console.error(error); process.exit(1); });
"""
    completed = subprocess.run(
        [
            "node", "-e", runner, str(expected), str(samples), str(batch),
            *(str(path) for path in paths),
        ],
        cwd=ROOT,
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(completed.stdout)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--length", type=int, default=256)
    parser.add_argument("--iterations", type=int, default=1000)
    parser.add_argument("--samples", type=int, default=1000)
    parser.add_argument("--batch", type=int, default=10)
    args = parser.parse_args()
    if args.length < 1 or args.iterations < 1 or args.samples < 1 or args.batch < 1:
        parser.error("length, iterations, samples, and batch must be positive")
    TMP.mkdir(parents=True, exist_ok=True)
    paths = {
        kind: build(kind, source(kind, args.length, args.iterations))
        for kind in ("string", "view", "bytes")
    }
    raw = measure(list(paths.values()), args.iterations, args.samples, args.batch)
    print(json.dumps({
        "length": args.length,
        "iterations": args.iterations,
        "samples": args.samples,
        "batch": args.batch,
        **{
            f"{kind}_median_us": round(statistics.median(raw[str(path)]), 3)
            for kind, path in paths.items()
        },
        **{f"{kind}_wasm_bytes": path.stat().st_size for kind, path in paths.items()},
    }, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
