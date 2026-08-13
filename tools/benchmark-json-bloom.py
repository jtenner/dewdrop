#!/usr/bin/env python3
"""Measure exact JSON duplicate checks with Bloom disabled versus enabled."""

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
TMP = ROOT / ".tmp" / "json-bloom-benchmark"
FIXTURES = ("small", "medium", "large")
OPERATIONS = ("parse_string", "parse_bytes", "stringify", "roundtrip")
ENABLED_THRESHOLD = "fn json_bloom_threshold() -> U32 {\n  16u32\n}"
DISABLED_THRESHOLD = "fn json_bloom_threshold() -> U32 {\n  4294967295u32\n}"


def load_comparison_module() -> Any:
    path = ROOT / "tools" / "benchmark-json-comparison.py"
    spec = importlib.util.spec_from_file_location("dew_json_comparison", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def run(command: list[str], *, capture: bool = False) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        command,
        cwd=ROOT,
        check=True,
        text=True,
        capture_output=capture,
    )


def prepare_standard_roots() -> dict[str, Path]:
    roots: dict[str, Path] = {}
    for variant in ("disabled", "enabled"):
        root = TMP / "packages" / variant
        shutil.rmtree(root, ignore_errors=True)
        shutil.copytree(ROOT / "std", root / "std")
        roots[variant] = root
    disabled_json = roots["disabled"] / "std" / "json.dew"
    source = disabled_json.read_text(encoding="utf-8")
    if source.count(ENABLED_THRESHOLD) != 1:
        raise RuntimeError("current std/json.dew does not contain the expected Bloom threshold")
    disabled_json.write_text(
        source.replace(ENABLED_THRESHOLD, DISABLED_THRESHOLD), encoding="utf-8"
    )
    return roots


def build_modules(json_as: Path) -> list[dict[str, Any]]:
    comparison = load_comparison_module()
    roots = prepare_standard_roots()
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
            env = dict(os.environ)
            env.update(
                {
                    "DEW_PARSE_EVENT_CACHE": "0",
                    "DEW_INTERFACE_CACHE": "0",
                    "DEW_BODY_CACHE": "0",
                    "DEW_BUILD_CACHE": "0",
                }
            )
            subprocess.run(
                [
                    str(ROOT / "tools" / "dew"),
                    "build",
                    str(source_path),
                    "--package-root",
                    str(package_root),
                    "-o",
                    str(wasm_path),
                ],
                cwd=ROOT,
                check=True,
                text=True,
                capture_output=True,
                env=env,
            )
            variants[variant] = str(wasm_path)
            sizes[variant] = wasm_path.stat().st_size
        modules.append(
            {
                "name": name,
                "bytes": len(document.encode("utf-8")),
                "rootSize": comparison.fixture_root_size(document),
                "variants": variants,
                "wasmBytes": sizes,
            }
        )
    return modules


