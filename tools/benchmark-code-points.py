#!/usr/bin/env python3
"""Benchmark allocation-bounded UTF-8 scalar iteration for String and StringView."""

from __future__ import annotations

import argparse
import json
import statistics
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TMP = ROOT / ".tmp" / "code-points-benchmark"


def benchmark_value(kind: str, scalars: int) -> tuple[str, int]:
    if kind.endswith("ascii"):
        value = "A" * scalars
    else:
        unit = "$¢€𐍈"
        value = (unit * ((scalars + 3) // 4))[:scalars]
    return value, sum(ord(character) for character in value)


def source(kind: str, scalars: int) -> tuple[str, int]:
    value, expected = benchmark_value(kind, scalars)
    if kind.startswith("string-"):
        setup = f'let points = "{value}".code_points()'
    else:
        byte_length = len(value.encode("utf-8"))
        setup = (
            f'let source = "0{value}1"\n'
            f'  let points = source.view(1u32, {byte_length}u32).code_points()'
        )
    return f"""open dew.std.string
open dew.std.text

pub fn main() -> U32 {{
  {setup}
  while 0u32 {{
    total if points.has_next() => continue total + points.next()
    total => break total
  }}
}}
""", expected


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
    entries: list[tuple[Path, int]], samples: int, batch: int
) -> dict[str, list[float]]:
    runner = r"""
const fs = require('fs');
const { performance } = require('perf_hooks');
(async () => {
  const samples = Number(process.argv[1]);
  const batch = Number(process.argv[2]);
  const specs = JSON.parse(process.argv[3]);
  const instances = [];
  const report = {};
  for (const spec of specs) {
    const { instance } = await WebAssembly.instantiate(fs.readFileSync(spec.path), {});
    for (let i = 0; i < 1000; i++) if (instance.exports.main() !== spec.expected) throw new Error('bad result');
    instances.push(instance);
    report[spec.path] = [];
  }
  for (let sample = 0; sample < samples; sample++) {
    for (let offset = 0; offset < specs.length; offset++) {
      const index = (sample + offset) % specs.length;
      const start = performance.now();
      for (let iteration = 0; iteration < batch; iteration++) {
        if (instances[index].exports.main() !== specs[index].expected) throw new Error('bad result');
      }
      report[specs[index].path].push((performance.now() - start) * 1000 / batch);
    }
  }
  process.stdout.write(JSON.stringify(report));
})().catch(error => { console.error(error); process.exit(1); });
"""
    specs = [{"path": str(path), "expected": expected} for path, expected in entries]
    completed = subprocess.run(
        ["node", "-e", runner, str(samples), str(batch), json.dumps(specs)],
        cwd=ROOT,
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(completed.stdout)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--scalars", type=int, default=256)
    parser.add_argument("--samples", type=int, default=2000)
    parser.add_argument("--batch", type=int, default=20)
    args = parser.parse_args()
    if args.scalars < 1 or args.samples < 1 or args.batch < 1:
        parser.error("scalars, samples, and batch must be positive")
    TMP.mkdir(parents=True, exist_ok=True)
    kinds = ("string-ascii", "view-ascii", "string-mixed", "view-mixed")
    paths: dict[str, Path] = {}
    expected: dict[str, int] = {}
    for kind in kinds:
        text, result = source(kind, args.scalars)
        paths[kind] = build(kind, text)
        expected[kind] = result
    raw = measure(
        [(paths[kind], expected[kind]) for kind in kinds],
        args.samples,
        args.batch,
    )
    medians = {
        kind: statistics.median(raw[str(paths[kind])]) for kind in kinds
    }
    print(json.dumps({
        "scalars": args.scalars,
        "samples": args.samples,
        "batch": args.batch,
        **{
            f"{kind.replace('-', '_')}_median_us": round(medians[kind], 3)
            for kind in kinds
        },
        **{
            f"{kind.replace('-', '_')}_ns_per_scalar": round(
                medians[kind] * 1000 / args.scalars, 3
            )
            for kind in kinds
        },
        **{
            f"{kind.replace('-', '_')}_wasm_bytes": paths[kind].stat().st_size
            for kind in kinds
        },
    }, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
