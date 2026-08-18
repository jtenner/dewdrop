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


def render_dew(bindings: list[ExportBinding], digest: str) -> str:
    supported = [binding for binding in bindings if binding.unsupported_reason is None]
    reference_indices: set[int] = set()
    for binding in supported:
        for value in (*binding.parameters, *binding.results):
            rendered, reason = dew_type(value)
            if reason is None and rendered is not None:
                match = re.search(r"StarshineRef([0-9]+)", rendered)
                if match is not None:
                    reference_indices.add(int(match.group(1)))
    lines = [
        "// Generated by tools/generate_starshine_ffi_consumer.py. Do not edit.",
        "// Raw carrier bindings for provider \"starshine\".",
        f"// Provider SHA-256: {digest}",
        f"// Bound exports: {len(supported)} of {len(bindings)}.",
        "// Nullable WasmGC references use NullableRef<StarshineRefN>.",
        "",
        "open dew.std.wasm.intrinsics",
        "",
    ]
    for index in sorted(reference_indices):
        lines.append(f"pub foreign type StarshineRef{index}")
    lines.extend(["", 'foreign impl "starshine" as StarshineFfi {'])
    for binding in supported:
        parameters = []
        for index, value in enumerate(binding.parameters):
            rendered, reason = dew_type(value)
            if rendered is None or reason is not None:
                raise AssertionError("unsupported binding entered Dew rendering")
            parameters.append(f"value{index}: {rendered}")
        if not binding.results:
            result = "Unit"
        else:
            result, reason = dew_type(binding.results[0])
            if result is None or reason is not None:
                raise AssertionError("unsupported result entered Dew rendering")
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
    bindings: list[ExportBinding], digest: str, wasm: Path
) -> str:
    supported_count = sum(binding.unsupported_reason is None for binding in bindings)
    data = {
        "version": 1,
        "provider": "starshine",
        "submodule_revision": subprocess.run(
            ["git", "-C", "starshine-mb", "rev-parse", "HEAD"],
            cwd=ROOT,
            check=True,
            stdout=subprocess.PIPE,
            text=True,
        ).stdout.strip(),
        "wasm_path": wasm.relative_to(ROOT).as_posix(),
        "wasm_sha256": digest,
        "export_count": len(bindings),
        "binding_count": supported_count,
        "unsupported_count": len(bindings) - supported_count,
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
            for binding in bindings
        ],
    }
    return json.dumps(data, indent=2, ensure_ascii=False) + "\n"


def write_or_check(path: Path, content: str, check: bool) -> None:
    if check:
        if not path.exists() or path.read_text(encoding="utf-8") != content:
            raise SystemExit(
                f"{path.relative_to(ROOT)} is stale; run "
                "tools/generate_starshine_ffi_consumer.py"
            )
        print(f"checked {path.relative_to(ROOT)}")
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")
    print(f"generated {path.relative_to(ROOT)}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--wasm", type=Path, default=DEFAULT_WASM)
    args = parser.parse_args()
    wasm = args.wasm.resolve()
    bindings, digest = inspect_exports(wasm)
    write_or_check(TARGET, render_dew(bindings, digest), args.check)
    write_or_check(MANIFEST, render_manifest(bindings, digest, wasm), args.check)


if __name__ == "__main__":
    main()
