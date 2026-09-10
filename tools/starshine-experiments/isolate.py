#!/usr/bin/env python3
"""Replay every prefix of an explicit pass list against one runtime fixture."""

import argparse
import json
from pathlib import Path

from runner import (HERE, ROOT, STARSHINE, CommandFailure, check_output, execute,
                    pipelines, snapshots, write_json)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--fixture", required=True)
    parser.add_argument("--pipeline", required=True)
    parser.add_argument("--input-wasm", type=Path, help="replay the exact compiler output instead of the saved WAT")
    parser.add_argument("--starshine", type=Path, default=STARSHINE)
    parser.add_argument("--pipelines", type=Path, default=HERE / "pipelines.json")
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--runtime", choices=["node", "wago"], action="append")
    parser.add_argument("--wago", type=Path, help="prebuilt Wago runner; required for --runtime wago")
    args = parser.parse_args()
    engines = args.runtime or ["node"]
    if "wago" in engines and args.wago is None:
        parser.error("--runtime wago requires --wago")
    source = snapshots.fixture_paths([args.fixture])[0]
    expected = snapshots.load_expectation(source)
    args.output = args.output.resolve()
    args.output.mkdir(parents=True, exist_ok=True)
    flags = pipelines(args.pipelines)[args.pipeline]
    records = []
    binary = args.output / "baseline.wasm"
    if args.input_wasm:
        execute(["cp", args.input_wasm.resolve(), binary], records)
    else:
        execute(["wasm-tools", "parse", source.with_suffix(".wat"), "-o", binary], records)
    queue = json.loads(execute([args.starshine, *flags, "--emit-expanded-pass-queue-json", binary], records).stdout)
    passes = [row["name"] for row in queue["passes"]]
    report = {"version": 1, "fixture": args.fixture, "pipeline": args.pipeline,
              "input": str(args.input_wasm.resolve() if args.input_wasm else source.with_suffix(".wat")),
              "queue": queue, "commands": records, "prefixes": []}
    for length in range(len(passes) + 1):
        row = {"passes": passes[:length], "commands": []}
        report["prefixes"].append(row)
        output = args.output / f"prefix-{length}.wasm"
        try:
            execute([args.starshine, "--optimize-level", queue["optimizeLevel"],
                     "--shrink-level", queue["shrinkLevel"],
                     *("--" + name for name in passes[:length]), binary, "-o", output], row["commands"])
            execute(["wasm-tools", "validate", "--features", "all", output], row["commands"])
            for engine in engines:
                command = (["node", ROOT / "tools/module-snapshots/run-main.mjs"]
                           if engine == "node" else [args.wago.resolve()])
                process = execute([*command, output, json.dumps(expected.get("host", {})),
                                   snapshots.fixture_mode(source)], row["commands"], timeout=2)
                check_output(expected["output"], snapshots.parse_runtime_result(engine, process))
            row["status"] = "passed"
        except (CommandFailure, AssertionError, snapshots.SnapshotError) as error:
            row.update(status="failed", error=str(error))
        write_json(args.output / "report.json", report)
        print(f"{length}: {row['status']} {passes[length - 1] if length else '(round trip)'}", flush=True)
    return int(any(row["status"] == "failed" for row in report["prefixes"]))


if __name__ == "__main__":
    raise SystemExit(main())
