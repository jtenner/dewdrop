#!/usr/bin/env python3
"""Benchmark deterministic physical local-slot reuse against retained locals."""

from __future__ import annotations

import argparse
import json
import statistics
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TMP = ROOT / ".tmp" / "physical-local-reuse-benchmark"


def source(locals_: int, mutable: bool) -> str:
    lines = ["  let value0 = value + 1"]
    for index in range(1, locals_):
        binding = "let mut" if mutable else "let"
        lines.append(f"  {binding} value{index} = value{index - 1} + 1")
    return f"""pub fn main(value: I32) -> I32 {{
{chr(10).join(lines)}
  value{locals_ - 1}
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
    for (let i = 0; i < 10000; i++) if (instance.exports.main(41) !== expected) throw new Error('bad result');
    instances.push(instance);
    report[path] = [];
  }
  for (let sample = 0; sample < samples; sample++) {
    for (let offset = 0; offset < paths.length; offset++) {
      const index = (sample + offset) % paths.length;
      const start = performance.now();
      for (let iteration = 0; iteration < batch; iteration++) {
        if (instances[index].exports.main(41) !== expected) throw new Error('bad result');
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


def wat_metrics(path: Path) -> dict[str, int]:
    wat = subprocess.run(
        ["wasm-tools", "print", str(path)],
        check=True,
        capture_output=True,
        text=True,
    ).stdout
    local_line = next(
        (line.strip() for line in wat.splitlines() if line.strip().startswith("(local ")),
        "",
    )
    return {
        "physical_locals": max(len(local_line.split()) - 1, 0),
        "local_get": wat.count("local.get"),
        "local_set": wat.count("local.set"),
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--locals", type=int, default=64)
    parser.add_argument("--samples", type=int, default=10000)
    parser.add_argument("--batch", type=int, default=100)
    args = parser.parse_args()
    if args.locals < 2 or args.samples < 1 or args.batch < 1:
        parser.error("locals must be at least two; samples and batch must be positive")
    TMP.mkdir(parents=True, exist_ok=True)
    reused = build("reused", source(args.locals, False))
    retained = build("retained", source(args.locals, True))
    expected = 41 + args.locals
    raw = measure([reused, retained], expected, args.samples, args.batch)
    reused_us = statistics.median(raw[str(reused)])
    retained_us = statistics.median(raw[str(retained)])
    print(json.dumps({
        "locals": args.locals,
        "samples": args.samples,
        "batch": args.batch,
        "reused_median_us": round(reused_us, 4),
        "retained_median_us": round(retained_us, 4),
        "ratio": round(reused_us / retained_us, 4),
        "reused_wasm_bytes": reused.stat().st_size,
        "retained_wasm_bytes": retained.stat().st_size,
        "reused": wat_metrics(reused),
        "retained": wat_metrics(retained),
    }, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
