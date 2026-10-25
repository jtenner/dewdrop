#!/usr/bin/env python3
"""Measure step-2 tests and raw Wasm storage with existing native tools."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import re
import statistics
import subprocess
import time

ROOT = Path(__file__).resolve().parents[1]
PRIVATE_TESTS = [
    "btree_node_storage_test.dew",
    "btree_metadata_test.dew",
    "btree_capacity_matrix_test.dew",
]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("compiler", type=Path)
    parser.add_argument("generator", type=Path)
    parser.add_argument("--output", type=Path, default=ROOT / ".tmp/btree-step-2/acceptance")
    args = parser.parse_args()
    compiler, generator = args.compiler.resolve(), args.generator.resolve()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    samples = []

    def run(name, command, expected=0, diagnostic=None):
        command = [str(x) for x in command]
        start = time.monotonic()
        result = subprocess.run(command, cwd=ROOT, capture_output=True,
                                env=dict(os.environ, DEW_STD_ROOT=str(ROOT), DEW_PROGRAM_CACHE="0"))
        elapsed = time.monotonic() - start
        (output / (name + ".stdout")).write_bytes(result.stdout)
        (output / (name + ".stderr")).write_bytes(result.stderr)
        samples.append(dict(name=name, command=command, seconds=elapsed, exit=result.returncode))
        (output / "commands.json").write_text(json.dumps(samples, indent=2) + "\n")
        print(f"{name}: exit {result.returncode}, {elapsed:.3f} seconds", flush=True)
        if elapsed > 30:
            print("PERFORMANCE BUG: command exceeded 30 seconds", flush=True)
        if result.returncode != expected:
            raise AssertionError(f"{name}: expected exit {expected}; see {output}")
        if diagnostic and diagnostic not in (result.stdout + result.stderr).decode():
            raise AssertionError(f"{name}: missing {diagnostic!r}")
        return result.stdout.decode()

    def digest(path):
        return hashlib.sha256(path.read_bytes()).hexdigest()

    identity = dict(
        base="5f8bfb43e034ecbfd7cf6c11542c9a46239b63eb",
        head=subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip(),
        platform=platform.platform(), machine=platform.machine(),
        cpu=Path("/proc/cpuinfo").read_text().split("model name", 1)[-1].splitlines()[0].strip("\t :"),
        node=subprocess.check_output(["node", "--version"], text=True).strip(),
        moon=subprocess.check_output(["moon", "version"], text=True).strip(),
        wasm_tools=subprocess.check_output(["wasm-tools", "--version"], text=True).strip(),
        gc="Node default WasmGC; no custom flags; native host execution",
        emission="raw native release compiler; program cache off",
        compiler_sha256=digest(compiler), generator_sha256=digest(generator),
    )
    source_paths = [ROOT / "std/collections/btree.dew", Path(__file__).resolve()]
    source_paths += list((ROOT / "tools/btree-plans").glob("*"))
    source_paths += list((ROOT / "std/tests").glob("btree_*_test.dew"))
    identity["sources"] = {str(p.relative_to(ROOT)): digest(p) for p in sorted(source_paths) if p.is_file()}
    (output / "identity.json").write_text(json.dumps(identity, indent=2) + "\n")
    public = ROOT / "std/tests/btree_plans_providers_test.dew"
    run("public-tests", [generator, output / "public.wasm", "probe.tests", "probe.tests",
                         public.relative_to(ROOT), public])
    run("public-runtime", ["node", ROOT / "tools/dew-test/run.mjs", "--wasm",
                           output / "public.wasm", "--label", "B-tree public plans/providers"])
    private_command = [generator, output / "private.wasm", "probe.storage"]
    for path in [ROOT / "std/collections/btree.dew", ROOT / "tools/btree-plans/providers.dew",
                 *[ROOT / "std/tests" / name for name in PRIVATE_TESTS]]:
        private_command += ["probe.storage", path.relative_to(ROOT), path]
    run("private-tests", private_command)
    run("private-runtime", ["node", ROOT / "tools/dew-test/run.mjs", "--wasm",
                            output / "private.wasm", "--label", "B-tree private storage"])
    prefix = [compiler, "build", "--root", "probe.storage", "--module", "probe.storage"]
    sources = [ROOT / "std/collections/btree.dew", ROOT / "tools/btree-plans/providers.dew",
               ROOT / "tools/btree-plans/physical.dew"]
    run("physical", prefix + sources + ["-o", output / "physical.wasm"])
    run("physical-validate", ["wasm-tools", "validate", output / "physical.wasm"])
    wat = run("physical-print", ["wasm-tools", "print", output / "physical.wasm"])
    (output / "physical.wat").write_text(wat)
    run("physical-strip", ["wasm-tools", "strip", output / "physical.wasm", "-o", output / "physical-stripped.wasm"])
    types = {int(index): body for index, body in re.findall(r"^  \(type \(;(\d+);\) (.*)$", wat, re.M)}
    functions = {int(m[1]): m[0] for m in re.finditer(r"^  \(func \(;(\d+);\).*?^  \)", wat, re.M | re.S)}
    exports = {name: int(index) for name, index in re.findall(r'\(export "([^"]+)" \(func (\d+)\)\)', wat)}
    branch_type = int(re.search(r"\(result \(ref (\d+)\)\)", functions[exports["branch_payload"]])[1])
    unit_key_type = int(re.findall(r"struct.get (\d+) 0", functions[exports["unit_keys"]])[-1])
    prefix_type = int(re.search(r"\(result \(ref (\d+)\)\)", functions[exports["prefix_with"]])[1])
    node_type = int(re.search(r"\(result \(ref (\d+)\)\)", functions[exports["make_unit"]])[1])
    branch_fields = [int(index) for index in re.findall(r"\(field \(ref (\d+)\)\)", types[branch_type])]
    assert len(branch_fields) == 2 and types[branch_type].count("(field ") == 2
    assert types[branch_fields[0]] == "(array (mut eqref)))", types[branch_type]
    assert types[branch_fields[1]] == "(array (mut v128)))", types[branch_type]
    assert types[unit_key_type].count("(field ") == 1, "Unit body has only its key array"
    assert types[prefix_type].count("(mut v128)") == 4 and types[prefix_type].count("(mut i32)") == 1
    assert types[node_type].count("(field ") == 4 and types[node_type].count("(mut i32)") == 3
    plan_source = (ROOT / "std/collections/btree.dew").read_text().split("pub fn btree_plan", 1)[1].split("\nfn ", 1)[0]
    assert plan_source.count(".inline_width()") == 1, "custom width is read once per plan"
    (output / "gc-shapes.json").write_text(json.dumps(dict(
        inline_branch=dict(type=branch_type, shape=types[branch_type]),
        unit_key_body=dict(type=unit_key_type, shape=types[unit_key_type]),
        prefix=dict(type=prefix_type, shape=types[prefix_type]),
        node=dict(type=node_type, shape=types[node_type]),
        custom_width_reads_in_plan_source=1), indent=2) + "\n")
    assert "call_ref" not in wat, "no indirect provider lookup"
    for opcode in ["i16x8.lt_u", "i32x4.lt_u", "i64x2.lt_s", "v128.xor"]:
        assert opcode in wat, opcode
    # Instrument a copy. No imports or existing indices change.
    sites = sorted(set(re.findall(r"\b(array\.new_default|array\.new|struct\.new) (\d+)\b", wat)))
    extra = []
    for ordinal, (opcode, type_index) in enumerate(sites):
        extra += [f'  (global $alloc_{ordinal} (mut i64) (i64.const 0))',
                  f'  (export "alloc_{ordinal}" (global $alloc_{ordinal}))']
        pattern = rf"^(\s*{re.escape(opcode)} {type_index})$"
        wat = re.sub(pattern, rf"\1\n    global.get $alloc_{ordinal}\n    i64.const 1\n    i64.add\n    global.set $alloc_{ordinal}", wat, flags=re.M)
    extra.append('  (func (export "reset_allocations")')
    for ordinal in range(len(sites)):
        extra.append(f"    i64.const 0 global.set $alloc_{ordinal}")
    extra.append("  )")
    arrays = {}
    for index, kind in re.findall(r"\(type \(;(\d+);\) \(array \(mut (i32|i64|f32|f64|v128|eqref)\)\)\)", wat):
        arrays.setdefault(kind, int(index))
    assert {"i64", "v128", "eqref"} <= arrays.keys(), arrays
    ref_type, int_type, vector_type = arrays["eqref"], arrays["i64"], arrays["v128"]
    extra += [
        f'  (func (export "slot_null") (param eqref i32) (result i32) local.get 0 ref.cast (ref {ref_type}) local.get 1 array.get {ref_type} ref.is_null)',
        f'  (func (export "slot_i64") (param eqref i32) (result i64) local.get 0 ref.cast (ref {int_type}) local.get 1 array.get {int_type})',
        f'  (func (export "reference_length") (param eqref) (result i32) local.get 0 ref.cast (ref {ref_type}) array.len)',
        f'  (func (export "vector_length") (param eqref) (result i32) local.get 0 ref.cast (ref {vector_type}) array.len)',
    ]
    inspected = output / "physical-inspect.wat"
    inspected.write_text(wat.rstrip()[:-1] + "\n" + "\n".join(extra) + "\n)\n")
    (output / "allocation-sites.json").write_text(json.dumps(
        {f"alloc_{i}": dict(opcode=op, type=int(t)) for i, (op, t) in enumerate(sites)}, indent=2) + "\n")
    run("inspect-assemble", ["wasm-tools", "parse", inspected, "-o", output / "physical-inspect.wasm"])
    run("inspect-validate", ["wasm-tools", "validate", output / "physical-inspect.wasm"])
    run("physical-runtime", ["node", ROOT / "tools/btree-plans/run.mjs", output, "inspect"])
    for process in range(4):
        run(f"cost-{process}", ["node", ROOT / "tools/btree-plans/run.mjs", output, "cost", str(process)])
    cost_samples = [sample for path in sorted(output.glob("cost-*.json"))
                    for sample in json.loads(path.read_text())["samples"]]
    summary = {}
    for name in dict.fromkeys(sample["name"] for sample in cost_samples):
        values = [sample["ns_per_operation"] for sample in cost_samples if sample["name"] == name]
        summary[name] = dict(samples=len(values), median_ns=statistics.median(values),
                             minimum_ns=min(values), maximum_ns=max(values))
    (output / "cost-summary.json").write_text(json.dumps(summary, indent=2) + "\n")
    traits = {
        "hash": "impl InlineKeyHash<U64> for Bad {\n  fn inline_hash_tag(self, key: U64) -> U8 {\n    0u8\n  }\n}",
        "compare": "impl InlineKeyCompareFrom<U64> for Bad {\n  fn compare_from(self, left: U64, right: U64, equal_bytes: U32) -> Ordering {\n    Ordering::Equal\n  }\n}",
        "prefix": "impl InlineKeyPrefix<U64> for Bad {\n  fn compare_prefix(self, key: U64, prefix: BTreeInlinePrefix) -> Ordering {\n    Ordering::Equal\n  }\n}",
        "length": "impl InlineKeyLength<U64> for Bad {\n  fn inline_encoding_length(self, key: U64) -> U32 {\n    8u32\n  }\n}",
    }
    for label, impl in traits.items():
        source = output / f"invalid-{label}.dew"
        source.write_text("open dew.std.collections.btree\nopen dew.std.ordering\nstruct Bad {}\n"
                          "impl Comparator<U64> for Bad {\n  fn compare(self, left: U64, right: U64) -> Ordering {\n    Ordering::Equal\n  }\n}\n"
                          + impl + "\npub fn invalid() -> BTreePlan {\n  btree_plan::<U64, U64, Bad>(Bad::{}, btree_default_config())\n}\n")
        run(f"invalid-{label}", [compiler, "build", "--root", "probe.invalid", "--module", "probe.invalid",
                                source, "-o", output / f"invalid-{label}.wasm"], expected=1,
            diagnostic="optional inline evidence requires InlineKey")
    identity["modules"] = {p.name: dict(bytes=p.stat().st_size, sha256=digest(p)) for p in output.glob("*.wasm")}
    (output / "identity.json").write_text(json.dumps(identity, indent=2) + "\n")
    print("Step-2 probes passed. No map engine or balancing is implemented.")


if __name__ == "__main__":
    main()