def measure(
    modules: list[dict[str, Any]], samples: int, rounds: int, target_batch_bytes: int
) -> dict[str, Any]:
    runner = r"""
const fs = require('fs');
const { performance } = require('perf_hooks');
(async () => {
  const specs = JSON.parse(fs.readFileSync(process.argv[1], 'utf8'));
  const samples = Number(process.argv[2]);
  const rounds = Number(process.argv[3]);
  const targetBatchBytes = Number(process.argv[4]);
  const operations = [
    ['parse_string', spec => spec.rootSize],
    ['parse_bytes', spec => spec.rootSize],
    ['stringify', spec => spec.bytes],
    ['roundtrip', spec => spec.bytes],
  ];
  const result = {};
  for (const spec of specs) {
    const instances = {};
    for (const variant of ['disabled', 'enabled']) {
      instances[variant] = (await WebAssembly.instantiate(
        fs.readFileSync(spec.variants[variant]), {},
      )).instance;
    }
    const batch = Math.max(1, Math.min(5000, Math.floor(targetBatchBytes / spec.bytes)));
    for (const [operation, expectedPerOperation] of operations) {
      const expected = expectedPerOperation(spec) * batch;
      for (const variant of ['disabled', 'enabled']) {
        for (let warmup = 0; warmup < 30; warmup++) {
          if (instances[variant].exports[operation](batch) !== expected) {
            throw new Error(`bad ${spec.name} ${variant} ${operation} warmup`);
          }
        }
      }
    }
    result[spec.name] = { batch, rounds: [] };
    for (let round = 0; round < rounds; round++) {
      const values = {};
      for (const [operation] of operations) {
        values[operation] = { disabled: [], enabled: [] };
      }
      for (let sample = 0; sample < samples; sample++) {
        const rotation = (sample + round) % operations.length;
        for (let offset = 0; offset < operations.length; offset++) {
          const [operation, expectedPerOperation] = operations[(rotation + offset) % operations.length];
          const expected = expectedPerOperation(spec) * batch;
          const order = (sample + round) % 2 === 0
            ? ['disabled', 'enabled']
            : ['enabled', 'disabled'];
          for (const variant of order) {
            const start = performance.now();
            const actual = instances[variant].exports[operation](batch);
            const elapsedNs = (performance.now() - start) * 1e6 / batch;
            if (actual !== expected) {
              throw new Error(`bad ${spec.name} ${variant} ${operation}: ${actual} != ${expected}`);
            }
            values[operation][variant].push(elapsedNs);
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
    completed = run(
        [
            "node",
            "-e",
            runner,
            str(specs_path),
            str(samples),
            str(rounds),
            str(target_batch_bytes),
        ],
        capture=True,
    )
    raw = json.loads(completed.stdout)
    report: dict[str, Any] = {}
    for module in modules:
        name = module["name"]
        operations: dict[str, Any] = {}
        for operation in OPERATIONS:
            round_rows: list[dict[str, float]] = []
            disabled_rounds: list[float] = []
            enabled_rounds: list[float] = []
            deltas: list[float] = []
            for round_values in raw[name]["rounds"]:
                disabled = statistics.median(round_values[operation]["disabled"])
                enabled = statistics.median(round_values[operation]["enabled"])
                delta = (enabled / disabled - 1.0) * 100.0
                disabled_rounds.append(disabled)
                enabled_rounds.append(enabled)
                deltas.append(delta)
                round_rows.append(
                    {
                        "disabled_ns_per_op": round(disabled, 2),
                        "enabled_ns_per_op": round(enabled, 2),
                        "delta_percent": round(delta, 2),
                    }
                )
            operations[operation] = {
                "disabled_ns_per_op": round(statistics.median(disabled_rounds), 2),
                "enabled_ns_per_op": round(statistics.median(enabled_rounds), 2),
                "delta_percent": round(statistics.median(deltas), 2),
                "rounds": round_rows,
            }
        report[name] = {
            "input_bytes": module["bytes"],
            "root_members": module["rootSize"],
            "batch": raw[name]["batch"],
            "wasm_bytes": module["wasmBytes"],
            "operations": operations,
        }
    return report


def git_revision() -> str:
    return run(["git", "rev-parse", "HEAD"], capture=True).stdout.strip()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--json-as-dir", type=Path, default=ROOT / ".tmp" / "json-as"
    )
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
    modules = build_modules(json_as)
    fixtures = measure(modules, args.samples, args.rounds, args.target_batch_bytes)
    report = {
        "methodology": {
            "comparison": "same compiler and fixtures; Bloom threshold 16 versus disabled",
            "execution": "paired interleaved Node/V8 execution",
            "warmups": 30,
            "samples_per_round": args.samples,
            "rounds": args.rounds,
            "target_batch_bytes": args.target_batch_bytes,
            "negative_delta_is_faster": True,
        },
        "environment": {
            "platform": platform.platform(),
            "machine": platform.machine(),
            "node": run(["node", "--version"], capture=True).stdout.strip(),
            "dew_revision": git_revision(),
        },
        "fixtures": fixtures,
    }
    encoded = json.dumps(report, indent=2, sort_keys=True) + "\n"
    if args.output is not None:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(encoded, encoding="utf-8")
    print(encoded, end="")


if __name__ == "__main__":
    main()
