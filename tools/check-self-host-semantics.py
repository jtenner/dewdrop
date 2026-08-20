#!/usr/bin/env python3
"""Run Dew semantic collection over every checked-in valid Dew source."""

from __future__ import annotations

import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parent.parent
WORK = ROOT / ".tmp" / "self-host-semantic-corpus"
BATCH_SIZE = 12

COMPILER_SOURCES = [
    "self_host/compiler/tokenizer.dew",
    "self_host/compiler/parser_ast.dew",
    "self_host/compiler/parser_derive_core.dew",
    "self_host/compiler/parser_derive_format.dew",
    "self_host/compiler/parser_core.dew",
    "self_host/compiler/parser_pattern.dew",
    "self_host/compiler/parser_expression.dew",
    "self_host/compiler/parser_control.dew",
    "self_host/compiler/parser_declaration_forms.dew",
    "self_host/compiler/parser_declarations.dew",
    "self_host/compiler/semantic_ids.dew",
    "self_host/compiler/semantic_hir.dew",
    "self_host/compiler/semantic_model.dew",
    "self_host/compiler/semantic_collection.dew",
    "self_host/compiler/semantic_body_lowering.dew",
]


def bytes_literal(data: bytes) -> str:
    output: list[str] = []
    for value in data:
        if value == 10:
            output.append(r"\n")
        elif value == 13:
            output.append(r"\r")
        elif value == 9:
            output.append(r"\t")
        elif value == 34:
            output.append(r'\"')
        elif value == 92:
            output.append(r"\\")
        elif 32 <= value < 127:
            output.append(chr(value))
        else:
            output.append(f"\\x{value:02X}")
    return 'b"' + "".join(output) + '"'


def snapshot_result_path(source: Path) -> Path:
    for parent in source.parents:
        if parent == ROOT:
            break
        for suffix in (".files", ".tests", ".modules"):
            if parent.name.endswith(suffix):
                fixture = parent.name[: -len(suffix)]
                return parent.parent / f"{fixture}.json"
    return source.with_suffix(".json")


def valid_sources() -> list[Path]:
    sources = set(ROOT.glob("std/**/*.dew"))
    sources.update(ROOT.glob("self_host/**/*.dew"))
    for source in ROOT.glob("tests/module-snapshots/**/*.dew"):
        result_path = snapshot_result_path(source)
        if result_path.exists():
            result = json.loads(result_path.read_text())
            if result.get("errors"):
                continue
        sources.add(source)
    return sorted(sources)


def is_test_file(source: Path) -> bool:
    relative = source.relative_to(ROOT)
    return source.name.endswith("_test.dew") or ".tests" in relative.parts


def render_test(batch: list[Path], start: int) -> str:
    parts = [
        "open dew.std.testing\n"
        "open dew.std.string_builder\n\n"
        "fn semantic_corpus_first_diagnostic(\n"
        "  collected: SelfHostCollectedModule,\n"
        ") -> String {\n"
        "  if collected.diagnostics.length() == 0u32 {\n"
        "    return \"\"\n"
        "  }\n"
        "  match collected.diagnostics[0u32] {\n"
        "    SelfHostCollectionDiagnostic::ParseDiagnostic(_, diagnostic) => {\n"
        "      let builder = StringBuilder::new()\n"
        "      builder.append(\"parse@\")\n"
        "      builder.append_u32(diagnostic.error.offset())\n"
        "      builder.finish()\n"
        "    }\n"
        "    SelfHostCollectionDiagnostic::DuplicateName(_) => \"duplicate-name\"\n"
        "    SelfHostCollectionDiagnostic::DuplicateTestIdentity(_) => \"duplicate-test\"\n"
        "    SelfHostCollectionDiagnostic::InvalidExpectedTestTrap(_, _, _) => \"invalid-trap\"\n"
        "    SelfHostCollectionDiagnostic::TestDeclarationOutsideTestFile(_, _) => \"test-outside-test-file\"\n"
        "    SelfHostCollectionDiagnostic::UnknownDerivedTrait(_, _, _) => \"unknown-derive\"\n"
        "    SelfHostCollectionDiagnostic::DuplicateDerivedTrait(_, _, _, _) => \"duplicate-derive\"\n"
        "    SelfHostCollectionDiagnostic::EmptyForeignLogicalName(_, _) => \"empty-foreign-library\"\n"
        "    SelfHostCollectionDiagnostic::EmptyForeignExportName(_, _) => \"empty-foreign-export\"\n"
        "  }\n"
        "}\n\n"
        "fn semantic_corpus_message(\n"
        "  path: String,\n"
        "  collected: SelfHostCollectedModule,\n"
        ") -> String {\n"
        "  let builder = StringBuilder::new()\n"
        "  builder.append(path)\n"
        "  builder.append(\": \")\n"
        "  builder.append(semantic_corpus_first_diagnostic(collected))\n"
        "  builder.finish()\n"
        "}\n"
    ]
    for index, source in enumerate(batch, start=start):
        relative = source.relative_to(ROOT).as_posix()
        test_only = "true" if is_test_file(source) else "false"
        parts.append(
            f'\ntest "self-host semantic corpus {relative}" {{\n'
            f"  let module_id = {100000 + index}u64\n"
            "  let collected = self_host_collect_files(module_id, [\n"
            "    SelfHostProgramFile::{\n"
            "      id: self_host_make_file_id(module_id, 0u32)\n"
            f'      path: "{relative}"\n'
            f"      source: {bytes_literal(source.read_bytes())}\n"
            f"      test_only: {test_only}\n"
            "    },\n"
            "  ])\n"
            "  assert(\n"
            "    collected.diagnostics.length() == 0u32,\n"
            f'    semantic_corpus_message("{relative}", collected),\n'
            "  )\n"
            "}\n"
        )
    return "".join(parts)


def main() -> int:
    sources = valid_sources()
    WORK.mkdir(parents=True, exist_ok=True)
    test_path = WORK / "semantic_corpus_test.dew"
    for start in range(0, len(sources), BATCH_SIZE):
        batch = sources[start : start + BATCH_SIZE]
        test_path.write_text(render_test(batch, start))
        command = [
            str(ROOT / "tools" / "dew"),
            "test",
            *[str(ROOT / path) for path in COMPILER_SOURCES],
            str(test_path),
        ]
        print(
            f"checking semantic corpus {start + 1}-{start + len(batch)}",
            flush=True,
        )
        result = subprocess.run(command, cwd=ROOT)
        if result.returncode != 0:
            return result.returncode
    print(f"self-host semantic corpus passed: {len(sources)} source files")
    return 0


if __name__ == "__main__":
    sys.exit(main())
