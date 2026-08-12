#!/usr/bin/env python3
"""Benchmark ordered, reordered, and one-missing component scalar replacement."""

from __future__ import annotations

import argparse
import json
import statistics
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TMP = ROOT / ".tmp" / "component-scalar-replacement-benchmark"


def source(mode: str, fields: int) -> str:
    declarations = "\n".join(f"  f{index}: I32" for index in range(fields))
    initializers = "\n".join(
        f"    f{index}: {'0' if index == 0 else f'value + {index}'}"
        for index in range(fields)
    )
    order = list(range(fields))
    if mode == "reversed":
        order.reverse()
    elif mode == "missing":
        order = order[1:]
    aliases = "\n".join(
        f"  let value{index} = aggregate.f{index}" for index in order
    )
    total = " + ".join(f"value{index}" for index in order)
    helper = "\nfn retain(value: Aggregate) -> Aggregate {\n  value\n}\n" if mode == "retained" else ""
    constructor = "retain(Aggregate {" if mode == "retained" else "Aggregate {"
    close = "  })" if mode == "retained" else "  }"
    return f"""struct Aggregate {{
{declarations}
}}
{helper}
pub fn main(value: I32) -> I32 {{
  let aggregate = {constructor}
{initializers}
{close}
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
    ordered = build("ordered", source("ordered", args.fields))
    reversed_ = build("reversed", source("reversed", args.fields))
    missing = build("missing", source("missing", args.fields))
    retained = build("retained", source("retained", args.fields))
    expected = 7 * (args.fields - 1) + args.fields * (args.fields - 1) // 2
    raw = measure(
        [ordered, reversed_, missing, retained],
        expected,
        args.samples,
        args.batch,
    )
    ordered_median = statistics.median(raw[str(ordered)])
    reversed_median = statistics.median(raw[str(reversed_)])
    missing_median = statistics.median(raw[str(missing)])
    retained_median = statistics.median(raw[str(retained)])
    print(json.dumps({
        "fields": args.fields,
        "samples": args.samples,
        "batch": args.batch,
        "ordered_median_us": round(ordered_median, 4),
        "reversed_median_us": round(reversed_median, 4),
        "missing_median_us": round(missing_median, 4),
        "retained_median_us": round(retained_median, 4),
        "ordered_ratio": round(ordered_median / retained_median, 4),
        "reversed_ratio": round(reversed_median / retained_median, 4),
        "missing_ratio": round(missing_median / retained_median, 4),
        "ordered_wasm_bytes": ordered.stat().st_size,
        "reversed_wasm_bytes": reversed_.stat().st_size,
        "missing_wasm_bytes": missing.stat().st_size,
        "retained_wasm_bytes": retained.stat().st_size,
        "ordered_struct_new": wat_count(ordered, "struct.new"),
        "ordered_struct_get": wat_count(ordered, "struct.get"),
        "reversed_struct_new": wat_count(reversed_, "struct.new"),
        "reversed_struct_get": wat_count(reversed_, "struct.get"),
        "missing_struct_new": wat_count(missing, "struct.new"),
        "missing_struct_get": wat_count(missing, "struct.get"),
        "retained_struct_new": wat_count(retained, "struct.new"),
        "retained_struct_get": wat_count(retained, "struct.get"),
    }, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
