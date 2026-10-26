#!/usr/bin/env python3
"""Measure private step-3 tests and raw/production root-leaf paths."""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import platform
import re
import statistics
import subprocess
import time

ROOT = Path(__file__).resolve().parents[1]


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def code_section_bytes(path):
    data = path.read_bytes()
    position = 8
    while position < len(data):
        section = data[position]
        position += 1
        size, shift = 0, 0
        while True:
            byte = data[position]
            position += 1
            size |= (byte & 127) << shift
            if byte < 128:
                break
            shift += 7
        if section == 10:
            return size
        position += size
    return 0


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("compiler", type=Path)
    parser.add_argument("generator", type=Path)
    parser.add_argument("starshine", type=Path)
    parser.add_argument("--output", type=Path, default=ROOT / ".tmp/btree-step-3/final")
    parser.add_argument("--physical-only", action="store_true")
    args = parser.parse_args()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    records = []
    failures = []

    def run(name, command, collect_failure=False):
        command = [str(x) for x in command]
        start = time.monotonic()
        result = subprocess.run(command, cwd=ROOT, capture_output=True,
                                env=dict(os.environ, DEW_STD_ROOT=str(ROOT), DEW_PROGRAM_CACHE="0"))
        elapsed = time.monotonic() - start
        (output / (name + ".stdout")).write_bytes(result.stdout)
        (output / (name + ".stderr")).write_bytes(result.stderr)
        records.append(dict(name=name, command=command, seconds=elapsed, exit=result.returncode))
        (output / "commands.json").write_text(json.dumps(records, indent=2) + "\n")
        print(f"{name}: exit {result.returncode}, {elapsed:.3f} seconds", flush=True)
        if elapsed > 30:
            print("PERFORMANCE BUG: command exceeded 30 seconds", flush=True)
        if result.returncode:
            if collect_failure:
                failures.append(name)
            else:
                raise AssertionError(f"{name} failed; see {output}")
        return result.stdout.decode()

    spec = importlib.util.spec_from_file_location("assemble", ROOT / "tools/dew-test/assemble.py")
    assemble = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(assemble)
    compiler, generator, starshine = [p.resolve() for p in (args.compiler, args.generator, args.starshine)]
    identity = dict(
        base="bee17cd481a4d48f2ed02d895119ee05192defee",
        design="5922ea1a12ede3913f97b9b7bdac1f90343240f1",
        upstream="8adae97a0ed97e5c98fa2790312eb0aec9719846",
        head=subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip(),
        platform=platform.platform(), machine=platform.machine(),
        cpu=Path("/proc/cpuinfo").read_text().split("model name", 1)[-1].splitlines()[0].strip("\t :"),
        gc="Node default WasmGC; no custom flags; native host execution",
        DEW_STD_ROOT=str(ROOT), DEW_PROGRAM_CACHE="0",
        tools={str(p): digest(p) for p in (compiler, generator, starshine)},
        node=run("node-version", ["node", "--version"]).strip(),
        moon=run("moon-version", ["moon", "version"]).strip(),
        wasm_tools=run("wasm-tools-version", ["wasm-tools", "--version"]).strip(),
        starshine_pin=run("starshine-pin", ["git", "-C", "starshine-mb", "rev-parse", "HEAD"]).strip(),
    )
    paths = [ROOT / "std/collections/btree.dew", ROOT / "tools/btree-plans/providers.dew"]
    paths += [ROOT / "std/tests" / p for p in assemble.PRIVATE_BTREE_TESTS]
    paths += [ROOT / "std/tests/btree_plans_providers_test.dew"]
    paths += sorted((ROOT / "tools/btree-fit").glob("*")) + [Path(__file__).resolve()]
    identity["sources"] = {str(p.relative_to(ROOT)): digest(p) for p in paths if p.is_file()}
    (output / "identity.json").write_text(json.dumps(identity, indent=2) + "\n")
    flags = json.loads((ROOT / "tools/starshine-experiments/pipelines.json").read_text())["pipelines"]["O4s"]
    if not args.physical_only:
        public = ROOT / "std/tests/btree_plans_providers_test.dew"
        run("public-compile", [generator, output / "public.wasm", "probe.public", "probe.public", public.relative_to(ROOT), public])
        run("public-runtime", ["node", ROOT / "tools/dew-test/run.mjs", "--wasm", output / "public.wasm", "--label", "B-tree public plan/provider tests"])
        command = [generator, output / "private.wasm", "probe.fit"]
        for path in paths[:2 + len(assemble.PRIVATE_BTREE_TESTS)]:
            command += ["probe.fit", path.relative_to(ROOT), path]
        run("private-compile", command)
        run("private-runtime", ["node", ROOT / "tools/dew-test/run.mjs", "--wasm", output / "private.wasm", "--label", "B-tree step-3 private tests"])
        run("private-O4s", [starshine, *flags, output / "private.wasm", "-o", output / "private-O4s.wasm"])
        run("private-O4s-validate", ["wasm-tools", "validate", output / "private-O4s.wasm"])
        run("private-O4s-runtime", ["node", ROOT / "tools/dew-test/run.mjs", "--wasm", output / "private-O4s.wasm", "--label", "B-tree step-3 O4s private tests"])
        run("diagnostics", ["node", ROOT / "tools/btree-fit/diagnostics.mjs", output / "private.wasm", output / "diagnostics.json"])
    run("physical-compile", [compiler, "build", "--root", "probe.fit", "--module", "probe.fit", ROOT / "std/collections/btree.dew", ROOT / "tools/btree-fit/physical.dew", ROOT / "tools/btree-fit/carriers.dew", "-o", output / "raw.wasm"])
    run("physical-O4s", [starshine, *flags, output / "raw.wasm", "-o", output / "O4s.wasm"])
    for variant in ("raw", "O4s"):
        binary = output / f"{variant}.wasm"
        run(variant + "-validate", ["wasm-tools", "validate", binary])
        wat = run(variant + "-print", ["wasm-tools", "print", binary])
        (output / f"{variant}.wat").write_text(wat)
        types = {int(i): body for i, body in re.findall(r"^  \(type \(;(\d+);\) (.*)$", wat, re.M)}
        functions = {int(m[1]): m[0] for m in re.finditer(r"^  \(func \(;(\d+);\).*?^  \)", wat, re.M | re.S)}
        exports = {name: int(i) for name, i in re.findall(r'\(export "([^"]+)" \(func (\d+)\)\)', wat)}
        unit_type = int(re.search(r"\(result \(ref (\d+)\)\)", functions[exports["unit_body"]])[1])
        tree_type = int(re.search(r"\(result \(ref (\d+)\)\)", functions[exports["make_empty"]])[1])
        assert types[unit_type].count("(field ") == 1, "Unit body contains only its key array"
        assert types[tree_type].count("(field ") == 10, "root/count/work, six generic comparator carrier fields, and plan; lazy work reference only"
        (output / f"{variant}-gc-shapes.json").write_text(json.dumps(dict(unit_body=types[unit_type], plain_tree=types[tree_type]), indent=2) + "\n")
        search_bodies = {}
        for name in ("search_numeric", "search_text"):
            wrapper = functions[exports[name]]
            calls = re.findall(r"\b(?:call|return_call) (\d+)\b", wrapper)
            assert calls, f"{name}: expected the source search call"
            index = int(calls[-1])
            body = functions[index]
            forwarders = []
            seen = set()
            while not re.search(r"(?m)^\s*loop(?: |$)", body):
                assert index not in seen, f"{name}: forwarding cycle"
                seen.add(index)
                forwarders.append(dict(function=index, body=body,
                    fixed_ref_targets=[int(x) for x in re.findall(r"\bref\.func (\d+)\b", body)]))
                targets = re.findall(r"\b(?:call|return_call) (\d+)\b", body)
                assert targets, f"{name}: no search loop or direct forwarding target"
                index = int(targets[-1])
                body = functions[index]
            # Static Wasm branches, not CPU branch-counter measurements.
            search_bodies[name] = dict(function=index, body=body, forwarders=forwarders, static_opcodes={
                opcode: len(re.findall(rf"(?m)^\s*{re.escape(opcode)}(?: |$)", body))
                for opcode in ("loop", "if", "br_if", "br_table", "call", "call_ref", "i32.lt_s", "i32.shr_u", "i32.mul")})
        (output / f"{variant}-search-bodies.json").write_text(json.dumps(search_bodies, indent=2) + "\n")
        run(variant + "-strip", ["wasm-tools", "strip", binary, "-o", output / f"{variant}-stripped.wasm"])
        if variant == "raw":
            assert "call_ref" not in wat, "source specialization has no indirect comparator or policy calls"
        # Shared recorder includes every array/struct constructor form.
        recorder_spec = importlib.util.spec_from_file_location("btree_record", ROOT / "tools/btree-fit/record.py")
        recorder = importlib.util.module_from_spec(recorder_spec)
        recorder_spec.loader.exec_module(recorder)
        inspected_wat, sites = recorder.instrument(wat)
        instrumented = output / f"{variant}-inspect.wat"
        instrumented.write_text(inspected_wat)
        (output / f"{variant}-sites.json").write_text(json.dumps(sites, indent=2) + "\n")
        run(variant + "-instrument", ["wasm-tools", "parse", instrumented, "-o", output / f"{variant}-inspect.wasm"])
        run(variant + "-inspect-validate", ["wasm-tools", "validate", output / f"{variant}-inspect.wasm"])
        run(variant + "-allocations", ["node", ROOT / "tools/btree-fit/run.mjs", output, variant, "inspect"], collect_failure=True)
        for process in range(4):
            run(f"{variant}-cost-{process}", ["node", ROOT / "tools/btree-fit/run.mjs", output, variant, "cost", process])
        samples = [sample for i in range(4) for sample in json.loads((output / f"{variant}-cost-{i}.json").read_text())["samples"]]
        summary = {}
        for name in dict.fromkeys(x["name"] for x in samples):
            values = [s["ns_per_operation"] for s in samples if s["name"] == name]
            summary[name] = dict(samples=len(values), median_ns=statistics.median(values), minimum_ns=min(values), maximum_ns=max(values))
        (output / f"{variant}-summary.json").write_text(json.dumps(summary, indent=2) + "\n")
    identity["modules"] = {p.name: dict(bytes=p.stat().st_size, code_section_bytes=code_section_bytes(p), sha256=digest(p)) for p in sorted(output.glob("*.wasm"))}
    (output / "identity.json").write_text(json.dumps(identity, indent=2) + "\n")
    (output / "failed-checks.json").write_text(json.dumps(failures, indent=2) + "\n")
    if failures:
        raise AssertionError(f"Required allocation checks failed: {failures}; evidence saved in {output}")
    print("Root-leaf control checks passed; see the step-4 runner for split evidence.")


if __name__ == "__main__":
    main()
