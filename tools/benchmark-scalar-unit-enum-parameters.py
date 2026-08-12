#!/usr/bin/env python3
"""Benchmark private scalar unit-enum parameters against retained reference parameters."""

from __future__ import annotations

import argparse
import json
import statistics
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TMP = ROOT / ".tmp" / "scalar-unit-enum-parameter-benchmark"


def source(cases: int, public: bool) -> str:
    visibility = "pub " if public else ""
    calls = " +\n    ".join(
        f"classify(State::{'Left' if index % 2 == 0 else 'Right'})"
        for index in range(cases)
    )
    return f"""{visibility}enum State {{
  Left
  Right
}}

fn classify(state: State) -> I32 {{
  match state {{
    State::Left => 1
    State::Right => 2
  }}
}}

pub fn main(value: I32) -> I32 {{
  {calls}
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
    paths: list[Path], samples: int, batch: int, expected: int,
) -> dict[str, list[float]]:
    runner = r"""
const fs = require('fs');
const { performance } = require('perf_hooks');
(async () => {
  const samples = Number(process.argv[1]);
  const batch = Number(process.argv[2]);
  const expected = Number(process.argv[3]);
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
        [
            "node",
            "-e",
            runner,
            str(samples),
            str(batch),
            str(expected),
            *(str(path) for path in paths),
        ],
        cwd=ROOT,
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(completed.stdout)


def wat(path: Path) -> str:
    return subprocess.run(
        ["wasm-tools", "print", str(path)],
        check=True,
        capture_output=True,
        text=True,
    ).stdout


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--cases", type=int, default=64)
    parser.add_argument("--samples", type=int, default=10000)
    parser.add_argument("--batch", type=int, default=100)
    args = parser.parse_args()
    if args.cases < 1 or args.samples < 1 or args.batch < 1:
        parser.error("cases, samples, and batch must be positive")
    TMP.mkdir(parents=True, exist_ok=True)
    scalar = build("scalar", source(args.cases, False))
    retained = build("retained", source(args.cases, True))
    expected = (args.cases + 1) // 2 + 2 * (args.cases // 2)
    raw = measure([scalar, retained], args.samples, args.batch, expected)
    scalar_us = statistics.median(raw[str(scalar)])
    retained_us = statistics.median(raw[str(retained)])
    scalar_wat = wat(scalar)
    retained_wat = wat(retained)
    print(json.dumps({
        "cases": args.cases,
        "samples": args.samples,
        "batch": args.batch,
        "scalar_median_us": round(scalar_us, 4),
        "retained_median_us": round(retained_us, 4),
        "scalar_to_retained_ratio": round(scalar_us / retained_us, 4),
        "scalar_wasm_bytes": scalar.stat().st_size,
        "retained_wasm_bytes": retained.stat().st_size,
        "scalar_struct_new": scalar_wat.count("struct.new"),
        "retained_struct_new": retained_wat.count("struct.new"),
        "scalar_struct_get": scalar_wat.count("struct.get"),
        "retained_struct_get": retained_wat.count("struct.get"),
        "scalar_ref_cast": scalar_wat.count("ref.cast"),
        "retained_ref_cast": retained_wat.count("ref.cast"),
    }, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
