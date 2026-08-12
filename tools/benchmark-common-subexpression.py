#!/usr/bin/env python3
"""Benchmark immutable scalar field CSE against an equivalent mutable-local baseline."""

from __future__ import annotations

import argparse
import json
import statistics
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TMP = ROOT / ".tmp" / "common-subexpression-benchmark"


def source(terms: int, iterations: int, mutable: bool) -> str:
    extractions = "\n".join(
        f"  let left{index} = pair.value\n  let right{index} = pair.value"
        for index in range(terms)
    )
    groups = " + ".join(f"(left{index} + right{index})" for index in range(terms))
    binding = "let mut pair = initial" if mutable else "let pair = initial"
    return f"""struct Pair {{
  value: I32
}}

fn calculate(initial: Pair) -> I32 {{
  {binding}
{extractions}
  {groups}
}}

fn repeat(pair: Pair, remaining: U32, total: I32) -> I32 {{
  if remaining == 0u32 {{
    total
  }} else {{
    repeat(pair, remaining - 1u32, total + calculate(pair))
  }}
}}

pub fn main() -> I32 {{
  repeat(Pair {{
    value: 1
  }}, {iterations}u32, 0)
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


def instruction_count(wasm: Path, instruction: str) -> int:
    completed = subprocess.run(
        ["wasm-tools", "print", str(wasm)],
        cwd=ROOT,
        check=True,
        capture_output=True,
        text=True,
    )
    return completed.stdout.count(instruction)


def nested_source(optimized: bool, pairs: int) -> str:
    reads = []
    for index in range(pairs):
        reads.append(f"  let cached{index} = inner.value")
        base = "outer.inner.value"
        if not optimized:
            base = f"retain(outer).inner.value"
        reads.append(f"  let nested{index} = {base}")
    total = " + ".join(
        value
        for index in range(pairs)
        for value in (f"cached{index}", f"nested{index}")
    )
    helper = "\nfn retain(value: Outer) -> Outer {\n  value\n}\n" if not optimized else ""
    return f"""struct Inner {{
  value: I32
}}

struct Outer {{
  inner: Inner
}}
{helper}
pub fn main() -> I32 {{
  let outer = Outer {{
    inner: Inner {{
      value: 7
    }}
  }}
  let inner = outer.inner
{chr(10).join(reads)}
  {total}
}}
"""


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--terms", type=int, default=64)
    parser.add_argument("--iterations", type=int, default=10000)
    parser.add_argument("--samples", type=int, default=1000)
    parser.add_argument("--batch", type=int, default=10)
    args = parser.parse_args()
    if args.terms < 1 or args.iterations < 1 or args.samples < 1 or args.batch < 1:
        parser.error("terms, iterations, samples, and batch must be positive")
    TMP.mkdir(parents=True, exist_ok=True)
    optimized = build("immutable-cse", source(args.terms, args.iterations, False))
    baseline = build("mutable-baseline", source(args.terms, args.iterations, True))
    raw = measure(
        [optimized, baseline],
        args.terms * 2 * args.iterations,
        args.samples,
        args.batch,
    )
    optimized_us = statistics.median(raw[str(optimized)])
    baseline_us = statistics.median(raw[str(baseline)])
    nested = build("nested-cse", nested_source(True, args.terms))
    nested_baseline = build(
        "nested-retained", nested_source(False, args.terms),
    )
    nested_raw = measure(
        [nested, nested_baseline],
        args.terms * 14,
        args.samples,
        args.batch,
    )
    nested_us = statistics.median(nested_raw[str(nested)])
    nested_baseline_us = statistics.median(nested_raw[str(nested_baseline)])
    print(json.dumps({
        "terms": args.terms,
        "iterations": args.iterations,
        "samples": args.samples,
        "batch": args.batch,
        "immutable_cse_median_us": round(optimized_us, 3),
        "mutable_baseline_median_us": round(baseline_us, 3),
        "cse_to_baseline_ratio": round(optimized_us / baseline_us, 4),
        "immutable_cse_wasm_bytes": optimized.stat().st_size,
        "mutable_baseline_wasm_bytes": baseline.stat().st_size,
        "immutable_cse_struct_gets": instruction_count(optimized, "struct.get"),
        "mutable_baseline_struct_gets": instruction_count(baseline, "struct.get"),
        "nested_cse_median_us": round(nested_us, 3),
        "nested_baseline_median_us": round(nested_baseline_us, 3),
        "nested_ratio": round(nested_us / nested_baseline_us, 4),
        "nested_cse_wasm_bytes": nested.stat().st_size,
        "nested_baseline_wasm_bytes": nested_baseline.stat().st_size,
        "nested_cse_struct_gets": instruction_count(nested, "struct.get"),
        "nested_baseline_struct_gets": instruction_count(
            nested_baseline, "struct.get",
        ),
    }, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
