#!/usr/bin/env python3
"""Run the Dew standard tests and every exported operation probe after optimization."""

import argparse
import os
from pathlib import Path
import shlex

from runner import (HERE, ROOT, STARSHINE, CommandFailure, environment, execute,
                    load_module, optimize, pipelines, sha256, write_json)

ASSEMBLY = load_module("dew_test_assembly", ROOT / "tools/dew-test/assemble.py")
TEST_COMPILER = ROOT / "_build/native/release/build/jtenner/dewdrop/dew_test_gen/dew_test_gen.exe"


def cases():
    checkers = {}
    for line in (ROOT / "tools/dew-test/run.sh").read_text().splitlines():
        parts = shlex.split(line) if line.startswith("node tools/check-") or line.startswith("node tools/wasi-parity/") else []
        if parts:
            checkers[Path(parts[2]).stem] = parts[:2]
    rows = []
    # Keep each source file visible if another standard test cannot compile.
    for path in sorted((ROOT / "std/tests").glob("*_test.dew")):
        rows.append(("std/" + path.stem, "dew.std", [(path.as_posix(), path)],
                     ["node", "tools/dew-test/run.mjs", "--wasm"]))
    for fixture, module in ASSEMBLY.PROBE_MODULES:
        path = ROOT / f"tools/dew-test/{fixture}.dew"
        rows.append(("probes/" + fixture, module, [(path.as_posix(), path)], checkers.pop(fixture)))
    for name, module, sources in [
        ("wasi_foreign", "app.wasi_probes", [("wasi-preview1-runtime.dew", ROOT / "tests/module-snapshots/wasm/wasi-preview1-runtime.dew")]),
        ("wasi_staging", "app.wasi_staging", [("staging.dew", ROOT / "tools/wasi-parity/staging.dew"), ("staging_probes.dew", ROOT / "tools/wasi-parity/staging_probes.dew")]),
    ]:
        rows.append(("probes/" + name, module, sources, checkers.pop(name)))
    if checkers:
        raise ValueError(f"unmapped operation checkers: {checkers}")
    path = ROOT / "tools/dew-test/builtin_traps.dew"
    rows.append(("probes/builtin_traps", "dew.std.traps", [("builtin_traps_test.dew", path)],
                 ["node", str(HERE / "check-traps.mjs")]))
    return rows


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=ROOT / ".tmp/starshine-library")
    parser.add_argument("--compiler", type=Path, default=TEST_COMPILER)
    parser.add_argument("--starshine", type=Path, default=STARSHINE)
    parser.add_argument("--pipeline", action="append")
    parser.add_argument("--pipelines", type=Path, default=HERE / "pipelines.json")
    parser.add_argument("--case", action="append")
    args = parser.parse_args()
    args.output = args.output.resolve()
    configured = pipelines(args.pipelines)
    selected = {name: configured[name] for name in args.pipeline or ["O4s"]}
    report = {"version": 1, "commands": [], "pipelines": selected, "cases": []}
    report["environment"] = environment(report["commands"])
    report["binaries"] = {"compiler": sha256(args.compiler), "starshine": sha256(args.starshine)}
    available = cases()
    unknown = set(args.case or []) - {row[0] for row in available}
    if unknown:
        parser.error(f"unknown library cases: {sorted(unknown)}")
    for name, module, sources, checker in available:
        if args.case and name not in args.case:
            continue
        directory = args.output / name
        directory.mkdir(parents=True, exist_ok=True)
        baseline = directory / "baseline.wasm"
        baseline.unlink(missing_ok=True)
        result = {"name": name, "commands": [], "pipelines": {}}
        report["cases"].append(result)
        command = [args.compiler, baseline, module]
        for logical, path in sources:
            command.extend([module, logical, path])
        try:
            execute(command, result["commands"], env={**os.environ, "DEW_CACHE_DIR": str(directory / "cache")})
            execute(["wasm-tools", "validate", "--features", "all", baseline], result["commands"])
            baseline_run = execute([*(arg.replace("{wasm}", str(baseline)) for arg in checker), baseline], result["commands"])
            result["baseline"] = {"bytes": baseline.stat().st_size, "sha256": sha256(baseline), "stdout": baseline_run.stdout}
            result["status"] = "passed"
        except CommandFailure as error:
            result.update(status="baseline-failed", error=str(error))
            write_json(directory / "result.json", result)
            print(f"baseline-failed: {name}", flush=True)
            continue
        for label, flags in selected.items():
            trial = {"commands": []}
            result["pipelines"][label] = trial
            output = directory / f"{label}.wasm"
            try:
                trial.update(optimize(baseline, output, flags, args.starshine, trial["commands"]))
                checked = execute([*(arg.replace("{wasm}", str(output)) for arg in checker), output], trial["commands"])
                trial.update(status="passed", stdout=checked.stdout)
            except CommandFailure as error:
                trial.update(status="failed", error=str(error))
                result["status"] = "failed"
        write_json(directory / "result.json", result)
        print(f"{result['status']}: {name}", flush=True)
    report["summary"] = {status: sum(row["status"] == status for row in report["cases"])
                         for status in ["passed", "baseline-failed", "failed"]}
    write_json(args.output / "report.json", report)
    print(report["summary"])
    return int(any(row["status"] != "passed" for row in report["cases"]))


if __name__ == "__main__":
    raise SystemExit(main())
