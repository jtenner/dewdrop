#!/usr/bin/env python3
"""Generate Dew raw bindings from the pinned Starshine WasmGC FFI exports."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import TypeAlias

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_WASM = ROOT / "starshine-mb" / "dist" / "ffi" / "starshine-ffi.wasm"
EXPORT_NAMES = (
    ROOT
    / "starshine-mb"
    / "ffi"
    / "src"
    / "ffi"
    / "export-names.generated.json"
)
TARGET = ROOT / "self_host" / "starshine" / "ffi.dew"
MANIFEST = ROOT / "self_host" / "starshine" / "ffi-bindings.json"
USED_EXPORTS = ROOT / "self_host" / "starshine" / "ffi-used.json"
FINGERPRINT_TARGET = ROOT / "self_host" / "starshine" / "fingerprint.dew"
FINGERPRINT_PREFIX_TARGET = (
    ROOT / "self_host" / "starshine" / "fingerprint-prefix.bin"
)
INTERFACE_PATHS = (
    ROOT / "starshine-mb" / "src" / "lib" / "pkg.generated.mbti",
    ROOT / "starshine-mb" / "src" / "binary" / "pkg.generated.mbti",
    ROOT / "starshine-mb" / "src" / "validate" / "pkg.generated.mbti",
    ROOT / "starshine-mb" / "src" / "ffi_bridge" / "pkg.generated.mbti",
)
FINGERPRINT_DOMAIN = b"DEW_SELF_HOST_COMPILER_FINGERPRINT_V1\x00"

SExpr: TypeAlias = str | list["SExpr"]


@dataclass(frozen=True)
class ExportBinding:
    ordinal: int
    function_index: int
    internal_name: str
    export_name: str
    parameters: tuple[SExpr, ...]
    results: tuple[SExpr, ...]
    signature: str
    unsupported_reason: str | None


@dataclass(frozen=True)
class CarrierProbe:
    export_name: str
    location: str
    index: int


@dataclass(frozen=True)
class CarrierAssertion:
    alias: str
    probes: tuple[CarrierProbe, ...]


# These checks give stable Dew names to provider types that can move when
# Starshine adds a new internal type. Each list also proves that all listed
# exports use one physical carrier. Generation stops before Dew compilation if
# the provider breaks one of these relations.
CARRIER_ASSERTIONS = (
    CarrierAssertion(
        "StarshineValue",
        (
            CarrierProbe("ValType::i32", "result", 0),
            CarrierProbe("Instruction::i32_const", "result", 0),
            CarrierProbe("ffi_bridge::instructions_push", "parameter", 1),
        ),
    ),
    CarrierAssertion(
        "StarshineRecTypes",
        (
            CarrierProbe("ffi_bridge::rec_types_new", "result", 0),
            CarrierProbe("ffi_bridge::rec_types_push", "parameter", 0),
            CarrierProbe("TypeSec::new", "parameter", 0),
            CarrierProbe("TypeSec::new", "result", 0),
        ),
    ),
    CarrierAssertion(
        "StarshineInstructions",
        (
            CarrierProbe("ffi_bridge::instructions_new", "result", 0),
            CarrierProbe("ffi_bridge::instructions_push", "parameter", 0),
            CarrierProbe("Expr::new", "parameter", 0),
            CarrierProbe("Expr::new", "result", 0),
        ),
    ),
    CarrierAssertion(
        "StarshineFunctions",
        (
            CarrierProbe("ffi_bridge::funcs_new", "result", 0),
            CarrierProbe("ffi_bridge::funcs_push", "parameter", 0),
            CarrierProbe("CodeSec::new", "parameter", 0),
            CarrierProbe("CodeSec::new", "result", 0),
        ),
    ),
    CarrierAssertion(
        "StarshineImports",
        (
            CarrierProbe("ffi_bridge::imports_new", "result", 0),
            CarrierProbe("ffi_bridge::imports_push_builder", "parameter", 0),
            CarrierProbe("ImportSec::new", "parameter", 0),
            CarrierProbe("ImportSec::new", "result", 0),
        ),
    ),
    CarrierAssertion(
        "StarshineModule",
        (
            CarrierProbe("ffi_bridge::module_new", "result", 0),
            CarrierProbe(
                "ffi_bridge::module_with_dewdrop_compiler_facts", "parameter", 0
            ),
            CarrierProbe(
                "ffi_bridge::module_with_dewdrop_compiler_facts", "result", 0
            ),
            CarrierProbe("ffi_bridge::validate_module", "parameter", 0),
            CarrierProbe("ffi_bridge::encode_module", "parameter", 0),
        ),
    ),
    CarrierAssertion(
        "StarshineValueTypes",
        (
            CarrierProbe("ffi_bridge::val_types_new", "result", 0),
            CarrierProbe("ffi_bridge::val_types_push", "parameter", 0),
            CarrierProbe("CompType::func", "parameter", 0),
            CarrierProbe("CompType::func", "parameter", 1),
        ),
    ),
    CarrierAssertion(
        "StarshineLocals",
        (
            CarrierProbe("Locals::empty", "result", 0),
            CarrierProbe("Locals::push", "parameter", 0),
            CarrierProbe("Func::new", "parameter", 0),
        ),
    ),
    CarrierAssertion(
        "StarshineImportBuilder",
        (
            CarrierProbe("ffi_bridge::import_builder_new", "result", 0),
            CarrierProbe("ImportBuilder::push_module_byte", "parameter", 0),
            CarrierProbe("ImportBuilder::push_field_byte", "parameter", 0),
            CarrierProbe("ffi_bridge::imports_push_builder", "parameter", 1),
        ),
    ),
    CarrierAssertion(
        "StarshineRuntimeFunctionBuilder",
        (
            CarrierProbe("ffi_bridge::runtime_function_builder_new", "result", 0),
            CarrierProbe("RuntimeFunctionBuilder::push_name_byte", "parameter", 0),
            CarrierProbe("ffi_bridge::funcs_push_runtime", "parameter", 1),
        ),
    ),
)

# Names come from the provider API, never from its current Wasm type ordering.
# Multiple logical aliases may share a carrier; they must not create distinct
# foreign types for the same provider heap type.
CARRIER_ASSERTIONS += tuple(
    CarrierAssertion(alias, tuple(CarrierProbe(*probe) for probe in probes))
    for alias, probes in (
        ("StarshineTypeIndices", (("ffi_bridge::type_indices_new", "result", 0),
                                 ("FuncSec::new", "parameter", 0))),
        ("StarshineTypeMetadata", (("SubType::comp_type", "parameter", 1),
                                  ("SubType::new", "parameter", 3))),
        ("StarshineFieldType", (("FieldType::new", "result", 0),
                               ("CompType::array", "parameter", 0))),
        ("StarshineFieldTypes", (("ffi_bridge::field_types_new", "result", 0),
                                ("CompType::struct_", "parameter", 0))),
        ("StarshineEncodedModule", (("ffi_bridge::encode_module", "result", 0),
                                   ("EncodedModule::byte_at", "parameter", 0))),
        ("StarshineGlobalBuilder", (("ffi_bridge::global_builder_new", "result", 0),
                                   ("GlobalBuilder::push", "parameter", 0))),
        ("StarshineFunctionReferenceBuilder", (
            ("ffi_bridge::function_reference_builder_new", "result", 0),
            ("FunctionReferenceBuilder::push", "parameter", 0))),
        ("StarshineCodeSec", (("CodeSec::new", "result", 0),
                             ("ffi_bridge::funcs_new", "result", 0))),
        ("StarshineTypeSec", (("TypeSec::new", "result", 0),
                             ("ffi_bridge::rec_types_new", "result", 0))),
        ("StarshineFuncSec", (("FuncSec::new", "result", 0),
                             ("ffi_bridge::type_indices_new", "result", 0))),
        ("StarshineImportSec", (("ImportSec::new", "result", 0),
                               ("ffi_bridge::imports_new", "result", 0))),
        ("StarshineExpr", (("Expr::new", "result", 0),
                          ("ffi_bridge::instructions_new", "result", 0))),
    )
)


def parse_sexpr(text: str) -> SExpr:
    tokens = re.findall(r"\(|\)|[^\s()]+", text)
    index = 0

    def parse_one() -> SExpr:
        nonlocal index
        if index >= len(tokens):
            raise ValueError("truncated S-expression")
        token = tokens[index]
        index += 1
        if token != "(":
            if token == ")":
                raise ValueError("unexpected closing parenthesis")
            return token
        values: list[SExpr] = []
        while index < len(tokens) and tokens[index] != ")":
            values.append(parse_one())
        if index >= len(tokens):
            raise ValueError("unterminated S-expression")
        index += 1
        return values

    value = parse_one()
    if index != len(tokens):
        raise ValueError("trailing S-expression tokens")
    return value


def balanced_groups(line: str, head: str) -> list[str]:
    groups: list[str] = []
    start = 0
    needle = f"({head}"
    while True:
        found = line.find(needle, start)
        if found < 0:
            return groups
        depth = 0
        end = found
        while end < len(line):
            if line[end] == "(":
                depth += 1
            elif line[end] == ")":
                depth -= 1
                if depth == 0:
                    groups.append(line[found : end + 1])
                    start = end + 1
                    break
            end += 1
        else:
            raise ValueError(f"unterminated {head} group: {line}")


def group_value_types(group: str, head: str) -> tuple[SExpr, ...]:
    parsed = parse_sexpr(group)
    if not isinstance(parsed, list) or not parsed or parsed[0] != head:
        raise ValueError(f"invalid {head} group: {group}")
    values = list(parsed[1:])
    if values and isinstance(values[0], str) and values[0].startswith("$"):
        values.pop(0)
    return tuple(values)


def render_wat_type(value: SExpr) -> str:
    if isinstance(value, str):
        return value
    return "(" + " ".join(render_wat_type(item) for item in value) + ")"


def dew_type(value: SExpr) -> tuple[str | None, str | None]:
    if isinstance(value, str):
        primitive = {
            "i32": "I32",
            "i64": "I64",
            "f32": "F32",
            "f64": "F64",
            "v128": "V128",
        }.get(value)
        if primitive is None:
            return None, f"unsupported abstract or unknown Wasm value type {value}"
        return primitive, None
    if len(value) == 2 and value[0] == "ref" and isinstance(value[1], str):
        try:
            type_index = int(value[1])
        except ValueError:
            return None, f"unsupported abstract Wasm reference {render_wat_type(value)}"
        return f"StarshineRef{type_index}", None
    if (
        len(value) == 3
        and value[0] == "ref"
        and value[1] == "null"
        and isinstance(value[2], str)
    ):
        try:
            type_index = int(value[2])
        except ValueError:
            return None, f"unsupported abstract Wasm reference {render_wat_type(value)}"
        return f"NullableRef<StarshineRef{type_index}>", None
    return None, f"unsupported Wasm value type {render_wat_type(value)}"


def function_signature(line: str) -> tuple[tuple[SExpr, ...], tuple[SExpr, ...]]:
    parameter_groups = balanced_groups(line, "param")
    result_groups = balanced_groups(line, "result")
    parameters: list[SExpr] = []
    results: list[SExpr] = []
    for group in parameter_groups:
        parameters.extend(group_value_types(group, "param"))
    for group in result_groups:
        results.extend(group_value_types(group, "result"))
    return tuple(parameters), tuple(results)


def reference_index(value: SExpr) -> int:
    if isinstance(value, list) and len(value) == 3 and value[:2] == ["ref", "null"]:
        return reference_index(["ref", value[2]])
    if (
        isinstance(value, list)
        and len(value) == 2
        and value[0] == "ref"
        and isinstance(value[1], str)
    ):
        try:
            return int(value[1])
        except ValueError as error:
            raise ValueError(
                f"compile-time carrier assertion found a non-numeric reference: "
                f"{render_wat_type(value)}"
            ) from error
    raise ValueError(
        "compile-time carrier assertion requires one typed reference, got "
        + render_wat_type(value)
    )


def validate_carrier_assertions(
    bindings: list[ExportBinding],
    assertions: tuple[CarrierAssertion, ...] = CARRIER_ASSERTIONS,
) -> dict[str, int]:
    by_name = {binding.export_name: binding for binding in bindings}
    aliases: dict[str, int] = {}
    for assertion in assertions:
        observed: list[tuple[CarrierProbe, int]] = []
        for probe in assertion.probes:
            binding = by_name.get(probe.export_name)
            if binding is None:
                raise ValueError(
                    "compile-time carrier assertion is missing export "
                    f"{probe.export_name} for {assertion.alias}"
                )
            values = (
                binding.parameters if probe.location == "parameter" else binding.results
            )
            if probe.location not in ("parameter", "result") or probe.index >= len(values):
                raise ValueError(
                    "compile-time carrier assertion has no "
                    f"{probe.location} {probe.index} on {probe.export_name}"
                )
            observed.append((probe, reference_index(values[probe.index])))
        expected = observed[0][1]
        mismatch = next((item for item in observed if item[1] != expected), None)
        if mismatch is not None:
            probe, actual = mismatch
            raise ValueError(
                "compile-time carrier assertion failed for "
                f"{assertion.alias}: expected ref {expected}, but "
                f"{probe.export_name} {probe.location} {probe.index} uses ref {actual}"
            )
        aliases[assertion.alias] = expected
    return aliases


def inspect_exports(wasm: Path) -> tuple[list[ExportBinding], str]:
    if not wasm.exists():
        raise SystemExit(
            f"missing {wasm.relative_to(ROOT)}; run tools/starshine-ffi.sh build"
        )
    printed = subprocess.run(
        ["wasm-tools", "print", str(wasm)],
        cwd=ROOT,
        check=True,
        stdout=subprocess.PIPE,
        text=True,
    ).stdout
    exports = [
        (name, int(function_index))
        for name, function_index in re.findall(
            r'^  \(export "([^"]+)" \(func (\d+)\)\)$', printed, re.MULTILINE
        )
    ]
    function_lines = {
        int(function_index): line
        for function_index, line in re.findall(
            r"^  \(func \(;([0-9]+);\)([^\n]*)", printed, re.MULTILINE
        )
    }
    if not exports:
        raise SystemExit("Starshine FFI module has no function exports")
    name_map = json.loads(EXPORT_NAMES.read_text(encoding="utf-8"))
    reverse_names = {export_name: internal for internal, export_name in name_map.items()}
    if len(reverse_names) != len(name_map):
        raise SystemExit("Starshine FFI export-name metadata contains duplicate exports")
    binary_names = {name for name, _ in exports}
    metadata_names = set(reverse_names)
    if binary_names != metadata_names:
        missing = sorted(metadata_names - binary_names)
        extra = sorted(binary_names - metadata_names)
        raise SystemExit(
            "Starshine FFI binary/export metadata mismatch; "
            f"missing={missing[:3]}, extra={extra[:3]}"
        )
    bindings: list[ExportBinding] = []
    for ordinal, (export_name, function_index) in enumerate(exports):
        line = function_lines.get(function_index)
        if line is None:
            raise SystemExit(f"missing function body header for export {export_name}")
        parameters, results = function_signature(line)
        reasons: list[str] = []
        for value in (*parameters, *results):
            _, reason = dew_type(value)
            if reason is not None and reason not in reasons:
                reasons.append(reason)
        if len(results) > 1:
            reasons.append("Dew foreign declarations do not support multi-value results")
        signature = "(" + ", ".join(render_wat_type(v) for v in parameters) + ")"
        signature += " -> "
        signature += (
            "Unit"
            if not results
            else ", ".join(render_wat_type(v) for v in results)
        )
        bindings.append(
            ExportBinding(
                ordinal=ordinal,
                function_index=function_index,
                internal_name=reverse_names[export_name],
                export_name=export_name,
                parameters=parameters,
                results=results,
                signature=signature,
                unsupported_reason="; ".join(reasons) if reasons else None,
            )
        )
    return bindings, hashlib.sha256(wasm.read_bytes()).hexdigest()


def select_bindings(
    available: list[ExportBinding], requested: list[str]
) -> list[ExportBinding]:
    if len(requested) != len(set(requested)):
        raise ValueError("Starshine FFI used-export list contains duplicates")
    by_name = {binding.export_name: binding for binding in available}
    missing = [name for name in requested if name not in by_name]
    if missing:
        raise ValueError(
            "Starshine FFI used-export list names missing provider exports: "
            + ", ".join(missing[:3])
        )
    selected = [by_name[name] for name in requested]
    unsupported = [
        binding.export_name
        for binding in selected
        if binding.unsupported_reason is not None
    ]
    if unsupported:
        raise ValueError(
            "Starshine FFI used-export list selects unsupported exports: "
            + ", ".join(unsupported[:3])
        )
    return selected


def encode_fingerprint_field(value: bytes) -> bytes:
    return len(value).to_bytes(4, "little") + value


def fingerprint_prefix(
    submodule_revision: str,
    interfaces: list[tuple[str, bytes]],
    bindings: list[ExportBinding],
) -> bytes:
    output = bytearray(FINGERPRINT_DOMAIN)
    output.extend(encode_fingerprint_field(submodule_revision.encode("ascii")))
    output.extend(len(interfaces).to_bytes(4, "little"))
    for path, digest in interfaces:
        if len(digest) != 32:
            raise ValueError(f"interface digest for {path} is not 32 bytes")
        output.extend(encode_fingerprint_field(path.encode("utf-8")))
        output.extend(digest)
    output.extend(len(bindings).to_bytes(4, "little"))
    for binding in bindings:
        output.extend(encode_fingerprint_field(binding.export_name.encode("utf-8")))
        output.extend(encode_fingerprint_field(binding.signature.encode("utf-8")))
    return bytes(output)


def dew_bytes_literal(value: bytes) -> str:
    return 'b"' + "".join(f"\\x{byte:02X}" for byte in value) + '"'


def render_fingerprint_dew(prefix: bytes) -> str:
    return "\n".join(
        [
            "// Generated by tools/generate_starshine_ffi_consumer.py. Do not edit.",
            "// BLAKE3 input: this frozen ABI prefix followed by exact provider bytes.",
            "",
            "open dew.std.blake3",
            "open dew.std.bytes",
            "",
            "pub fn starshine_compiler_fingerprint_prefix() -> Bytes {",
            f"  {dew_bytes_literal(prefix)}",
            "}",
            "",
            "pub fn starshine_compiler_fingerprint(provider: Bytes) -> FixedArray<U8> {",
            "  blake3(starshine_compiler_fingerprint_prefix().concat(provider))",
            "}",
            "",
        ]
    )


def render_dew(
    bindings: list[ExportBinding], digest: str, carrier_aliases: dict[str, int]
) -> str:
    supported = [binding for binding in bindings if binding.unsupported_reason is None]
    carrier_names: dict[int, str] = {}
    for alias, index in carrier_aliases.items():
        carrier_names.setdefault(index, alias)

    def named_type(value: SExpr) -> str:
        if isinstance(value, list):
            index = reference_index(value)
            if index not in carrier_names:
                raise ValueError(f"no stable carrier name for {render_wat_type(value)}")
            name = carrier_names[index]
            return f"NullableRef<{name}>" if value[1] == "null" else name
        rendered, reason = dew_type(value)
        if rendered is None or reason is not None:
            raise ValueError(reason)
        return rendered

    for binding in supported:
        for value in (*binding.parameters, *binding.results):
            named_type(value)
    lines = [
        "// Generated by tools/generate_starshine_ffi_consumer.py. Do not edit.",
        "// Raw carrier bindings for provider \"starshine\".",
        f"// Provider SHA-256: {digest}",
        f"// Bound exports: {len(supported)} of {len(bindings)}.",
        "// Nullable WasmGC references retain NullableRef<NamedCarrier>.",
        "",
        "open dew.std.wasm.intrinsics",
        "",
    ]
    for name in sorted(carrier_names.values()):
        lines.append(f"pub foreign type {name}")
    lines.extend(
        [
            "",
            "// These aliases name compiler-visible ABI carriers.",
            "// The generator proves each alias from all related FFI signatures.",
            "// Generation stops before compilation if one relation changes.",
        ]
    )
    for alias, index in carrier_aliases.items():
        if alias != carrier_names[index]:
            lines.append(f"pub type {alias} = {carrier_names[index]}")
    lines.extend(["", 'foreign impl "starshine" as StarshineFfi {'])
    for binding in supported:
        parameters = []
        for index, value in enumerate(binding.parameters):
            rendered = named_type(value)
            parameters.append(f"value{index}: {rendered}")
        if not binding.results:
            result = "Unit"
        else:
            result = named_type(binding.results[0])
            owner, _, member = binding.export_name.partition("::")
            alias = f"Starshine{owner}"
            if member == "new" and alias in carrier_aliases:
                if reference_index(binding.results[0]) != carrier_aliases[alias]:
                    raise ValueError(f"constructor carrier mismatch for {binding.export_name}")
                result = alias
        prefix = f"  fn {binding.internal_name}("
        suffix = f') -> {result} = "{binding.export_name}"'
        one_line = prefix + ", ".join(parameters) + suffix
        if len(one_line) <= 100:
            lines.append(one_line)
        else:
            lines.append(prefix)
            for parameter in parameters:
                lines.append(f"    {parameter},")
            lines.append(f"  {suffix}")
    lines.extend(["}", ""])
    return "\n".join(lines)


def render_manifest(
    available: list[ExportBinding],
    selected: list[ExportBinding],
    digest: str,
    wasm: Path,
    submodule_revision: str,
    interfaces: list[tuple[str, bytes]],
    prefix: bytes,
) -> str:
    data = {
        "version": 1,
        "provider": "starshine",
        "submodule_revision": submodule_revision,
        "wasm_path": wasm.relative_to(ROOT).as_posix(),
        "wasm_sha256": digest,
        "available_export_count": len(available),
        "binding_count": len(selected),
        "interfaces": [
            {"path": path, "sha256": interface_digest.hex()}
            for path, interface_digest in interfaces
        ],
        "fingerprint": {
            "algorithm": "blake3-256",
            "domain": FINGERPRINT_DOMAIN.decode("ascii", errors="strict").rstrip("\x00"),
            "prefix_sha256": hashlib.sha256(prefix).hexdigest(),
            "provider_input": "exact wasm bytes appended after the prefix",
        },
        "exports": [
            {
                "ordinal": binding.ordinal,
                "function_index": binding.function_index,
                "internal_name": binding.internal_name,
                "export_name": binding.export_name,
                "signature": binding.signature,
                "status": "bound" if binding.unsupported_reason is None else "unsupported",
                **(
                    {}
                    if binding.unsupported_reason is None
                    else {"reason": binding.unsupported_reason}
                ),
            }
            for binding in selected
        ],
    }
    return json.dumps(data, indent=2, ensure_ascii=False) + "\n"


def write_or_check(path: Path, content: str | bytes, check: bool) -> None:
    if check:
        current = path.read_bytes() if path.exists() else None
        expected = content.encode("utf-8") if isinstance(content, str) else content
        if current != expected:
            raise SystemExit(
                f"{path.relative_to(ROOT)} is stale; run "
                "tools/generate_starshine_ffi_consumer.py"
            )
        print(f"checked {path.relative_to(ROOT)}")
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    if isinstance(content, str):
        path.write_text(content, encoding="utf-8")
    else:
        path.write_bytes(content)
    print(f"generated {path.relative_to(ROOT)}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--wasm", type=Path, default=DEFAULT_WASM)
    args = parser.parse_args()
    wasm = args.wasm.resolve()
    available, digest = inspect_exports(wasm)
    used_data = json.loads(USED_EXPORTS.read_text(encoding="utf-8"))
    if used_data.get("version") != 1 or not isinstance(used_data.get("exports"), list):
        raise SystemExit("invalid self_host/starshine/ffi-used.json")
    try:
        selected = select_bindings(available, used_data["exports"])
    except ValueError as error:
        raise SystemExit(str(error)) from error
    submodule_revision = subprocess.run(
        ["git", "-C", "starshine-mb", "rev-parse", "HEAD"],
        cwd=ROOT,
        check=True,
        stdout=subprocess.PIPE,
        text=True,
    ).stdout.strip()
    interfaces = [
        (
            path.relative_to(ROOT / "starshine-mb").as_posix(),
            hashlib.sha256(path.read_bytes()).digest(),
        )
        for path in INTERFACE_PATHS
    ]
    prefix = fingerprint_prefix(submodule_revision, interfaces, selected)
    try:
        carrier_aliases = validate_carrier_assertions(selected)
    except ValueError as error:
        raise SystemExit(str(error)) from error
    write_or_check(TARGET, render_dew(selected, digest, carrier_aliases), args.check)
    write_or_check(FINGERPRINT_TARGET, render_fingerprint_dew(prefix), args.check)
    write_or_check(FINGERPRINT_PREFIX_TARGET, prefix, args.check)
    write_or_check(
        MANIFEST,
        render_manifest(
            available,
            selected,
            digest,
            wasm,
            submodule_revision,
            interfaces,
            prefix,
        ),
        args.check,
    )


if __name__ == "__main__":
    main()
