#!/usr/bin/env python3
"""Measure JSON parser growable-array state versus one fixed state carrier."""

from __future__ import annotations

import argparse
import importlib.util
import json
import os
import platform
import shutil
import statistics
import subprocess
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
TMP = ROOT / ".tmp" / "json-parser-state-benchmark"
FIXTURES = ("small", "medium", "large")
OPERATIONS = ("parse_string", "parse_bytes", "roundtrip")

FIXED_STRUCT = """struct JsonParser {
  input: Bytes
  source: String
  state: FixedArray<U32>
  limits: JsonLimits
}"""
ARRAY_STRUCT = """struct JsonParser {
  input: Bytes
  source: String
  offset: Array<U32>
  values: Array<U32>
  limits: JsonLimits
}"""
FIXED_ACCESSORS = """fn json_parser_offset(parser: JsonParser) -> U32 {
  parser.state.get_unchecked(0u32)
}

fn json_parser_set_offset(parser: JsonParser, offset: U32) -> Unit {
  parser.state.set_unchecked(0u32, offset)
}

fn json_parser_value_count(parser: JsonParser) -> U32 {
  parser.state.get_unchecked(1u32)
}

fn json_parser_set_value_count(parser: JsonParser, count: U32) -> Unit {
  parser.state.set_unchecked(1u32, count)
}"""
ARRAY_ACCESSORS = """fn json_parser_offset(parser: JsonParser) -> U32 {
  parser.offset.get_unchecked(0u32)
}

fn json_parser_set_offset(parser: JsonParser, offset: U32) -> Unit {
  parser.offset.set_unchecked(0u32, offset)
}

fn json_parser_value_count(parser: JsonParser) -> U32 {
  parser.values.get_unchecked(0u32)
}

fn json_parser_set_value_count(parser: JsonParser, count: U32) -> Unit {
  parser.values.set_unchecked(0u32, count)
}"""
FIXED_INIT = """    let parser = JsonParser::{
      input: source.as_bytes()
      source: source
      state: FixedArray::make(2u32, 0u32)
      limits: limits
    }"""
ARRAY_INIT = """    let offset = Array::with_capacity(1u32)
    offset.push(0u32)
    let values = Array::with_capacity(1u32)
    values.push(0u32)
    let parser = JsonParser {
      input: source.as_bytes()
      source: source
      offset: offset
      values: values
      limits: limits
    }"""


