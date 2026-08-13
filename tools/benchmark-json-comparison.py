#!/usr/bin/env python3
"""Compare Dew's dynamic JSON value API with json-as on shared fixtures.

The comparison intentionally reports json-as's generated typed-struct path and
its schema-less JSON.Obj path separately. Dew's JsonValue parser is eager and
preserves exact number lexemes; JSON.Obj may retain lazy source slices, so the
dynamic rows describe public API throughput rather than identical internal work.
"""

from __future__ import annotations

import argparse
import json
import os
import platform
import re
import shutil
import statistics
import subprocess
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
TMP = ROOT / ".tmp" / "json-comparison"
FIXTURES = ("small", "medium", "large")
JSON_AS_RESULT = re.compile(
    r"Completed benchmark in [^\n]*\((?P<duration>[0-9.]+) "
    r"(?P<unit>ns|us|ms)/op\) @ (?P<mbps>[0-9,]+)MB/s"
)
JSON_AS_DESCRIPTION = re.compile(r" - Benchmarking (?P<description>.+)")


def run(
    command: list[str],
    *,
    cwd: Path = ROOT,
    capture: bool = False,
    env: dict[str, str] | None = None,
) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        command,
        cwd=cwd,
        check=True,
        text=True,
        capture_output=capture,
        env=env,
    )


def command_output(command: list[str], *, cwd: Path = ROOT) -> str:
    return run(command, cwd=cwd, capture=True).stdout.strip()


def dew_string_literal(value: str) -> str:
    pieces: list[str] = []
    for byte in value.encode("utf-8"):
        if byte == 0x22:
            pieces.append('\\"')
        elif byte == 0x5C:
            pieces.append("\\\\")
        elif byte == 0x0A:
            pieces.append("\\n")
        elif byte == 0x0D:
            pieces.append("\\r")
        elif byte == 0x09:
            pieces.append("\\t")
        elif 0x20 <= byte <= 0x7E:
            pieces.append(chr(byte))
        else:
            pieces.append(f"\\x{byte:02X}")
    return '"' + "".join(pieces) + '"'


def extract_json_as_fixture(json_as: Path, name: str) -> str:
    source = (json_as / "assembly" / "__benches__" / f"{name}.bench.ts").read_text(
        encoding="utf-8"
    )
    match = re.search(r"const v2 = `(?P<value>.*?)`;", source, re.DOTALL)
    if match is None:
        raise RuntimeError(f"could not extract v2 from json-as {name}.bench.ts")
    value = match.group("value")
    json.loads(value)
    return value


def fixture_root_size(document: str) -> int:
    value = json.loads(document)
    if not isinstance(value, dict):
        raise RuntimeError("comparison fixtures must have object roots")
    return len(value)


