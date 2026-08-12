#!/usr/bin/env python3
"""Benchmark immutable local alias coalescing against mutable alias storage."""

from __future__ import annotations

import argparse
import json
import statistics
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TMP = ROOT / ".tmp" / "local-lifetime-coalescing-benchmark"


def source(aliases: int, mutable: bool) -> str:
    lines = ["  let value0 = value + 1"]
    for index in range(1, aliases + 1):
        binding = "let mut" if mutable else "let"
        lines.append(f"  {binding} value{index} = value{index - 1}")
    return f"""pub fn main(value: I32) -> I32 {{
{chr(10).join(lines)}
  value{aliases}
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


def measure(paths: list[Path], samples: int, batch: int) -> dict[str, list[float]]:
    runner = r"""
const fs = require('fs');
const { performance } = require('perf_hooks');
(async () => {
  const samples = Number(process.argv[1]);
  const batch = Number(process.argv[2]);
  const paths = process.argv.slice(3);
  const instances = [];
  const report = {};
  for (const path of paths) {
    const { instance } = await WebAssembly.instantiate(fs.readFileSync(path), {});
    for (let i = 0; i < 10000; i++) if (instance.exports.main(41) !== 42) throw new Error('bad result');
    instances.push(instance);
    report[path] = [];
  }
  for (let sample = 0; sample < samples; sample++) {
    for (let offset = 0; offset < paths.length; offset++) {
      const index = (sample + offset) % paths.length;
      const start = performance.now();
      for (let iteration = 0; iteration < batch; iteration++) {
        if (instances[index].exports.main(41) !== 42) throw new Error('bad result');
      }
      report[paths[index]].push((performance.now() - start) * 1000 / batch);
    }
  }
  process.stdout.write(JSON.stringify(report));
})().catch(error => { console.error(error); process.exit(1); });
"""
    completed = subprocess.run(
        ["node", "-e", runner, str(samples), str(batch), *(str(path) for path in paths)],
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
    parser.add_argument("--aliases", type=int, default=64)
    parser.add_argument("--samples", type=int, default=10000)
    parser.add_argument("--batch", type=int, default=100)
    args = parser.parse_args()
    if args.aliases < 1 or args.samples < 1 or args.batch < 1:
        parser.error("aliases, samples, and batch must be positive")
    TMP.mkdir(parents=True, exist_ok=True)
    coalesced = build("coalesced", source(args.aliases, False))
    retained = build("retained", source(args.aliases, True))
    raw = measure([coalesced, retained], args.samples, args.batch)
    coalesced_us = statistics.median(raw[str(coalesced)])
    retained_us = statistics.median(raw[str(retained)])
    print(json.dumps({
        "aliases": args.aliases,
        "samples": args.samples,
        "batch": args.batch,
        "coalesced_median_us": round(coalesced_us, 4),
        "retained_median_us": round(retained_us, 4),
        "ratio": round(coalesced_us / retained_us, 4),
        "coalesced_wasm_bytes": coalesced.stat().st_size,
        "retained_wasm_bytes": retained.stat().st_size,
        "coalesced_local_get": wat_count(coalesced, "local.get"),
        "coalesced_local_set": wat_count(coalesced, "local.set"),
        "retained_local_get": wat_count(retained, "local.get"),
        "retained_local_set": wat_count(retained, "local.set"),
    }, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
