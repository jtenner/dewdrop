#!/usr/bin/env python3
"""Measure checked Dew workloads across ordered Starshine pass lists."""

import argparse
import json
import os
from pathlib import Path
import resource
import statistics

from runner import (COMPILER, STARSHINE, HERE, ROOT, CommandFailure, environment,
                    execute, load_module, optimize, pipelines, sha256, wasm_sizes, write_json)


def workloads():
    def helper(name):
        return load_module(name.replace("-", "_"), ROOT / f"tools/benchmark-{name}.py")
    array = helper("array-runtime")
    maps = helper("ordered-collections")
    hashes = helper("text-hash")
    enums = helper("scalar-payload-enum-abi")
    tail = helper("tail-recursion")
    json_bench = helper("json-canonical")
    rows = []
    def add(name, source, expected, export="main", inputs=None):
        rows.append({"name": name, "source": source, "export": export,
                     "inputs": inputs or [{"args": [], "expected": expected}]})
    add("array-growth", array.source(256, False), 255)
    add("array-reserved", array.source(256, True), 255)
    add("hash-map", maps.map_source(32, False), 528)
    add("ordered-map", maps.map_source(32, True), 528)
    add("bytes-hash", hashes.source(hashes.payload(2048), "bytes"), 1)
    add("string-hash", hashes.source(hashes.payload(2048), "string"), 1)
    add("enum-payload", enums.program_source(32, True), None,
        inputs=[{"args": [v], "expected": 64 * v + 992} for v in [0, 1, 41, 127]])
    add("tail-loop", tail.recursive_source(10000), 0)
    document = json.dumps({"items": list(range(16)), "name": "Dew benchmark", "active": True}, separators=(",", ":"))
    source = json_bench.source(json.dumps(document))
    add("json-roundtrip", source, None, "legacy",
        [{"args": [v], "expected": len(document) * v} for v in [1, 2, 3, 4]])
    add("json-canonical", source, None, "canonical",
        [{"args": [v], "expected": len(document) * v} for v in [1, 2, 3, 4]])
    return rows


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=ROOT / ".tmp/starshine-benchmarks")
    parser.add_argument("--compiler", type=Path, default=COMPILER)
    parser.add_argument("--starshine", type=Path, default=STARSHINE)
    parser.add_argument("--pipeline", action="append")
    parser.add_argument("--pipelines", type=Path, default=HERE / "pipelines.json")
    parser.add_argument("--workload", action="append")
    parser.add_argument("--rounds", type=int, default=5)
    parser.add_argument("--samples", type=int, default=31)
    parser.add_argument("--target-ms", type=float, default=3)
    args = parser.parse_args()
    if args.rounds < 1 or args.samples < 5 or args.target_ms <= 0:
        parser.error("positive rounds/target and at least 5 samples required")
    soft, hard = resource.getrlimit(resource.RLIMIT_STACK)
    if soft != resource.RLIM_INFINITY and soft < 64 * 1024 * 1024:
        resource.setrlimit(resource.RLIMIT_STACK, (min(64 * 1024 * 1024, hard) if hard != resource.RLIM_INFINITY else 64 * 1024 * 1024, hard))
    configured = pipelines(args.pipelines)
    selected = {name: configured[name] for name in args.pipeline or ["O4s", "prune", "fold-inline"]}
    report = {"version": 1, "commands": [], "pipelines": selected, "workloads": [],
              "settings": {"rounds": args.rounds, "samples": args.samples, "target_ms": args.target_ms}}
    report["environment"] = environment(report["commands"])
    report["binaries"] = {"compiler": sha256(args.compiler), "starshine": sha256(args.starshine)}
    args.output = args.output.resolve()
    available = workloads()
    unknown = set(args.workload or []) - {work["name"] for work in available}
    if unknown:
        parser.error(f"unknown workloads: {sorted(unknown)}")
    for work in available:
        if args.workload and work["name"] not in args.workload:
            continue
        directory = args.output / work["name"]
        directory.mkdir(parents=True, exist_ok=True)
        source = directory / "benchmark.dew"
        source.write_text(work.pop("source"))
        result = {**work, "commands": [], "variants": {}, "rounds": []}
        report["workloads"].append(result)
        baseline = directory / "baseline.wasm"
        try:
            execute([args.compiler, baseline, source], result["commands"],
                    env={**os.environ, "DEW_CACHE_DIR": str(directory / "cache")})
            execute(["wasm-tools", "validate", "--features", "all", baseline], result["commands"])
            result["variants"]["baseline"] = {"status": "passed", "wasm": str(baseline), **wasm_sizes(baseline), "sha256": sha256(baseline)}
        except CommandFailure as error:
            result.update(status="baseline-failed", error=str(error))
            write_json(directory / "result.json", result)
            write_json(args.output / "report.json", report)
            print(f"baseline-failed: {work['name']}: {error}", flush=True)
            continue
        for name, flags in selected.items():
            variant = {"commands": []}
            result["variants"][name] = variant
            output = directory / f"{name}.wasm"
            try:
                variant.update(optimize(baseline, output, flags, args.starshine, variant["commands"]))
                variant.update(status="passed", wasm=str(output))
                # Check each variant alone before adding it to the timing set.
                spec = {**work, "variants": [{"name": name, "wasm": str(output)}]}
                write_json(directory / "check.json", spec)
                execute(["node", HERE / "benchmark.mjs", directory / "check.json", "5", "0.1"], variant["commands"])
            except CommandFailure as error:
                variant.update(status="failed", error=str(error))
        spec = {**work, "variants": [{"name": name, "wasm": data["wasm"]}
                  for name, data in result["variants"].items() if data["status"] == "passed"]}
        write_json(directory / "spec.json", spec)
        try:
            for round_index in range(args.rounds):
                # A fresh process per round; no compiler jobs run during timing.
                measured = execute(["node", HERE / "benchmark.mjs", directory / "spec.json",
                                    args.samples, args.target_ms], result["commands"])
                result["rounds"].append({**json.loads(measured.stdout),
                                         "load_average": list(os.getloadavg())})
            for name, variant in result["variants"].items():
                if variant["status"] == "passed":
                    medians = [statistics.median(r["variants"][name]["ns_per_call"]) for r in result["rounds"]]
                    variant["round_medians_ns"] = medians
                    variant["median_ns"] = statistics.median(medians)
            result["status"] = "passed" if all(v["status"] == "passed" for v in result["variants"].values()) else "failed"
        except CommandFailure as error:
            result.update(status="failed", error=str(error))
        write_json(directory / "result.json", result)
        write_json(args.output / "report.json", report)
        print(f"{result['status']}: {work['name']} " + ", ".join(
            f"{n}={v.get('median_ns', 0):.1f}ns/{v.get('bytes', 0)}B ({v['status']})"
            for n, v in result["variants"].items()), flush=True)
    write_json(args.output / "report.json", report)
    return int(any(work["status"] != "passed" for work in report["workloads"]))


if __name__ == "__main__":
    raise SystemExit(main())