def load_comparison_module() -> Any:
    path = ROOT / "tools" / "benchmark-json-comparison.py"
    spec = importlib.util.spec_from_file_location("dew_json_comparison", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def run(command: list[str], *, capture: bool = False) -> subprocess.CompletedProcess[str]:
    return subprocess.run(command, cwd=ROOT, check=True, text=True, capture_output=capture)


def replace_once(source: str, old: str, new: str) -> str:
    if source.count(old) != 1:
        raise RuntimeError("current std/json.dew does not contain expected fixed-state source")
    return source.replace(old, new)


def prepare_standard_roots() -> dict[str, Path]:
    roots: dict[str, Path] = {}
    for variant in ("arrays", "fixed"):
        root = TMP / "packages" / variant
        shutil.rmtree(root, ignore_errors=True)
        shutil.copytree(ROOT / "std", root / "std")
        roots[variant] = root
    path = roots["arrays"] / "std" / "json.dew"
    source = path.read_text(encoding="utf-8")
    source = replace_once(source, FIXED_STRUCT, ARRAY_STRUCT)
    source = replace_once(source, FIXED_ACCESSORS, ARRAY_ACCESSORS)
    source = replace_once(source, FIXED_INIT, ARRAY_INIT)
    path.write_text(source, encoding="utf-8")
    return roots


def build_modules(json_as: Path) -> list[dict[str, Any]]:
    comparison = load_comparison_module()
    roots = prepare_standard_roots()
    env = dict(os.environ)
    env.update({
        "DEW_PARSE_EVENT_CACHE": "0",
        "DEW_INTERFACE_CACHE": "0",
        "DEW_BODY_CACHE": "0",
        "DEW_BUILD_CACHE": "0",
    })
    modules: list[dict[str, Any]] = []
    for name in FIXTURES:
        document = comparison.extract_json_as_fixture(json_as, name)
        directory = TMP / "modules" / name
        directory.mkdir(parents=True, exist_ok=True)
        source_path = directory / "benchmark.dew"
        source_path.write_text(comparison.dew_source(document), encoding="utf-8")
        variants: dict[str, str] = {}
        sizes: dict[str, int] = {}
        for variant, package_root in roots.items():
            wasm_path = directory / f"benchmark-{variant}.wasm"
            subprocess.run(
                [str(ROOT / "tools" / "dew"), "build", str(source_path),
                 "--package-root", str(package_root), "-o", str(wasm_path)],
                cwd=ROOT, check=True, text=True, capture_output=True, env=env,
            )
            variants[variant] = str(wasm_path)
            sizes[variant] = wasm_path.stat().st_size
        modules.append({
            "name": name,
            "bytes": len(document.encode("utf-8")),
            "rootSize": comparison.fixture_root_size(document),
            "variants": variants,
            "wasmBytes": sizes,
        })
    return modules


def measure(modules: list[dict[str, Any]], samples: int, rounds: int,
            target_batch_bytes: int) -> dict[str, Any]:
    runner = r"""
const fs = require('fs');
const { performance } = require('perf_hooks');
(async () => {
  const specs = JSON.parse(fs.readFileSync(process.argv[1], 'utf8'));
  const samples = Number(process.argv[2]);
  const rounds = Number(process.argv[3]);
  const targetBatchBytes = Number(process.argv[4]);
  const operations = ['parse_string', 'parse_bytes', 'roundtrip'];
  const result = {};
  for (const spec of specs) {
    const instances = {};
    for (const variant of ['arrays', 'fixed']) {
      instances[variant] = (await WebAssembly.instantiate(
        fs.readFileSync(spec.variants[variant]), {},
      )).instance;
    }
    const batch = Math.max(1, Math.min(5000, Math.floor(targetBatchBytes / spec.bytes)));
    for (const operation of operations) {
      for (const variant of ['arrays', 'fixed']) {
        for (let warmup = 0; warmup < 30; warmup++) instances[variant].exports[operation](batch);
      }
    }
    result[spec.name] = { batch, rounds: [] };
    for (let round = 0; round < rounds; round++) {
      const values = Object.fromEntries(operations.map(operation => [
        operation, { arrays: [], fixed: [] },
      ]));
      for (let sample = 0; sample < samples; sample++) {
        for (let offset = 0; offset < operations.length; offset++) {
          const operation = operations[(sample + round + offset) % operations.length];
          const order = (sample + round) % 2 === 0
            ? ['arrays', 'fixed'] : ['fixed', 'arrays'];
          for (const variant of order) {
            const start = performance.now();
            instances[variant].exports[operation](batch);
            values[operation][variant].push((performance.now() - start) * 1e6 / batch);
          }
        }
      }
      result[spec.name].rounds.push(values);
    }
  }
  process.stdout.write(JSON.stringify(result));
})().catch(error => { console.error(error); process.exit(1); });
"""
    TMP.mkdir(parents=True, exist_ok=True)
    specs_path = TMP / "specs.json"
    specs_path.write_text(json.dumps(modules), encoding="utf-8")
    raw = json.loads(run([
        "node", "-e", runner, str(specs_path), str(samples), str(rounds),
        str(target_batch_bytes),
    ], capture=True).stdout)
    report: dict[str, Any] = {}
    for module in modules:
        operations: dict[str, Any] = {}
        for operation in OPERATIONS:
            array_rounds: list[float] = []
            fixed_rounds: list[float] = []
            deltas: list[float] = []
            for values in raw[module["name"]]["rounds"]:
                arrays = statistics.median(values[operation]["arrays"])
                fixed = statistics.median(values[operation]["fixed"])
                array_rounds.append(arrays)
                fixed_rounds.append(fixed)
                deltas.append((fixed / arrays - 1.0) * 100.0)
            operations[operation] = {
                "arrays_ns_per_op": round(statistics.median(array_rounds), 2),
                "fixed_ns_per_op": round(statistics.median(fixed_rounds), 2),
                "delta_percent": round(statistics.median(deltas), 2),
            }
        report[module["name"]] = {
            "input_bytes": module["bytes"],
            "batch": raw[module["name"]]["batch"],
            "wasm_bytes": module["wasmBytes"],
            "operations": operations,
        }
    return report


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--json-as-dir", type=Path, default=ROOT / ".tmp" / "json-as")
    parser.add_argument("--samples", type=int, default=101)
    parser.add_argument("--rounds", type=int, default=5)
    parser.add_argument("--target-batch-bytes", type=int, default=262144)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    if args.samples < 4 or args.rounds < 1 or args.target_batch_bytes < 1:
        parser.error("samples >= 4, rounds >= 1, and positive batch bytes are required")
    json_as = args.json_as_dir.resolve()
    if not (json_as / "package.json").is_file():
        parser.error(f"not a json-as checkout: {json_as}")
    report = {
        "methodology": {
            "comparison": "same compiler and fixtures; two Array<U32> cells versus one FixedArray<U32>",
            "samples_per_round": args.samples,
            "rounds": args.rounds,
            "warmups": 30,
            "target_batch_bytes": args.target_batch_bytes,
        },
        "environment": {
            "platform": platform.platform(),
            "machine": platform.machine(),
            "node": run(["node", "--version"], capture=True).stdout.strip(),
            "dew_revision": run(["git", "rev-parse", "HEAD"], capture=True).stdout.strip(),
        },
        "fixtures": measure(build_modules(json_as), args.samples, args.rounds,
                            args.target_batch_bytes),
    }
    encoded = json.dumps(report, indent=2, sort_keys=True) + "\n"
    if args.output is not None:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(encoded, encoding="utf-8")
    print(encoded, end="")


if __name__ == "__main__":
    main()
