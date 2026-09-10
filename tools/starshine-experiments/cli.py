#!/usr/bin/env python3
"""Run all CLI source fixtures and execute successful builds after Starshine."""

import argparse
from pathlib import Path

from runner import (HERE, ROOT, STARSHINE, CommandFailure, check_output, environment,
                    execute, pipelines, optimize, write_json)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=ROOT / ".tmp/starshine-cli")
    parser.add_argument("--starshine", type=Path, default=STARSHINE)
    parser.add_argument("--dew", type=Path, default=ROOT / "tools/dew")
    parser.add_argument("--pipeline", action="append")
    args = parser.parse_args()
    args.output = args.output.resolve()
    configured = pipelines()
    selected = {name: configured[name] for name in args.pipeline or ["O4s"]}
    report = {"version": 1, "commands": [], "pipelines": selected, "cases": []}
    report["environment"] = environment(report["commands"])
    for suite in ["compile-pass", "compile-fail", "run-pass"]:
        for source in sorted((ROOT / "tests" / suite).rglob("*.dew")):
            name = source.relative_to(ROOT / "tests").with_suffix("").as_posix()
            directory = args.output / name
            directory.mkdir(parents=True, exist_ok=True)
            row = {"name": name, "commands": [], "pipelines": {}}
            report["cases"].append(row)
            relative = source.relative_to(ROOT)
            try:
                checked = execute([args.dew, "check", relative], row["commands"], allow_failure=True, timeout=600)
                if suite == "compile-fail":
                    if not checked.returncode:
                        raise AssertionError("expected compiler failure")
                    check_output(source.with_suffix(".txt").read_text(), checked.stdout + checked.stderr)
                    row["status"] = "expected-compile-failure"
                    write_json(directory / "result.json", row)
                    print(f"{row['status']}: {name}", flush=True)
                    continue
                if checked.returncode:
                    raise AssertionError(f"compiler failed: {checked.stdout}{checked.stderr}")
                baseline = directory / "baseline.wasm"
                execute([args.dew, "build", relative, "-o", baseline], row["commands"], timeout=600)
                execute(["wasm-tools", "validate", "--features", "all", baseline], row["commands"])
                before = execute(["node", ROOT / "tools/dew-run.mjs", baseline], row["commands"])
                if suite == "run-pass":
                    check_output(source.with_suffix(".txt").read_text(), before.stdout)
                row["status"] = "passed"
                for label, flags in selected.items():
                    trial = {"commands": []}
                    row["pipelines"][label] = trial
                    output = directory / f"{label}.wasm"
                    try:
                        trial.update(optimize(baseline, output, flags, args.starshine, trial["commands"]))
                        after = execute(["node", ROOT / "tools/dew-run.mjs", output], trial["commands"])
                        check_output(before.stdout, after.stdout)
                        trial["status"] = "passed"
                    except (CommandFailure, AssertionError) as error:
                        trial.update(status="failed", error=str(error))
                        row["status"] = "failed"
            except (CommandFailure, AssertionError) as error:
                row.update(status="baseline-failed", error=str(error))
            write_json(directory / "result.json", row)
            print(f"{row['status']}: {name}", flush=True)
    write_json(args.output / "report.json", report)
    return int(any(row["status"] in ["failed", "baseline-failed"] for row in report["cases"]))


if __name__ == "__main__":
    raise SystemExit(main())
