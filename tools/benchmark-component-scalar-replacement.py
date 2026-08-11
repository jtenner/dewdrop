#!/usr/bin/env python3
"""Benchmark ordered component-local scalar replacement against reversed extraction."""

from __future__ import annotations

import argparse
import json
import statistics
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TMP = ROOT / ".tmp" / "component-scalar-replacement-benchmark"


def source(ordered: bool, fields: int) -> str:
    declarations = "\n".join(f"  f{index}: I32" for index in range(fields))
    initializers = "\n".join(
        f"    f{index}: value + {index}" for index in range(fields)
    )
    order = list(range(fields))
    if not ordered:
        order.reverse()
    aliases = "\n".join(
        f"  let value{index} = aggregate.f{index}" for index in order
    )
    total = " + ".join(f"value{index}" for index in range(fields))
    return f"""struct Aggregate {{
{declarations}
}}

pub fn main(value: I32) -> I32 {{
  let aggregate = Aggregate {{
{initializers}
  }}
{aliases}
  {total}
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


def wat_count(path: Path, instruction: str) -> int:
    wat = subprocess.run(
        ["wasm-tools", "print", str(path)],
        check=True,
        capture_output=True,
        text=True,
    ).stdout
    return wat.count(instruction)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--fields", type=int, default=32)
    parser.add_argument("--samples", type=int, default=10000)
    parser.add_argument("--batch", type=int, default=100)
    args = parser.parse_args()
    if args.fields < 2 or args.samples < 1 or args.batch < 1:
        parser.error("fields must be at least two; samples and batch must be positive")
    TMP.mkdir(parents=True, exist_ok=True)
    ordered = build("ordered", source(True, args.fields))
    reversed_ = build("reversed", source(False, args.fields))
    expected = 7 * args.fields + args.fields * (args.fields - 1) // 2
    raw = measure([ordered, reversed_], expected, args.samples, args.batch)
    ordered_median = statistics.median(raw[str(ordered)])
    reversed_median = statistics.median(raw[str(reversed_)])
    print(json.dumps({
        "fields": args.fields,
        "samples": args.samples,
        "batch": args.batch,
        "ordered_median_us": round(ordered_median, 4),
        "reversed_median_us": round(reversed_median, 4),
        "ratio": round(ordered_median / reversed_median, 4),
        "ordered_wasm_bytes": ordered.stat().st_size,
        "reversed_wasm_bytes": reversed_.stat().st_size,
        "ordered_struct_new": wat_count(ordered, "struct.new"),
        "ordered_struct_get": wat_count(ordered, "struct.get"),
        "reversed_struct_new": wat_count(reversed_, "struct.new"),
        "reversed_struct_get": wat_count(reversed_, "struct.get"),
    }, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
