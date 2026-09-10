#!/usr/bin/env python3
"""Compare Dew fixture execution before and after Starshine optimization."""

from __future__ import annotations

import argparse
from datetime import datetime, timezone
from concurrent.futures import ThreadPoolExecutor
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import platform
import resource
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
DEFAULT_OUT = ROOT / ".tmp/starshine-experiments"
COMPILER = ROOT / "_build/native/release/build/jtenner/dewdrop/module_snapshot_gen/module_snapshot_gen.exe"
STARSHINE = ROOT / "_build/native/release/build/jtenner/starshine/cmd/cmd.exe"


def load_module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    sys.modules[name] = module
    spec.loader.exec_module(module)
    return module


snapshots = load_module("dew_snapshots", ROOT / "tools/module-snapshots/run.py")


class CommandFailure(RuntimeError):
    pass


def execute(command, records, *, timeout=30, env=None, allow_failure=False, cwd=ROOT):
    command = [str(arg) for arg in command]
    start = time.perf_counter()
    record = {"command": command}
    try:
        process = subprocess.run(command, cwd=cwd, env=env, stdin=subprocess.DEVNULL, capture_output=True,
                                 text=True, timeout=timeout)
        record.update(returncode=process.returncode, stdout=process.stdout,
                      stderr=process.stderr, timeout=False)
    except subprocess.TimeoutExpired as error:
        def decoded(value):
            return value.decode(errors="replace") if isinstance(value, bytes) else value or ""
        record.update(returncode=None, stdout=decoded(error.stdout),
                      stderr=decoded(error.stderr), timeout=True)
        process = None
    finally:
        record["seconds"] = time.perf_counter() - start
        record["performance_bug"] = record["seconds"] > 30
        records.append(record)
    if process is None:
        raise CommandFailure(f"timeout after {timeout}s: {command!r}\n{record['stderr']}")
    if process.returncode and not allow_failure:
        raise CommandFailure(f"exit {process.returncode}: {command!r}\n{process.stdout}{process.stderr}")
    return process


def check_output(expected, actual):
    if expected != actual:
        raise AssertionError(f"runtime mismatch: expected {expected!r}, got {actual!r}")


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def wasm_sizes(path):
    """Keep metadata removal separate from code/data size changes."""
    data = path.read_bytes()
    if data[:8] != b"\0asm\1\0\0\0":
        raise ValueError(f"not a version 1 Wasm module: {path}")
    offset = 8
    non_custom = 8
    code = 0
    while offset < len(data):
        start = offset
        section = data[offset]
        offset += 1
        length = 0
        shift = 0
        while True:
            byte = data[offset]
            offset += 1
            length |= (byte & 127) << shift
            if byte < 128:
                break
            shift += 7
            if shift >= 35:
                raise ValueError("invalid Wasm section size")
        offset += length
        if offset > len(data):
            raise ValueError("truncated Wasm section")
        if section:
            non_custom += offset - start
        if section == 10:
            code += offset - start
    return {"bytes": len(data), "non_custom_bytes": non_custom, "code_section_bytes": code}


