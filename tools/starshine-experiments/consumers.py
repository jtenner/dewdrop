#!/usr/bin/env python3
"""Check package, ABI, host, and parity fixtures before and after Starshine."""

import argparse
import json
import os
from pathlib import Path
import resource

from library import TEST_COMPILER
from runner import (COMPILER, HERE, ROOT, STARSHINE, CommandFailure, check_output,
                    environment, execute, optimize, pipelines, sha256, write_json)


def cases():
    rows = []
    for name, source, expected in [
        ("generic-v128-identity", "generics/generic-erased-scalar-adapter-runtime", 42),
        ("generic-aggregate-callback-i32", "functions/generic-aggregate-callback-adapter-runtime", 42),
        ("generic-enum-callback-i32", "functions/generic-aggregate-callback-adapter-runtime", 42),
        ("generic-eqref-identity", "generics/generic-erased-fallback-runtime", 42),
    ]:
        rows.append(dict(name="abi/" + name, build=[f"tests/module-snapshots/{source}.dew"],
                         consumer=f"tests/abi-consumers/{name}.wat", expected_value=expected))
    rows.append(dict(name="abi/runtime-trait-evidence", build=["--root", "app.main",
                     "--module", "app.main", "tests/abi-consumers/runtime-trait-evidence-provider.dew",
                     "--module", "fixture.runtime_evidence",
                     "tests/abi-consumers/runtime-trait-evidence-provider.modules/fixture.runtime_evidence/support.dew"],
                     consumer="tests/abi-consumers/runtime-trait-evidence-i32.wat", expected_value=673))
    for name, manifest in [("multi-module", "tests/cli/multi-module/dew.modules.json"),
                           ("imported-package", "tests/abi-consumers/imported-package/dew.json")]:
        rows.append(dict(name="cli/" + name, build=["--manifest", manifest]))
    rows.append(dict(name="cli/explicit-preamble", build=["--no-default-preamble",
                     "tests/cli/no-default-explicit-preamble.dew"]))
    rows.append(dict(name="cli/no-preamble-error", check=["--no-default-preamble",
                     "tests/cli/no-default-preamble.dew"], diagnostic="UnknownValueName"))
    manifest = ROOT / "tests/cli/test-package/dew.modules.json"
    package = json.loads(manifest.read_text())
    sources = [(module["name"], str((manifest.parent / name).relative_to(ROOT)))
               for module in package["modules"] for name in module["files"]]
    rows.append(dict(name="cli/test-package", tests=sources, root=package["root"]))
    rows.append(dict(name="cli/assertion-message", root="cli.message",
                     tests=[("cli.message", "tests/cli/assertion-message_test.dew")],
                     runtime_error="assertion failed: visible assertion λ"))
    rows.append(dict(name="host/facet", build=["--link-wasm", "facet",
                     "fixtures/facet/facet-adapter.wasm", "fixtures/facet/facet-import-smoke.dew"],
                     checker=["node", HERE / "check-facet.mjs"]))
    for name, files in [("utf", ["utf_parity.dew", "generated_cases.dew"]),
                        ("swar", ["typed_lane_parity.dew", "swar_parity.dew"]),
                        ("wasi", ["generated_cases.dew"])]:
        rows.append(dict(name="parity/" + name, module="parity." + name,
                         sources=[f"tools/{name}-parity/{file}" for file in files],
                         checker=["node", f"tools/{name}-parity/parity.mjs"]))
    return rows


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=ROOT / ".tmp/starshine-consumers")
    parser.add_argument("--compiler", type=Path, default=COMPILER)
    parser.add_argument("--test-compiler", type=Path, default=TEST_COMPILER)
    parser.add_argument("--starshine", type=Path, default=STARSHINE)
    parser.add_argument("--dew", type=Path, default=ROOT / "tools/dew")
    parser.add_argument("--pipeline", action="append")
    parser.add_argument("--case", action="append")
    args = parser.parse_args()
    soft, hard = resource.getrlimit(resource.RLIMIT_STACK)
    if soft != resource.RLIM_INFINITY and soft < 64 * 1024 * 1024:
        resource.setrlimit(resource.RLIMIT_STACK, (min(64 * 1024 * 1024, hard) if hard != resource.RLIM_INFINITY else 64 * 1024 * 1024, hard))
    args.output = args.output.resolve()
    configured = pipelines()
    selected = {name: configured[name] for name in args.pipeline or ["O4s"]}
    report = {"version": 1, "commands": [], "pipelines": selected, "cases": []}
    report["environment"] = environment(report["commands"])
    report["binaries"] = {"compiler": sha256(args.compiler), "test_compiler": sha256(args.test_compiler),
                          "starshine": sha256(args.starshine)}
    available = cases()
    unknown = set(args.case or []) - {case["name"] for case in available}
    if unknown:
        parser.error(f"unknown cases: {sorted(unknown)}")
    for case in available:
        if args.case and case["name"] not in args.case:
            continue
        directory = args.output / case["name"]
        directory.mkdir(parents=True, exist_ok=True)
        row = {"name": case["name"], "commands": [], "pipelines": {}}
        report["cases"].append(row)
        baseline = directory / "baseline.wasm"
        baseline.unlink(missing_ok=True)
        checker = case.get("checker", ["node", ROOT / "tools/dew-run.mjs"])
        if "tests" in case:
            checker = ["node", ROOT / "tools/dew-test/run.mjs", "--wasm"]
        consumer = directory / "consumer.wasm"

        def checked(binary, records):
            command = (["node", ROOT / "tools/dew-wasm-consumer.mjs", binary, consumer, "run", "i32"]
                       if "consumer" in case else [*checker, binary])
            process = execute(command, records, allow_failure="runtime_error" in case)
            if "runtime_error" in case:
                assert process.returncode != 0, "expected assertion failure"
                assert case["runtime_error"] in process.stdout + process.stderr, process.stdout + process.stderr
            if "expected_value" in case:
                observed = json.loads(process.stdout)
                assert observed["result"]["value"] == case["expected_value"], observed
            return process.stdout

        try:
            if "check" in case:
                process = execute([args.dew, "check", *case["check"]], row["commands"], allow_failure=True, timeout=600)
                assert process.returncode != 0, "expected compiler diagnostic"
                assert case["diagnostic"] in process.stdout + process.stderr, process.stdout + process.stderr
                row["status"] = "expected-compile-failure"
            else:
                if "wat" in case:
                    execute(["wasm-tools", "parse", case["wat"], "-o", baseline], row["commands"])
                elif "build" in case:
                    execute([args.dew, "build", *case["build"], "-o", baseline], row["commands"], timeout=600)
                else:
                    if "tests" in case:
                        command = [args.test_compiler, baseline, case["root"]]
                        for module, source in case["tests"]:
                            command.extend([module, source, source])
                    else:
                        source = directory / "combined.dew"
                        source.write_text("\n".join((ROOT / path).read_text() for path in case["sources"]))
                        command = [args.compiler, baseline, "production", case["module"], source.name, source]
                    execute(command, row["commands"], env={**os.environ, "DEW_CACHE_DIR": str(directory / "cache")})
                execute(["wasm-tools", "validate", "--features", "all", baseline], row["commands"])
                if "consumer" in case:
                    execute(["wasm-tools", "parse", case["consumer"], "-o", consumer], row["commands"])
                before = checked(baseline, row["commands"])
                row["baseline"] = {"stdout": before, "sha256": sha256(baseline)}
                row["status"] = "passed"
                for label, flags in selected.items():
                    trial = {"commands": []}
                    row["pipelines"][label] = trial
                    output = directory / f"{label}.wasm"
                    try:
                        trial.update(optimize(baseline, output, flags, args.starshine, trial["commands"]))
                        after = checked(output, trial["commands"])
                        # Test progress includes elapsed time; its assertions are the contract.
                        if "tests" not in case:
                            check_output(before, after)
                        trial.update(status="passed", stdout=after)
                    except (CommandFailure, AssertionError) as error:
                        trial.update(status="failed", error=str(error))
                        row["status"] = "failed"
        except (CommandFailure, AssertionError) as error:
            row.update(status="baseline-failed", error=str(error))
        write_json(directory / "result.json", row)
        write_json(args.output / "report.json", report)
        print(f"{row['status']}: {row['name']}", flush=True)
    return int(any(row["status"] in ["failed", "baseline-failed"] for row in report["cases"]))


if __name__ == "__main__":
    raise SystemExit(main())
