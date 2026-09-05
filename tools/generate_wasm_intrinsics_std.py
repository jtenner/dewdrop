#!/usr/bin/env python3
"""Generate the compiler-known WebAssembly intrinsic module and bootstrap source."""

from __future__ import annotations

import argparse
import re
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "std/wasm/intrinsics.dew"
TARGET = ROOT / "src/standard_sources/standard_wasm_intrinsics_sources.mbt"

BACKEND_SOURCES = [
    ROOT / "src/backend/starshine_code.mbt",
    *sorted((ROOT / "src/backend").glob("starshine_*builtins.mbt")),
]

BUILTIN_PATTERN = re.compile(
    r"^(?:pub\s+)?builtin\s+"
    r"(?P<name>[A-Za-z_][A-Za-z0-9_]*)"
    r"(?P<rest><[^\n=]*>)?"
    r"(?P<signature>\([^\n=]*\)\s*->\s*[^\n=]+?)"
    r'\s*=\s*"(?P<target>[^"]+)"\s*$',
    re.MULTILINE,
)
BACKEND_NAME_PATTERN = re.compile(r'name\s*==\s*b"([^"]+)"')
WRAPPER_PATTERN = re.compile(
    r"^(?:pub\s+)?fn\s+(?P<name>\w+)(?P<signature>\([^\n]*\)\s*->\s*[^\n{]+?)"
    r"\s*\{\n  (?P<body>[^\n]+)\n\}", re.MULTILINE,
)


@dataclass(frozen=True)
class IntrinsicDeclaration:
    source: str
    name: str
    alias: str
    generics: str
    signature: str
    target: str
    body: str | None = None

    def render(self) -> str:
        if self.body is not None:
            return f"pub fn {self.alias}{self.signature} {{\n  {self.body}\n}}"
        return (
            f"pub builtin {self.alias}{self.generics}{self.signature} "
            f'= "{self.target}"'
        )


EXTRA_DECLARATIONS = [
    IntrinsicDeclaration(
        source="WasmGC array operations",
        name="array_new",
        alias="wasm_array_new",
        generics="<t>",
        signature="(length: U32, value: t) -> WasmArray<t>",
        target="array_new",
    ),
    IntrinsicDeclaration(
        source="WasmGC array operations",
        name="array_len",
        alias="wasm_array_len",
        generics="<t>",
        signature="(value: WasmArray<t>) -> U32",
        target="array_len",
    ),
    IntrinsicDeclaration(
        source="WasmGC array operations",
        name="array_get",
        alias="wasm_array_get",
        generics="<t>",
        signature="(value: WasmArray<t>, index: U32) -> t",
        target="array_get",
    ),
    IntrinsicDeclaration(
        source="WasmGC array operations",
        name="array_set",
        alias="wasm_array_set",
        generics="<t>",
        signature="(value: WasmArray<t>, index: U32, item: t) -> Unit",
        target="array_set",
    ),
    IntrinsicDeclaration(
        source="WasmGC nullable foreign references",
        name="ref_null",
        alias="wasm_ref_null",
        generics="<t>",
        signature="() -> NullableRef<t>",
        target="ref_null",
    ),
    IntrinsicDeclaration(
        source="WasmGC nullable foreign references",
        name="ref_is_null",
        alias="wasm_ref_is_null",
        generics="<t>",
        signature="(value: NullableRef<t>) -> Bool",
        target="ref_is_null",
    ),
    IntrinsicDeclaration(
        source="WasmGC nullable foreign references",
        name="ref_as_non_null",
        alias="wasm_ref_as_non_null",
        generics="<t>",
        signature="(value: NullableRef<t>) -> t",
        target="ref_as_non_null",
    ),
    IntrinsicDeclaration(
        source="backend-only Core operations",
        name="i32_lt",
        alias="wasm_core_i32_lt",
        generics="",
        signature="(left: I32, right: I32) -> Bool",
        target="i32.lt_s",
    ),
    IntrinsicDeclaration(
        source="backend-only Core operations",
        name="u32_ctz",
        alias="wasm_u32_ctz",
        generics="",
        signature="(value: U32) -> U32",
        target="dew_u32_ctz",
    ),
    IntrinsicDeclaration(
        source="WasmGC text representation bridges",
        name="bytes_load_u8x16",
        alias="wasm_bytes_load_u8x16",
        generics="",
        signature="(value: Bytes, start: U32) -> U8x16",
        target="dew_bytes_load_u8x16",
    ),
    IntrinsicDeclaration(
        source="WasmGC text representation bridges",
        name="string_load_u8x16",
        alias="wasm_string_load_u8x16",
        generics="",
        signature="(value: String, start: U32) -> U8x16",
        target="dew_string_load_u8x16",
    ),
]


def backend_inline_names() -> set[str]:
    names: set[str] = set()
    for path in BACKEND_SOURCES:
        names.update(BACKEND_NAME_PATTERN.findall(path.read_text(encoding="utf-8")))
    return names