def write_json(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")


def pipelines(path=HERE / "pipelines.json"):
    config = json.loads(path.read_text())
    if config["version"] != 1:
        raise ValueError("pipeline format must be version 1")
    return config["pipelines"]


def runtime(binary, source, expected, engine, wago, records):
    host = json.dumps(expected.get("host", {}))
    mode = snapshots.fixture_mode(source)
    command = (["node", ROOT / "tools/module-snapshots/run-main.mjs"]
               if engine == "node" else [wago])
    process = execute([*command, binary, host, mode], records)
    actual = snapshots.parse_runtime_result(engine, process)
    check_output(expected["output"], actual)
    return actual


def optimize(binary, output, flags, starshine, records):
    output.unlink(missing_ok=True)
    execute([starshine, *flags, binary, "-o", output], records)
    execute(["wasm-tools", "validate", "--features", "all", output], records)
    return {**wasm_sizes(output), "sha256": sha256(output)}


def snapshot_case(source, args, selected):
    name = snapshots.fixture_name(source)
    directory = args.output / "snapshots" / name
    directory.mkdir(parents=True, exist_ok=True)
    result = {"name": name, "commands": [], "pipelines": {}}
    records = result["commands"]
    expected = snapshots.load_expectation(source)
    binary = directory / "baseline.wasm"
    binary.unlink(missing_ok=True)
    try:
        if args.from_wat:
            if expected["errors"]:
                if source.with_suffix(".wat").exists():
                    raise AssertionError("compile-failure fixture has a WAT snapshot")
                result["status"] = "compile-failure-no-wat"
                return result
            execute(["wasm-tools", "parse", source.with_suffix(".wat"), "-o", binary], records)
            errors, warnings, internals = [], expected["warnings"], []
            returncode = 0
        else:
            command = [args.compiler, binary, snapshots.fixture_mode(source)]
            for module, logical, path in snapshots.fixture_sources(source):
                command.extend([module, logical, path])
            process = execute(command, records, allow_failure=True,
                              env={**os.environ, "DEW_CACHE_DIR": str(directory / "cache")})
            errors, warnings, internals = snapshots.compiler_diagnostics(process.stdout + "\n" + process.stderr)
            returncode = process.returncode
        if internals:
            raise AssertionError(f"compiler internal failure: {internals}")
        if returncode and not errors:
            raise AssertionError(
                f"compiler failed without diagnostics (exit {returncode}):\n"
                f"{process.stdout}\n{process.stderr}")
        check_output(expected["errors"], errors)
        check_output(expected["warnings"], warnings)
        if returncode:
            check_output(expected["output"], None)
            result["status"] = "expected-compile-failure"
            return result
        if errors:
            raise AssertionError("compiler returned success with errors")
        execute(["wasm-tools", "validate", "--features", "all", binary], records)
        result["baseline"] = {"bytes": binary.stat().st_size, "sha256": sha256(binary), "output": {}}
        for engine in args.runtime:
            result["baseline"]["output"][engine] = runtime(binary, source, expected, engine, args.wago, records)
        result["status"] = "passed"
    except (CommandFailure, AssertionError, snapshots.SnapshotError) as error:
        result.update(status="baseline-failed", error=str(error))
        return result
    for label, flags in selected.items():
        trial = {"commands": []}
        result["pipelines"][label] = trial
        try:
            output = directory / f"{label}.wasm"
            trial.update(optimize(binary, output, flags, args.starshine, trial["commands"]))
            trial["output"] = {}
            for engine in args.runtime:
                trial["output"][engine] = runtime(output, source, expected, engine, args.wago, trial["commands"])
            trial["status"] = "passed"
        except (CommandFailure, AssertionError, snapshots.SnapshotError) as error:
            trial.update(status="failed", error=str(error))
            result["status"] = "failed"
    return result


def environment(records):
    cpu = platform.processor()
    cpuinfo = Path("/proc/cpuinfo")
    if cpuinfo.exists():
        cpu = next((line.split(":", 1)[1].strip() for line in cpuinfo.read_text().splitlines() if line.startswith("model name")), cpu)
    return {"date_utc": datetime.now(timezone.utc).isoformat(), "platform": platform.platform(), "cpu": cpu,
            "cpu_affinity": sorted(os.sched_getaffinity(0)) if hasattr(os, "sched_getaffinity") else None,
            "node": execute(["node", "--version"], records).stdout.strip(),
            "dewdrop_commit": execute(["git", "rev-parse", "HEAD"], records).stdout.strip(),
            "starshine_commit": execute(["git", "-C", "starshine-mb", "rev-parse", "HEAD"], records).stdout.strip(),
            "workspace_diff_sha256": hashlib.sha256(execute(["git", "diff", "--binary"], []).stdout.encode()).hexdigest()}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUT)
    parser.add_argument("--compiler", type=Path, default=COMPILER)
    parser.add_argument("--starshine", type=Path, default=STARSHINE)
    parser.add_argument("--pipeline", action="append")
    parser.add_argument("--pipelines", type=Path, default=HERE / "pipelines.json")
    parser.add_argument("--fixture", action="append", default=[])
    parser.add_argument("--runtime", choices=["node", "wago"], action="append")
    parser.add_argument("--jobs", type=int, default=4)
    parser.add_argument("--skip-build", action="store_true")
    parser.add_argument("--from-wat", action="store_true", help="use checked-in WAT as the fixed optimizer input; report compiler-error fixtures separately")
    args = parser.parse_args()
    if args.jobs < 1:
        parser.error("--jobs must be positive")
    args.output = args.output.resolve()
    args.runtime = args.runtime or ["node", "wago"]
    args.wago = args.output / "wago-runner"
    args.output.mkdir(parents=True, exist_ok=True)
    soft, hard = resource.getrlimit(resource.RLIMIT_STACK)
    desired = 64 * 1024 * 1024
    if soft != resource.RLIM_INFINITY and soft < desired:
        resource.setrlimit(resource.RLIMIT_STACK, (min(desired, hard) if hard != resource.RLIM_INFINITY else desired, hard))
    configured = pipelines(args.pipelines)
    names = args.pipeline or ["O4s"]
    unknown = set(names) - configured.keys()
    if unknown:
        parser.error(f"unknown pipelines: {sorted(unknown)}")
    selected = {name: configured[name] for name in names}
    report = {"version": 1, "input": "snapshot-wat" if args.from_wat else "source", "pipelines": selected, "commands": [], "fixtures": []}
    report["environment"] = environment(report["commands"])
    if not args.skip_build:
        if not args.from_wat:
            execute(["moon", "build", "--target", "native", "--release", "src/module_snapshot_gen"], report["commands"], timeout=600)
        execute(["moon", "build", "--target", "native", "--release", "starshine-mb/src/cmd"], report["commands"], timeout=600)
    if "wago" in args.runtime:
        execute(["go", "-C", snapshots.WAGO_RUNNER, "build", "-o", args.wago, "."], report["commands"], timeout=120)
    report["binaries"] = {"starshine": sha256(args.starshine)}
    if not args.from_wat:
        report["binaries"]["compiler"] = sha256(args.compiler)
    sources = snapshots.fixture_paths(args.fixture)
    start = time.perf_counter()
    with ThreadPoolExecutor(max_workers=args.jobs) as executor:
        for result in executor.map(lambda source: snapshot_case(source, args, selected), sources):
            report["fixtures"].append(result)
            write_json(args.output / "snapshots" / result["name"] / "result.json", result)
            print(f"{result['status']}: {result['name']}", flush=True)
    report["seconds"] = time.perf_counter() - start
    report["summary"] = {status: sum(row["status"] == status for row in report["fixtures"])
                         for status in ["passed", "expected-compile-failure", "compile-failure-no-wat", "baseline-failed", "failed"]}
    write_json(args.output / "report.json", report)
    print(json.dumps(report["summary"], sort_keys=True), flush=True)
    return int(any(row["status"] in ["failed", "baseline-failed"] for row in report["fixtures"]))


if __name__ == "__main__":
    raise SystemExit(main())