def dew_source(document: str) -> str:
    literal = dew_string_literal(document)
    root_size = fixture_root_size(document)
    return f"""open dew.std.array
open dew.std.bytes
open dew.std.json
open dew.std.string

fn json_benchmark_document() -> String {{
  {literal}
}}

fn json_benchmark_bytes() -> Bytes {{
  json_benchmark_document().as_bytes()
}}

fn json_benchmark_baseline_repeat(remaining: U32, total: U32) -> U32 {{
  if remaining == 0u32 {{
    total
  }} else {{
    json_benchmark_baseline_repeat(remaining - 1u32, total + {root_size}u32)
  }}
}}

fn json_benchmark_validate_repeat(remaining: U32, total: U32) -> U32 {{
  if remaining == 0u32 {{
    total
  }} else if json_benchmark_bytes().is_valid_utf8() {{
    json_benchmark_validate_repeat(remaining - 1u32, total + 1u32)
  }} else {{
    total
  }}
}}

fn json_benchmark_parse_string_repeat(remaining: U32, total: U32) -> U32 {{
  if remaining == 0u32 {{
    total
  }} else {{
    match json_parse(json_benchmark_document()) {{
      Result::Ok(JsonValue::Object(members)) =>
        json_benchmark_parse_string_repeat(remaining - 1u32, total + members.length())
      _ => total
    }}
  }}
}}

fn json_benchmark_parse_bytes_repeat(remaining: U32, total: U32) -> U32 {{
  if remaining == 0u32 {{
    total
  }} else {{
    match json_parse_bytes(json_benchmark_bytes()) {{
      Result::Ok(JsonValue::Object(members)) =>
        json_benchmark_parse_bytes_repeat(remaining - 1u32, total + members.length())
      _ => total
    }}
  }}
}}

fn json_benchmark_stringify_repeat(
  value: JsonValue,
  remaining: U32,
  total: U32,
) -> U32 {{
  if remaining == 0u32 {{
    total
  }} else {{
    match json_stringify(value) {{
      Result::Ok(output) =>
        json_benchmark_stringify_repeat(
          value,
          remaining - 1u32,
          total + output.byte_length(),
        )
      Result::Err(_) => total
    }}
  }}
}}

fn json_benchmark_roundtrip_repeat(remaining: U32, total: U32) -> U32 {{
  if remaining == 0u32 {{
    total
  }} else {{
    match json_parse(json_benchmark_document()) {{
      Result::Ok(value) => match json_stringify(value) {{
        Result::Ok(output) =>
          json_benchmark_roundtrip_repeat(remaining - 1u32, total + output.byte_length())
        Result::Err(_) => total
      }}
      Result::Err(_) => total
    }}
  }}
}}

pub fn baseline(iterations: U32) -> U32 {{
  json_benchmark_baseline_repeat(iterations, 0u32)
}}

pub fn validate_bytes(iterations: U32) -> U32 {{
  json_benchmark_validate_repeat(iterations, 0u32)
}}

pub fn parse_string(iterations: U32) -> U32 {{
  json_benchmark_parse_string_repeat(iterations, 0u32)
}}

pub fn parse_bytes(iterations: U32) -> U32 {{
  json_benchmark_parse_bytes_repeat(iterations, 0u32)
}}

pub fn stringify(iterations: U32) -> U32 {{
  match json_parse(json_benchmark_document()) {{
    Result::Ok(value) => json_benchmark_stringify_repeat(value, iterations, 0u32)
    Result::Err(_) => 0u32
  }}
}}

pub fn roundtrip(iterations: U32) -> U32 {{
  json_benchmark_roundtrip_repeat(iterations, 0u32)
}}
"""


def build_dew_fixture(name: str, document: str) -> Path:
    directory = TMP / "dew" / name
    directory.mkdir(parents=True, exist_ok=True)
    source_path = directory / "benchmark.dew"
    wasm_path = directory / "benchmark.wasm"
    source_path.write_text(dew_source(document), encoding="utf-8")
    run(
        [str(ROOT / "tools" / "dew"), "build", str(source_path), "-o", str(wasm_path)],
        capture=True,
    )
    return wasm_path


def measure_dew(
    modules: list[dict[str, Any]], samples: int, target_batch_bytes: int
) -> dict[str, Any]:
    runner = r"""
const fs = require('fs');
const { performance } = require('perf_hooks');
(async () => {
  const specs = JSON.parse(fs.readFileSync(process.argv[1], 'utf8'));
  const samples = Number(process.argv[2]);
  const targetBatchBytes = Number(process.argv[3]);
  const operations = [
    ['baseline', spec => spec.rootSize],
    ['validate_bytes', spec => 1],
    ['parse_string', spec => spec.rootSize],
    ['parse_bytes', spec => spec.rootSize],
    ['stringify', spec => spec.bytes],
    ['roundtrip', spec => spec.bytes],
  ];
  const report = {};
  for (const spec of specs) {
    const { instance } = await WebAssembly.instantiate(fs.readFileSync(spec.wasm), {});
    const batch = Math.max(1, Math.min(5000, Math.floor(targetBatchBytes / spec.bytes)));
    report[spec.name] = { batch, operations: {} };
    for (const [name] of operations) report[spec.name].operations[name] = [];
    for (const [name, expectedPerOp] of operations) {
      const expected = expectedPerOp(spec) * batch;
      for (let warmup = 0; warmup < 20; warmup++) {
        if (instance.exports[name](batch) !== expected) throw new Error(`bad ${spec.name} ${name} warmup`);
      }
    }
    for (let sample = 0; sample < samples; sample++) {
      const rotation = sample % operations.length;
      for (let offset = 0; offset < operations.length; offset++) {
        const [name, expectedPerOp] = operations[(rotation + offset) % operations.length];
        const expected = expectedPerOp(spec) * batch;
        const start = performance.now();
        const actual = instance.exports[name](batch);
        const elapsedUs = (performance.now() - start) * 1000 / batch;
        if (actual !== expected) throw new Error(`bad ${spec.name} ${name}: ${actual} != ${expected}`);
        report[spec.name].operations[name].push(elapsedUs);
      }
    }
  }
  process.stdout.write(JSON.stringify(report));
})().catch(error => { console.error(error); process.exit(1); });
"""
    TMP.mkdir(parents=True, exist_ok=True)
    specs_path = TMP / "dew-specs.json"
    specs_path.write_text(json.dumps(modules), encoding="utf-8")
    try:
        completed = run(
            [
                "node",
                "-e",
                runner,
                str(specs_path),
                str(samples),
                str(target_batch_bytes),
            ],
            capture=True,
        )
    except subprocess.CalledProcessError as error:
        raise RuntimeError(error.stderr or error.stdout or "Dew benchmark runner failed") from error
    raw = json.loads(completed.stdout)
    result: dict[str, Any] = {}
    for spec in modules:
        name = spec["name"]
        byte_length = spec["bytes"]
        result[name] = {"batch": raw[name]["batch"], "operations": {}}
        for operation, values in raw[name]["operations"].items():
            median_us = statistics.median(values)
            result[name]["operations"][operation] = {
                "median_ns_per_op": round(median_us * 1000, 2),
                "median_mbps": round(byte_length / median_us, 2),
                "p25_ns_per_op": round(statistics.quantiles(values, n=4)[0] * 1000, 2),
                "p75_ns_per_op": round(statistics.quantiles(values, n=4)[2] * 1000, 2),
            }
    return result


