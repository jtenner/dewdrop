#!/usr/bin/env python3
"""Measure Dew's packed private scalar-payload ABI against retained enum references."""

from __future__ import annotations

import argparse
import json
import statistics
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TMP = ROOT / ".tmp" / "scalar-payload-enum-abi-benchmark"


def program_source(cases: int, public_enum: bool) -> str:
    visibility = "pub " if public_enum else ""
    calls = " +\n    ".join(
        f"classify(Maybe::Some(value + {index})) + match choose(value + {index}) {{\n"
        "      Maybe::Some(item) => item\n"
        "      Maybe::None => 0\n"
        "    }"
        for index in range(cases)
    )
    return f"""{visibility}enum Maybe {{
  Some(I32)
  None
}}

fn choose(value: I32) -> Maybe {{
  Maybe::Some(value)
}}

fn classify(value: Maybe) -> I32 {{
  match value {{
    Maybe::Some(item) => item
    Maybe::None => 0
  }}
}}

pub fn main(value: I32) -> I32 {{
  {calls}
}}
"""


def build(name: str, source: str) -> Path:
    source_path = TMP / f"{name}.dew"
    wasm_path = TMP / f"{name}.wasm"
    source_path.write_text(source, encoding="utf-8")
    subprocess.run(
        [str(ROOT / "tools" / "dew"), "build", str(source_path), "-o", str(wasm_path)],
        cwd=ROOT,
        check=True,
        stdout=subprocess.DEVNULL,
    )
    return wasm_path


def measure(paths: list[Path], samples: int, batch: int, expected: int) -> dict[str, list[float]]:
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
        ["node", "-e", runner, str(samples), str(batch), str(expected), *(str(path) for path in paths)],
        cwd=ROOT,
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(completed.stdout)


def wat(path: Path) -> str:
    return subprocess.run(
        ["wasm-tools", "print", str(path)], check=True, capture_output=True, text=True,
    ).stdout


def counts(text: str) -> dict[str, int]:
    return {
        "struct_new": text.count("struct.new"),
        "struct_get": text.count("struct.get"),
        "ref_cast": text.count("ref.cast"),
        "call": text.count("call "),
        "i64_shl": text.count("i64.shl"),
        "i64_shr_u": text.count("i64.shr_u"),
        "i64_or": text.count("i64.or"),
        "i32_wrap_i64": text.count("i32.wrap_i64"),
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--cases", type=int, default=64)
    parser.add_argument("--samples", type=int, default=10000)
    parser.add_argument("--batch", type=int, default=100)
    args = parser.parse_args()
    if args.cases < 1 or args.samples < 1 or args.batch < 1:
        parser.error("cases, samples, and batch must be positive")
    TMP.mkdir(parents=True, exist_ok=True)
    retained = build("retained", program_source(args.cases, True))
    packed = build("packed", program_source(args.cases, False))
    expected = 2 * (args.cases * 41 + args.cases * (args.cases - 1) // 2)
    raw = measure([retained, packed], args.samples, args.batch, expected)
    retained_us = statistics.median(raw[str(retained)])
    packed_us = statistics.median(raw[str(packed)])
    print(json.dumps({
        "cases": args.cases,
        "samples": args.samples,
        "batch": args.batch,
        "retained_median_us": round(retained_us, 4),
        "packed_median_us": round(packed_us, 4),
        "packed_to_retained_ratio": round(packed_us / retained_us, 4),
        "retained_wasm_bytes": retained.stat().st_size,
        "packed_wasm_bytes": packed.stat().st_size,
        "retained": counts(wat(retained)),
        "packed": counts(wat(packed)),
    }, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
