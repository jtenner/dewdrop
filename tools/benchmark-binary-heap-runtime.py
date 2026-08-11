#!/usr/bin/env python3
"""Benchmark repeated BinaryHeap insertion against Floyd heap construction."""

from __future__ import annotations

import argparse
import json
import statistics
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TMP = ROOT / ".tmp" / "binary-heap-benchmark"


def source(count: int, floyd: bool) -> str:
    values = [((index * 1103515245 + 12345) >> 8) % (count * 4 + 1) for index in range(count)]
    pushes = "\n".join(f"  array_push(source, {value})" for value in values)
    if floyd:
        build = "  let heap = binary_heap_from_array(natural_comparator(), HeapOrder::Minimum, source)"
    else:
        repeated = "\n".join(f"  binary_heap_push(heap, {value})" for value in values)
        build = (
            "  let heap = binary_heap_with_capacity(natural_comparator(), HeapOrder::Minimum, "
            f"{count}u32)\n{repeated}"
        )
        pushes = ""
    pops = "\n".join(
        "  match binary_heap_pop(heap) {\n"
        "    Option::Some(_) => {}\n"
        "    Option::None => unreachable()\n"
        "  }"
        for _ in range(count)
    )
    source_setup = "  let source = array_with_capacity(" + str(count) + "u32)\n" + pushes if floyd else ""
    return f"""open dew.std.array
open dew.std.ordering
open dew.std.collections.binary_heap

pub fn main() -> I32 {{
{source_setup}
{build}
{pops}
  1
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
    for (let i = 0; i < 20; i++) instance.exports.main();
    const values = [];
    for (let i = 0; i < samples; i++) {
      const start = performance.now();
      if (instance.exports.main() !== 1) throw new Error('unexpected result');
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
    parser.add_argument("--count", type=int, default=128)
    parser.add_argument("--samples", type=int, default=200)
    args = parser.parse_args()
    if args.count < 1 or args.samples < 1:
        parser.error("--count and --samples must be positive")
    TMP.mkdir(parents=True, exist_ok=True)
    repeated = build("repeated", source(args.count, False))
    floyd = build("floyd", source(args.count, True))
    raw = measure([repeated, floyd], args.samples)
    repeated_us = statistics.median(raw[str(repeated)])
    floyd_us = statistics.median(raw[str(floyd)])
    print(json.dumps({
        "count": args.count,
        "samples": args.samples,
        "repeated_push_drain_median_us": round(repeated_us, 3),
        "floyd_build_drain_median_us": round(floyd_us, 3),
        "floyd_ratio": round(floyd_us / repeated_us, 4) if repeated_us else None,
    }, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
