#!/usr/bin/env python3
"""Benchmark exact nonescaping trait flow against direct static dispatch."""

from __future__ import annotations

import argparse
import json
import statistics
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TMP = ROOT / ".tmp" / "trait-object-escape-benchmark"

EXACT = """trait Value {
  fn value(self) -> I32
}

struct Number {
  stored: I32
}

impl Value for Number {
  fn value(self) -> I32 {
    self.stored
  }
}

fn identity(value: Value) -> Value {
  value
}

fn invoke(value: Value) -> I32 {
  value.value()
}

pub fn main(value: I32) -> I32 {
  invoke(identity(Number {
    stored: value
  }))
}
"""

DIRECT = """trait Value {
  fn value(self) -> I32
}

struct Number {
  stored: I32
}

impl Value for Number {
  fn value(self) -> I32 {
    self.stored
  }
}

pub fn main(value: I32) -> I32 {
  Number {
    stored: value
  }.value()
}
"""


def build(name: str, text: str) -> Path:
    source = TMP / f"{name}.dew"
    wasm = TMP / f"{name}.wasm"
    source.write_text(text, encoding="utf-8")
    subprocess.run(
        [str(ROOT / "tools" / "dew"), "build", str(source), "-o", str(wasm)],
        cwd=ROOT,
        check=True,
        stdout=subprocess.DEVNULL,
    )
    return wasm


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
    for (let i = 0; i < 10000; i++) if (instance.exports.main(7) !== 7) throw new Error('bad result');
    instances.push(instance);
    report[path] = [];
  }
  for (let sample = 0; sample < samples; sample++) {
    for (let offset = 0; offset < paths.length; offset++) {
      const index = (sample + offset) % paths.length;
      const start = performance.now();
      for (let iteration = 0; iteration < batch; iteration++) {
        if (instances[index].exports.main(7) !== 7) throw new Error('bad result');
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
    parser.add_argument("--samples", type=int, default=10000)
    parser.add_argument("--batch", type=int, default=100)
    args = parser.parse_args()
    if args.samples < 1 or args.batch < 1:
        parser.error("samples and batch must be positive")
    TMP.mkdir(parents=True, exist_ok=True)
    exact = build("exact", EXACT)
    direct = build("direct", DIRECT)
    raw = measure([exact, direct], args.samples, args.batch)
    exact_median = statistics.median(raw[str(exact)])
    direct_median = statistics.median(raw[str(direct)])
    print(json.dumps({
        "samples": args.samples,
        "batch": args.batch,
        "exact_median_us": round(exact_median, 4),
        "direct_median_us": round(direct_median, 4),
        "ratio": round(exact_median / direct_median, 4),
        "exact_wasm_bytes": exact.stat().st_size,
        "direct_wasm_bytes": direct.stat().st_size,
        "exact_struct_new": wat_count(exact, "struct.new"),
        "exact_call_ref": wat_count(exact, "call_ref"),
        "exact_ref_func": wat_count(exact, "ref.func"),
        "direct_struct_new": wat_count(direct, "struct.new"),
        "direct_call_ref": wat_count(direct, "call_ref"),
        "direct_ref_func": wat_count(direct, "ref.func"),
    }, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
