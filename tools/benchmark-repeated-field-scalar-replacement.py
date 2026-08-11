#!/usr/bin/env python3
"""Benchmark repeated-field scalar replacement against a retained mixed-field aggregate."""

from __future__ import annotations

import argparse
import json
import statistics
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TMP = ROOT / ".tmp" / "repeated-field-scalar-replacement-benchmark"


def source(repeated: bool, fields: int) -> str:
    projections = [
        "pair.right" if repeated or index % 2 else "pair.left"
        for index in range(fields)
    ]
    expression = " + ".join(projections)
    return f"""struct Pair {{
  left: I32
  right: I32
}}

pub fn main(value: I32) -> I32 {{
  let pair = Pair {{
    left: value
    right: value
  }}
  {expression}
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


def measure(paths: list[Path], expected: int, samples: int, batch: int) -> dict[str, list[float]]:
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
    for (let i = 0; i < 10000; i++) if (instance.exports.main(7) !== expected) throw new Error('bad result');
    instances.push(instance);
    report[path] = [];
  }
  for (let sample = 0; sample < samples; sample++) {
    for (let offset = 0; offset < paths.length; offset++) {
      const index = (sample + offset) % paths.length;
      const start = performance.now();
      for (let iteration = 0; iteration < batch; iteration++) {
        if (instances[index].exports.main(7) !== expected) throw new Error('bad result');
      }
      report[paths[index]].push((performance.now() - start) * 1000 / batch);
    }
  }
  process.stdout.write(JSON.stringify(report));
})().catch(error => { console.error(error); process.exit(1); });
"""
    completed = subprocess.run(
        ["node", "-e", runner, str(expected), str(samples), str(batch), *(str(path) for path in paths)],
        cwd=ROOT,
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(completed.stdout)


def count_wat(path: Path, instruction: str) -> int:
    wat = subprocess.run(
        ["wasm-tools", "print", str(path)],
        check=True,
        capture_output=True,
        text=True,
    ).stdout
    return wat.count(instruction)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--fields", type=int, default=64)
    parser.add_argument("--samples", type=int, default=10000)
    parser.add_argument("--batch", type=int, default=100)
    args = parser.parse_args()
    if args.fields < 2 or args.samples < 1 or args.batch < 1:
        parser.error("fields must be at least two; samples and batch must be positive")
    TMP.mkdir(parents=True, exist_ok=True)
    repeated = build("repeated", source(True, args.fields))
    mixed = build("mixed", source(False, args.fields))
    raw = measure([repeated, mixed], 7 * args.fields, args.samples, args.batch)
    repeated_median = statistics.median(raw[str(repeated)])
    mixed_median = statistics.median(raw[str(mixed)])
    print(json.dumps({
        "fields": args.fields,
        "samples": args.samples,
        "batch": args.batch,
        "repeated_median_us": round(repeated_median, 4),
        "mixed_median_us": round(mixed_median, 4),
        "ratio": round(repeated_median / mixed_median, 4),
        "repeated_wasm_bytes": repeated.stat().st_size,
        "mixed_wasm_bytes": mixed.stat().st_size,
        "repeated_struct_new": count_wat(repeated, "struct.new"),
        "repeated_struct_get": count_wat(repeated, "struct.get"),
        "mixed_struct_new": count_wat(mixed, "struct.new"),
        "mixed_struct_get": count_wat(mixed, "struct.get"),
    }, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