def standard_builtin_declarations() -> list[IntrinsicDeclaration]:
    declarations: list[IntrinsicDeclaration] = []
    for path in sorted((ROOT / "std").rglob("*.dew")):
        if path == SOURCE or "tests" in path.parts:
            continue
        text = path.read_text(encoding="utf-8")
        relative = path.relative_to(ROOT).as_posix()
        for match in BUILTIN_PATTERN.finditer(text):
            declarations.append(
                IntrinsicDeclaration(
                    source=relative,
                    name=match.group("name"),
                    alias=f"wasm_{match.group('name')}",
                    generics=match.group("rest") or "",
                    signature=match.group("signature"),
                    target=match.group("target"),
                )
            )
        for match in WRAPPER_PATTERN.finditer(text):
            # Keep existing packed API spellings as Dew code, never turn them
            # back into compiler-owned aliases. These bodies use only preamble
            # carrier operations, so there is no hidden module dependency.
            if "unsafe_bitcast" in match.group("body") and path.parent.name != "preamble":
                declarations.append(IntrinsicDeclaration(
                    source=relative,
                    name=match.group("name"),
                    alias=f"wasm_{match.group('name')}",
                    generics="",
                    signature=match.group("signature"),
                    target="",
                    body=match.group("body"),
                ))
    return declarations


def intrinsic_declarations() -> tuple[list[IntrinsicDeclaration], set[str]]:
    backend_names = backend_inline_names()
    declarations = list(EXTRA_DECLARATIONS)
    declarations.extend(
        declaration
        for declaration in standard_builtin_declarations()
        if declaration.body is not None or declaration.target in backend_names
    )
    aliases: set[str] = set()
    duplicate_aliases: list[str] = []
    for declaration in declarations:
        if declaration.alias in aliases:
            duplicate_aliases.append(declaration.alias)
        aliases.add(declaration.alias)
    if duplicate_aliases:
        names = ", ".join(sorted(set(duplicate_aliases)))
        raise SystemExit(f"duplicate generated WebAssembly intrinsic aliases: {names}")
    declared_names = {declaration.target for declaration in declarations}
    # These diagnostic-only helpers traverse the old Array representation.
    # They are not Wasm instructions and must not become public intrinsics.
    diagnostic_helpers = {"dew_array_backing_length_i32", "dew_array_backing_length_ref"}
    missing = sorted(backend_names - declared_names - diagnostic_helpers)
    if missing:
        raise SystemExit(
            "backend inline builtins without Dew source declarations: "
            + ", ".join(missing)
        )
    return declarations, backend_names


def rendered_intrinsics() -> tuple[str, int, int]:
    declarations, backend_names = intrinsic_declarations()
    lines = [
        "// Generated by tools/generate_wasm_intrinsics_std.py.",
        "// Names use a wasm_ prefix so open dew.std.* remains unambiguous.",
        "// Each declaration preserves the exact Dew carrier signature of its source builtin.",
        "",
        "pub struct WasmArray<t> {}",
        "pub struct NullableRef<t> {}",
        "",
        '// Compatibility spelling for the first published intrinsic.',
        'pub builtin i64_trunc_i32(value: I64) -> I32 = "i32.wrap_i64"',
        "",
    ]
    previous_source = ""
    for declaration in declarations:
        if declaration.source != previous_source:
            if previous_source:
                lines.append("")
            lines.append(f"// {declaration.source}")
            previous_source = declaration.source
        lines.append(declaration.render())
    return "\n".join(lines).rstrip() + "\n", len(declarations), len(backend_names)


def moonbit_bytes_literal(data: bytes) -> str:
    pieces: list[str] = []
    for byte in data:
        if byte == 0x0A:
            pieces.append("\\n")
        elif byte == 0x0D:
            pieces.append("\\r")
        elif byte == 0x09:
            pieces.append("\\t")
        elif byte == 0x22:
            pieces.append('\\"')
        elif byte == 0x5C:
            pieces.append("\\\\")
        elif 0x20 <= byte <= 0x7E:
            pieces.append(chr(byte))
        else:
            pieces.append(f"\\x{byte:02X}")
    return 'b"' + "".join(pieces) + '"'


def rendered_bootstrap(source: str) -> str:
    return (
        "///|\n"
        "pub fn standard_wasm_intrinsics_source() -> Bytes {\n"
        f"  {moonbit_bytes_literal(source.encode('utf-8'))}\n"
        "}\n"
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--check", action="store_true", help="fail if generated sources are stale",
    )
    args = parser.parse_args()
    source, declaration_count, backend_count = rendered_intrinsics()
    bootstrap = rendered_bootstrap(source)
    if args.check:
        stale: list[str] = []
        if not SOURCE.exists() or SOURCE.read_text(encoding="utf-8") != source:
            stale.append(SOURCE.relative_to(ROOT).as_posix())
        if not TARGET.exists() or TARGET.read_text(encoding="utf-8") != bootstrap:
            stale.append(TARGET.relative_to(ROOT).as_posix())
        if stale:
            raise SystemExit(
                ", ".join(stale)
                + " stale; run tools/generate_wasm_intrinsics_std.py"
            )
        print(
            f"checked {declaration_count} declarations covering "
            f"{backend_count} backend inline builtins"
        )
        return
    SOURCE.parent.mkdir(parents=True, exist_ok=True)
    SOURCE.write_text(source, encoding="utf-8")
    TARGET.write_text(bootstrap, encoding="utf-8")
    print(
        f"generated {declaration_count} declarations covering "
        f"{backend_count} backend inline builtins"
    )


if __name__ == "__main__":
    main()
