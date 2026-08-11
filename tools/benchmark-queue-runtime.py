#!/usr/bin/env python3
"""Benchmark the contiguous FIFO queue baseline against LIFO Array removal."""

from __future__ import annotations

import argparse
import json
import statistics
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TMP = ROOT / ".tmp" / "queue-benchmark"


def source(count: int, queue: bool) -> str:
    if queue:
        open_line = "open dew.std.queue"
        make = "queue_new()"
        type_name = "Queue<I32>"
        push = "queue_enqueue(values, {value})"
        pop = "queue_dequeue(values)"
    else:
        open_line = "open dew.std.collections.stack"
        make = "stack_new()"
        type_name = "Stack<I32>"
        push = "stack_push(values, {value})"
        pop = "stack_pop(values)"
    pushes = "\n".join(f"  {push.format(value=i)}" for i in range(count))
    pops = "\n".join(
        f"  match {pop} {{\n    Option::Some(_) => {{}}\n    Option::None => unreachable()\n  }}"
        for _ in range(count)
    )
    return f"""{open_line}

fn make() -> {type_name} {{
  {make}
}}

pub fn main() -> I32 {{
  let values = make()
{pushes}
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
    queue = build("queue", source(args.count, True))
    stack = build("stack", source(args.count, False))
    raw = measure([queue, stack], args.samples)
    queue_us = statistics.median(raw[str(queue)])
    stack_us = statistics.median(raw[str(stack)])
    print(json.dumps({
        "count": args.count,
        "samples": args.samples,
        "queue_drain_median_us": round(queue_us, 3),
        "stack_drain_median_us": round(stack_us, 3),
        "contiguous_fifo_overhead_ratio": round(queue_us / stack_us, 4) if stack_us else None,
    }, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