def build_json_as_fixture(json_as: Path, name: str) -> Path:
    source = json_as / "assembly" / "__benches__" / f"{name}.bench.ts"
    build = json_as / "build"
    build.mkdir(parents=True, exist_ok=True)
    temporary = build / f"{name}.comparison.tmp.wasm"
    output = build / f"{name}.comparison.simd.wasm"
    env = dict(os.environ)
    env.update(
        {
            "JSON_CACHE": "0",
            "JSON_WRITE": str(source.relative_to(json_as)),
            "JSON_MODE": "SIMD",
        }
    )
    run(
        [
            "npx",
            "asc",
            str(source.relative_to(json_as)),
            "--transform",
            "./transform",
            "-o",
            str(temporary.relative_to(json_as)),
            "-O3",
            "--noAssert",
            "--uncheckedBehavior",
            "always",
            "--runtime",
            "incremental",
            "--enable",
            "bulk-memory",
            "--exportStart",
            "start",
            "--exportRuntime",
            "--enable",
            "simd",
            "--use",
            "BENCH_PREALLOC_BYTES=67108864",
        ],
        cwd=json_as,
        capture=True,
        env=env,
    )
    run(
        [
            "wasm-opt",
            "-O4",
            "-tnh",
            "-iit",
            "-ifwl",
            "-s",
            "0",
            "--enable-bulk-memory",
            "--enable-nontrapping-float-to-int",
            "--enable-tail-call",
            "--enable-sign-ext",
            "--enable-mutable-globals",
            "--enable-simd",
            str(temporary),
            "-o",
            str(output),
        ],
        cwd=json_as,
        capture=True,
    )
    temporary.unlink(missing_ok=True)
    return output


def measure_json_as(module: Path, *, cwd: Path) -> dict[str, Any]:
    runner = r"""
const fs = require('fs');
(async () => {
  const bytes = fs.readFileSync(process.argv[1]);
  let memory = null;
  const logs = [];
  const files = {};
  function lift(pointer) {
    if (!pointer) return null;
    const length = new Uint32Array(memory.buffer)[(pointer - 4) >>> 2];
    const start = pointer >>> 1;
    const end = (pointer + length) >>> 1;
    const view = new Uint16Array(memory.buffer);
    let output = '';
    for (let at = start; at < end; at += 1024) {
      output += String.fromCharCode(...view.subarray(at, Math.min(at + 1024, end)));
    }
    return output;
  }
  const { instance } = await WebAssembly.instantiate(bytes, { env: {
    abort: (message, file, line) => { throw new Error(`abort ${lift(message)} ${lift(file)}:${line}`); },
    'console.log': pointer => logs.push(lift(pointer)),
    'Date.now': () => Date.now(),
    'performance.now': () => performance.now(),
    writeFile: (name, data) => { files[lift(name)] = lift(data); },
    readFile: () => 0,
  }});
  memory = instance.exports.memory;
  instance.exports.start();
  process.stdout.write(JSON.stringify({ logs, files }));
})().catch(error => { console.error(error); process.exit(1); });
"""
    completed = run(
        ["node", "-e", runner, str(module)], cwd=cwd, capture=True
    )
    raw = json.loads(completed.stdout)
    parsed: dict[str, Any] = {}
    for encoded in raw["files"].values():
        result = json.loads(encoded)
        parsed[result["description"]] = {
            "ns_per_op": round(result["nsPerOp"], 2),
            "mbps": round(result["mbps"], 2),
        }
    if parsed:
        return parsed
    current: str | None = None
    for line in raw["logs"]:
        description = JSON_AS_DESCRIPTION.fullmatch(line)
        if description is not None:
            current = description.group("description")
            continue
        result = JSON_AS_RESULT.search(line)
        if result is None or current is None:
            continue
        multiplier = {"ns": 1.0, "us": 1000.0, "ms": 1_000_000.0}[result.group("unit")]
        parsed[current] = {
            "ns_per_op": round(float(result.group("duration")) * multiplier, 2),
            "mbps": int(result.group("mbps").replace(",", "")),
        }
        current = None
    return parsed


