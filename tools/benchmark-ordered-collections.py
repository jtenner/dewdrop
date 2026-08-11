#!/usr/bin/env python3
"""Benchmark ordered map/set workloads against hash map/set baselines."""

from __future__ import annotations

import argparse
import json
import statistics
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TMP = ROOT / ".tmp" / "ordered-collections-benchmark"


def keys(count: int) -> list[int]:
    values = list(range(count))
    state = 0x9E3779B9
    for index in range(count - 1, 0, -1):
        state = (state * 1664525 + 1013904223) & 0xFFFFFFFF
        other = state % (index + 1)
        values[index], values[other] = values[other], values[index]
    return values


def map_source(count: int, ordered: bool) -> str:
    values = keys(count)
    if ordered:
        imports = "open dew.std.ordering\nopen dew.std.collections.ordered_map"
        setup = "  let map = ordered_map_new(natural_comparator())"
        insert = lambda key: f"  ordered_map_insert(map, {key}, {key + 1})"
        lookup = lambda key: (
            f"  match ordered_map_get(map, {key}) {{\n"
            "    Option::Some(value) => {\n"
            "      sum = sum + value\n"
            "    }\n"
            "    Option::None => unreachable()\n"
            "  }"
        )
        remove = lambda key: f"  ordered_map_remove(map, {key})"
    else:
        imports = "open dew.std.map\n\nfn new_map() -> Map<I32, I32> {\n  Map::empty()\n}"
        setup = "  let map = new_map()"
        insert = lambda key: f"  map.insert({key}, {key + 1})"
        lookup = lambda key: f"  sum = sum + map.get_unchecked({key})"
        remove = lambda key: f"  map.remove({key})"
    body = "\n".join([*(insert(key) for key in values), "  let mut sum = 0", *(lookup(key) for key in values), *(remove(key) for key in reversed(values))])
    return f"""{imports}

pub fn main() -> I32 {{
{setup}
{body}
  sum
}}
"""


def set_source(count: int, ordered: bool) -> str:
    values = keys(count)
    if ordered:
        imports = "open dew.std.ordering\nopen dew.std.collections.ordered_set"
        setup = "  let set = ordered_set_new(natural_comparator())"
        insert = lambda key: f"  ordered_set_insert(set, {key})"
        contains = lambda key: (f"  if ordered_set_contains(set, {key}) {{\n" f"    sum = sum + {key + 1}\n" "  } else {\n" "  }")
        remove = lambda key: f"  ordered_set_remove(set, {key})"
    else:
        imports = "open dew.std.set\n\nfn new_set() -> Set<I32> {\n  Set::empty()\n}"
        setup = "  let set = new_set()"
        insert = lambda key: f"  set.insert({key})"
        contains = lambda key: (f"  if set.contains({key}) {{\n" f"    sum = sum + {key + 1}\n" "  } else {\n" "  }")
        remove = lambda key: f"  set.remove({key})"
    body = "\n".join([*(insert(key) for key in values), "  let mut sum = 0", *(contains(key) for key in values), *(remove(key) for key in reversed(values))])
    return f"""{imports}

pub fn main() -> I32 {{
{setup}
{body}
  sum
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


def measure(paths: list[Path], samples: int, expected: int) -> dict[str, list[float]]:
    runner = r"""
const fs = require('fs');
const { performance } = require('perf_hooks');
(async () => {
  const samples = Number(process.argv[1]);
  const expected = Number(process.argv[2]);
  const report = {};
  for (const path of process.argv.slice(3)) {
    const { instance } = await WebAssembly.instantiate(fs.readFileSync(path), {});
    for (let i = 0; i < 20; i++) {
      if (instance.exports.main() !== expected) throw new Error('unexpected result');
    }
    const values = [];
    for (let i = 0; i < samples; i++) {
      const start = performance.now();
      if (instance.exports.main() !== expected) throw new Error('unexpected result');
      values.push((performance.now() - start) * 1000);
    }
    report[path] = values;
  }
  process.stdout.write(JSON.stringify(report));
})().catch(error => { console.error(error); process.exit(1); });
"""
    completed = subprocess.run(
        ["node", "-e", runner, str(samples), str(expected), *(str(path) for path in paths)],
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
    paths = {
        "hash_map": build("hash-map", map_source(args.count, False)),
        "ordered_map": build("ordered-map", map_source(args.count, True)),
        "hash_set": build("hash-set", set_source(args.count, False)),
        "ordered_set": build("ordered-set", set_source(args.count, True)),
    }
    expected = args.count * (args.count + 1) // 2
    raw = measure(list(paths.values()), args.samples, expected)
    medians = {name: statistics.median(raw[str(path)]) for name, path in paths.items()}
    print(json.dumps({
        "count": args.count,
        "samples": args.samples,
        "hash_map_median_us": round(medians["hash_map"], 3),
        "ordered_map_median_us": round(medians["ordered_map"], 3),
        "ordered_map_ratio": round(medians["ordered_map"] / medians["hash_map"], 4),
        "hash_set_median_us": round(medians["hash_set"], 3),
        "ordered_set_median_us": round(medians["ordered_set"], 3),
        "ordered_set_ratio": round(medians["ordered_set"] / medians["hash_set"], 4),
        "wasm_bytes": {name: path.stat().st_size for name, path in paths.items()},
    }, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
