#!/usr/bin/env python3
"""Compile and run the Dew parser against every checked-in valid Dew source."""

from __future__ import annotations

import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parent.parent
WORK = ROOT / ".tmp" / "self-host-parser-corpus"
BATCH_SIZE = 25

PARSER_SOURCES = [
    "self_host/compiler/tokenizer.dew",
    "self_host/compiler/parser_ast.dew",
    "self_host/compiler/parser_core.dew",
    "self_host/compiler/parser_pattern.dew",
    "self_host/compiler/parser_expression.dew",
    "self_host/compiler/parser_control.dew",
    "self_host/compiler/parser_declaration_forms.dew",
    "self_host/compiler/parser_declarations.dew",
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


def bytes_expression(data: bytes) -> str:
    chunk_size = 8192
    if len(data) <= chunk_size:
        return bytes_literal(data)
    chunks = [
        bytes_literal(data[start : start + chunk_size])
        for start in range(0, len(data), chunk_size)
    ]
    return "parser_corpus_source([" + ", ".join(chunks) + "])"


def valid_sources() -> list[Path]:
    sources = set(ROOT.glob("std/**/*.dew"))
    sources.update(ROOT.glob("self_host/**/*.dew"))
    for source in ROOT.glob("tests/module-snapshots/**/*.dew"):
        result_path = source.with_suffix(".json")
        if result_path.exists():
            result = json.loads(result_path.read_text())
            if result.get("errors"):
                continue
        sources.add(source)
    return sorted(sources)


def render_test(batch: list[Path]) -> str:
    parts = [
        "open dew.std.string_builder\n"
        "open dew.std.testing\n\n"
        "fn parser_corpus_source(parts: Array<Bytes>) -> Bytes {\n"
        "  let mut output = b\"\"\n"
        "  for part in parts {\n"
        "    output = output.concat(part)\n"
        "  }\n"
        "  output\n"
        "}\n\n"
        "fn parser_corpus_error(\n"
        "  module_: SelfHostParsedModule,\n"
        "  name: String,\n"
        ") -> String {\n"
        "  for event in module_.events {\n"
        "    match event {\n"
        "      SelfHostParseEvent::Diagnostic(diagnostic) => {\n"
        "        let builder = StringBuilder::new()\n"
        "        builder.append(name)\n"
        "        builder.append(\":\")\n"
        "        builder.append_u32(diagnostic.error.offset())\n"
        "        return builder.finish()\n"
        "      }\n"
        "      _ => {}\n"
        "    }\n"
        "  }\n"
        "  \"\"\n"
        "}\n"
    ]
    for source in batch:
        relative = source.relative_to(ROOT).as_posix()
        parts.append(
            f'\ntest "self-host parser corpus {relative}" {{\n'
            "  let error = parser_corpus_error(\n"
            f"    self_host_parse_module({bytes_expression(source.read_bytes())}),\n"
            f'    "{relative}",\n'
            "  )\n"
            "  assert(error.byte_length() == 0u32, error)\n"
            "}\n"
        )
    return "".join(parts)


def main() -> int:
    sources = valid_sources()
    WORK.mkdir(parents=True, exist_ok=True)
    test_path = WORK / "corpus_test.dew"
    for start in range(0, len(sources), BATCH_SIZE):
        batch = sources[start : start + BATCH_SIZE]
        test_path.write_text(render_test(batch))
        command = [
            str(ROOT / "tools" / "dew"),
            "test",
            *[str(ROOT / path) for path in PARSER_SOURCES],
            str(test_path),
        ]
        print(
            f"checking parser corpus {start + 1}-{start + len(batch)}",
            flush=True,
        )
        result = subprocess.run(command, cwd=ROOT)
        if result.returncode != 0:
            return result.returncode
    print(f"self-host parser corpus passed: {len(sources)} source files")
    return 0


if __name__ == "__main__":
    sys.exit(main())