def git_revision(path: Path) -> str:
    return command_output(["git", "rev-parse", "HEAD"], cwd=path)


def package_version(path: Path) -> str:
    return json.loads((path / "package.json").read_text(encoding="utf-8"))["version"]


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--json-as-dir",
        type=Path,
        default=ROOT / ".tmp" / "json-as",
        help="json-as checkout at the revision to compare",
    )
    parser.add_argument("--samples", type=int, default=101)
    parser.add_argument("--target-batch-bytes", type=int, default=262144)
    parser.add_argument("--skip-json-as-build", action="store_true")
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    if args.samples < 4 or args.target_batch_bytes < 1:
        parser.error("samples must be at least 4 and target batch bytes must be positive")
    json_as = args.json_as_dir.resolve()
    if not (json_as / "package.json").is_file():
        parser.error(f"not a json-as checkout: {json_as}")
    if shutil.which("wasm-opt") is None:
        parser.error("wasm-opt is required for json-as's documented benchmark build")

    TMP.mkdir(parents=True, exist_ok=True)
    fixtures: dict[str, str] = {
        name: extract_json_as_fixture(json_as, name) for name in FIXTURES
    }
    dew_modules: list[dict[str, Any]] = []
    for name, document in fixtures.items():
        wasm = build_dew_fixture(name, document)
        dew_modules.append(
            {
                "name": name,
                "wasm": str(wasm),
                "bytes": len(document.encode("utf-8")),
                "rootSize": fixture_root_size(document),
                "wasmBytes": wasm.stat().st_size,
            }
        )
    dew_results = measure_dew(dew_modules, args.samples, args.target_batch_bytes)

    if not args.skip_json_as_build:
        run(["npm", "run", "build:transform"], cwd=json_as, capture=True)
    json_as_results: dict[str, Any] = {}
    for name in FIXTURES:
        module = json_as / "build" / f"{name}.comparison.simd.wasm"
        if not args.skip_json_as_build:
            module = build_json_as_fixture(json_as, name)
        if not module.is_file():
            parser.error(f"missing prebuilt json-as module: {module}")
        json_as_results[name] = {
            "wasm_bytes": module.stat().st_size,
            "operations": measure_json_as(module, cwd=json_as),
        }

    report = {
        "methodology": {
            "comparison": "same compact small/medium/large json-as fixture strings",
            "dew": "eager recursive JsonValue with exact number lexemes",
            "json_as_dynamic": "schema-less JSON.Obj; nested source slices may remain lazy",
            "json_as_typed": "generated fixture-specific struct parser",
            "engine": "Node/V8 for both implementations",
            "json_as_build": "SIMD, AssemblyScript incremental runtime, asc -O3, official wasm-opt speed flags",
            "dew_samples": args.samples,
            "dew_target_batch_bytes": args.target_batch_bytes,
        },
        "environment": {
            "platform": platform.platform(),
            "machine": platform.machine(),
            "processor": platform.processor(),
            "node": command_output(["node", "--version"]),
            "wasm_opt": command_output(["wasm-opt", "--version"]),
            "dew_revision": git_revision(ROOT),
            "json_as_revision": git_revision(json_as),
            "json_as_version": package_version(json_as),
            "assemblyscript": command_output(["npx", "asc", "--version"], cwd=json_as),
        },
        "fixtures": {
            spec["name"]: {
                "input_bytes": spec["bytes"],
                "root_members": spec["rootSize"],
                "dew_wasm_bytes": spec["wasmBytes"],
                "dew": dew_results[spec["name"]],
                "json_as": json_as_results[spec["name"]],
            }
            for spec in dew_modules
        },
    }
    encoded = json.dumps(report, indent=2, sort_keys=True) + "\n"
    if args.output is not None:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(encoded, encoding="utf-8")
    print(encoded, end="")


if __name__ == "__main__":
    main()
