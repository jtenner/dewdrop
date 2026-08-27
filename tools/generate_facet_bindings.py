#!/usr/bin/env python3
"""Generate the complete Facet 0.1 Dew bindings and static-link adapter."""

from __future__ import annotations

import argparse
import re
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CANONICAL = ROOT / "tools/facet-imports.wat"
ADAPTER = ROOT / "tools/facet-adapter.wat"
SMOKE = ROOT / "fixtures/facet/facet-import-smoke.dew"
FACET_SPEC_REVISION = "c3d06ad1b3e7f8ad6b83ecb4e96e999c922b5140"

NAMESPACES = [
    ("root", "std/facet.dew", "dew.std.facet"),
    ("imports", "std/facet/imports.dew", "dew.std.facet.imports"),
    ("core", "std/facet/core.dew", "dew.std.facet.core"),
    ("fs", "std/facet/fs.dew", "dew.std.facet.fs"),
    ("process", "std/facet/process.dew", "dew.std.facet.process"),
    ("clock", "std/facet/clock.dew", "dew.std.facet.clock"),
    ("random", "std/facet/random.dew", "dew.std.facet.random"),
    ("poll", "std/facet/poll.dew", "dew.std.facet.poll"),
    ("net", "std/facet/net.dew", "dew.std.facet.net"),
]

PUBLIC_NAMESPACES = NAMESPACES[2:]

SCALAR_RESULT_TYPES = {
    ("i32", "i32"): "FacetI32Result",
    ("i64", "i32"): "FacetI64Result",
    ("i64", "i32", "i32"): "FacetSystemTimeResult",
    ("i32", "i32", "i64", "i64", "i32", "i64", "i32", "i64", "i32", "i32"): "FacetStatResult",
    ("i64", "i32", "i64", "i32", "i32"): "FacetDirectoryEntryResult",
    ("i32", "i32", "i64", "i64", "i32", "i32", "i32"): "FacetSocketAcceptResult",
    ("i32", "i64", "i64", "i32", "i32", "i32"): "FacetSocketAddressResult",
    ("i64", "i32", "i64", "i64", "i32", "i32", "i32", "i32"): "FacetSocketReceiveResult",
    ("i32", "i32", "i32", "i64", "i32", "i32"): "FacetPollEventResult",
}

RESULT_FIELDS = {
    "FacetI32Result": [("value", "U32"), ("error", "FacetErrno")],
    "FacetI64Result": [("value", "U64"), ("error", "FacetErrno")],
    "FacetSystemTimeResult": [
        ("seconds", "I64"),
        ("nanoseconds", "U32"),
        ("error", "FacetErrno"),
    ],
    "FacetStatResult": [
        ("file_type", "U32"),
        ("flags", "U32"),
        ("size", "U64"),
        ("access_time_seconds", "I64"),
        ("access_time_nanoseconds", "U32"),
        ("modification_time_seconds", "I64"),
        ("modification_time_nanoseconds", "U32"),
        ("change_time_seconds", "I64"),
        ("change_time_nanoseconds", "U32"),
        ("error", "FacetErrno"),
    ],
    "FacetDirectoryEntryResult": [
        ("units", "U64"),
        ("file_type", "U32"),
        ("inode", "U64"),
        ("done", "U32"),
        ("error", "FacetErrno"),
    ],
    "FacetSocketAcceptResult": [
        ("fd", "FacetFd"),
        ("family", "U32"),
        ("address_high", "U64"),
        ("address_low", "U64"),
        ("port", "U32"),
        ("scope_id", "U32"),
        ("error", "FacetErrno"),
    ],
    "FacetSocketAddressResult": [
        ("family", "U32"),
        ("address_high", "U64"),
        ("address_low", "U64"),
        ("port", "U32"),
        ("scope_id", "U32"),
        ("error", "FacetErrno"),
    ],
    "FacetDnsResult": [
        ("family", "U32"),
        ("address_high", "U64"),
        ("address_low", "U64"),
        ("scope_id", "U32"),
        ("done", "U32"),
        ("error", "FacetErrno"),
    ],
    "FacetSocketReceiveResult": [
        ("bytes_read", "U64"),
        ("family", "U32"),
        ("address_high", "U64"),
        ("address_low", "U64"),
        ("port", "U32"),
        ("scope_id", "U32"),
        ("message_flags", "U32"),
        ("error", "FacetErrno"),
    ],
    "FacetPollEventResult": [
        ("source_kind", "U32"),
        ("source_id", "U32"),
        ("events", "U32"),
        ("userdata", "U64"),
        ("done", "U32"),
        ("error", "FacetErrno"),
    ],
}

RAW_RESULT_TYPES = {
    kind: "FacetRaw" + kind.removeprefix("Facet")
    for kind in RESULT_FIELDS
}

RESULT_HELPER_PREFIXES = {
    "FacetI32Result": "i32_result",
    "FacetI64Result": "i64_result",
    "FacetSystemTimeResult": "system_time_result",
    "FacetStatResult": "stat_result",
    "FacetDirectoryEntryResult": "directory_entry_result",
    "FacetSocketAcceptResult": "socket_accept_result",
    "FacetSocketAddressResult": "socket_address_result",
    "FacetDnsResult": "dns_result",
    "FacetSocketReceiveResult": "socket_receive_result",
    "FacetPollEventResult": "poll_event_result",
}

ARRAY_DEW_TYPES = {
    "i8": "FixedArray<U8>",
    "i16": "FixedArray<U16>",
    "i32": "FixedArray<U32>",
    "i64": "FixedArray<U64>",
    "v128": "FixedArray<V128>",
}

ARRAY_WAT_TYPES = {
    "i8": "$array_i8",
    "i16": "$array_i16",
    "i32": "$array_i32",
    "i64": "$array_i64",
    "v128": "$array_v128",
}


@dataclass(frozen=True)
class Import:
    name: str
    params: tuple[str, ...]
    results: tuple[str, ...]


def balanced_forms(source: str, prefix: str) -> list[str]:
    forms: list[str] = []
    index = 0
    while True:
        start = source.find(prefix, index)
        if start < 0:
            return forms
        depth = 0
        quoted = False
        escaped = False
        for cursor in range(start, len(source)):
            char = source[cursor]
            if quoted:
                if escaped:
                    escaped = False
                elif char == "\\":
                    escaped = True
                elif char == '"':
                    quoted = False
                continue
            if char == '"':
                quoted = True
            elif char == "(":
                depth += 1
            elif char == ")":
                depth -= 1
                if depth == 0:
                    forms.append(source[start : cursor + 1])
                    index = cursor + 1
                    break
        else:
            raise ValueError(f"unterminated form beginning at byte {start}")


def group_types(body: str, keyword: str) -> tuple[str, ...]:
    marker = f"({keyword}"
    groups = balanced_forms(body, marker)
    output: list[str] = []
    for group in groups:
        inner = group[len(marker) : -1].strip()
        output.extend(re.findall(r"\(ref(?:\s+null)?\s+[^)]+\)|i32|i64|v128", inner))
    return tuple(" ".join(item.split()) for item in output)


def canonical_imports() -> list[Import]:
    source = CANONICAL.read_text(encoding="utf-8")
    imports: list[Import] = []
    for form in balanced_forms(source, '(import "facet"'):
        match = re.match(r'\(import\s+"facet"\s+"([^"]+)"\s+\(func(?:\s+\$[^\s()]+)?(.*)\)\s*\)$', form, re.S)
        if match is None:
            raise ValueError(f"unsupported import form: {form}")
        name, body = match.groups()
        imports.append(Import(name, group_types(body, "param"), group_types(body, "result")))
    if len(imports) != 261:
        raise ValueError(f"canonical Facet import count is {len(imports)}, want 261")
    if len({item.name for item in imports}) != len(imports):
        raise ValueError("canonical Facet imports contain a duplicate name")
    return imports


def namespace_for(name: str) -> str:
    if name in {"abi_version", "handle_close"}:
        return "core"
    if name in {"proc_exit", "proc_yield"} or name.startswith(("stdio_", "args_", "env_")):
        return "process"
    if name.startswith("clock_") or name.startswith("sleep_"):
        return "clock"
    if name.startswith("random_"):
        return "random"
    if name.startswith(("fs_preopen_", "fd_", "path_", "dir_iter_")):
        return "fs"
    if name.startswith(("socket_", "dns_")):
        return "net"
    if name.startswith("poll_"):
        return "poll"
    raise ValueError(f"no Dew namespace for Facet import {name}")


def array_suffix(name: str) -> str | None:
    match = re.search(r"_(i8|i16|i32|i64|v128)$", name)
    return match.group(1) if match else None


def allocating_result_suffix(result: str) -> str | None:
    match = re.fullmatch(r"\(ref null \$facet_string_(i8|i16|i32)\)", result)
    return match.group(1) if match else None


def is_directory_alloc(item: Import) -> bool:
    return item.name.startswith("dir_iter_next_array_")


def raw_result_kind(item: Import) -> str:
    if item.name == "dns_next":
        return "FacetDnsResult"
    if item.results and allocating_result_suffix(item.results[0]):
        suffix = allocating_result_suffix(item.results[0])
        assert suffix is not None
        return ("dir_array_" if is_directory_alloc(item) else "array_") + suffix
    if len(item.results) <= 1:
        return "direct"
    if item.results not in SCALAR_RESULT_TYPES:
        raise ValueError(f"unsupported Facet result tuple for {item.name}: {item.results}")
    return SCALAR_RESULT_TYPES[item.results]


def wat_type(token: str) -> str:
    if token in {"i32", "i64", "v128"}:
        return token
    if token == "(ref array)":
        return token
    suffix = allocating_result_suffix(token)
    if suffix:
        return f"(ref null {ARRAY_WAT_TYPES[suffix]})"
    raise ValueError(f"unsupported WAT type {token}")


def concrete_param_wat(item: Import, token: str) -> str:
    if token != "(ref array)":
        return wat_type(token)
    if item.name.startswith(("fd_readv_array_", "fd_writev_array_")):
        return "(ref $array_refs)"
    suffix = array_suffix(item.name)
    if suffix is None:
        raise ValueError(f"cannot infer array storage for {item.name}")
    return f"(ref {ARRAY_WAT_TYPES[suffix]})"


def result_type_name(kind: str) -> str:
    if kind in RESULT_FIELDS:
        return "$result_" + re.sub(r"(?<!^)(?=[A-Z])", "_", kind).lower()
    if kind.startswith("array_"):
        return "$result_" + kind
    if kind.startswith("dir_array_"):
        return "$result_" + kind
    raise ValueError(kind)


def render_wat(imports: list[Import]) -> str:
    lines = [
        ";; Generated by tools/generate_facet_bindings.py. Do not edit.",
        f";; Facet specification revision: {FACET_SPEC_REVISION}",
        "(module",
        "  (type $array_i8 (array (mut i8)))",
        "  (type $array_i16 (array (mut i16)))",
        "  (type $array_i32 (array (mut i32)))",
        "  (type $array_i64 (array (mut i64)))",
        "  (type $array_v128 (array (mut v128)))",
        "  (type $array_refs (array (mut eqref)))",
    ]
    used_kinds = {raw_result_kind(item) for item in imports}
    for kind, fields in RESULT_FIELDS.items():
        if kind in used_kinds:
            wat_fields = " ".join("(field " + ("i64" if dew in {"U64", "I64"} else "i32") + ")" for _, dew in fields)
            lines.append(f"  (type {result_type_name(kind)} (struct {wat_fields}))")
    for suffix in ("i8", "i16", "i32"):
        lines.append(
            f"  (type $result_array_{suffix} (struct (field (ref null {ARRAY_WAT_TYPES[suffix]})) (field i32)))"
        )
        lines.append(
            f"  (type $result_dir_array_{suffix} (struct (field (ref null {ARRAY_WAT_TYPES[suffix]})) (field i32) (field i64) (field i32) (field i32)))"
        )
    lines.append("")

    for item in imports:
        params = "" if not item.params else " (param " + " ".join(wat_type(token) for token in item.params) + ")"
        results = "" if not item.results else " (result " + " ".join(wat_type(token) for token in item.results) + ")"
        lines.append(f'  (import "facet" "{item.name}" (func $raw_{item.name}{params}{results}))')
    lines.append("")

    for item in imports:
        kind = raw_result_kind(item)
        params = [concrete_param_wat(item, token) for token in item.params]
        signature = "" if not params else " (param " + " ".join(params) + ")"
        if kind == "direct":
            results = "" if not item.results else " (result " + " ".join(wat_type(token) for token in item.results) + ")"
            lines.append(f'  (func (export "{item.name}"){signature}{results}')
            for index in range(len(params)):
                lines.append(f"    local.get {index}")
            lines.append(f"    call $raw_{item.name})")
            continue
        result_name = result_type_name(kind)
        lines.append(f'  (func (export "{item.name}"){signature} (result (ref {result_name}))')
        local_types = " ".join(wat_type(token) for token in item.results)
        lines.append(f"    (local {local_types})")
        for index in range(len(params)):
            lines.append(f"    local.get {index}")
        lines.append(f"    call $raw_{item.name}")
        base = len(params)
        for index in reversed(range(len(item.results))):
            lines.append(f"    local.set {base + index}")
        for index in range(len(item.results)):
            lines.append(f"    local.get {base + index}")
        lines.append(f"    struct.new {result_name})")
    lines.append("")

    for kind, fields in RESULT_FIELDS.items():
        if kind not in used_kinds:
            continue
        result_name = result_type_name(kind)
        helper_prefix = RESULT_HELPER_PREFIXES[kind]
        for index, (field, dew_type) in enumerate(fields):
            wasm_type = "i64" if dew_type in {"U64", "I64"} else "i32"
            lines.extend([
                f'  (func (export "{helper_prefix}_{field}") (param (ref {result_name})) (result {wasm_type})',
                "    local.get 0",
                f"    struct.get {result_name} {index})",
            ])
    for suffix in ("i8", "i16", "i32"):
        array_type = ARRAY_WAT_TYPES[suffix]
        lines.extend([
            f'  (func (export "array_{suffix}_result_value") (param (ref $result_array_{suffix})) (result (ref {array_type}))',
            "    local.get 0",
            f"    struct.get $result_array_{suffix} 0",
            "    ref.as_non_null)",
            f'  (func (export "array_{suffix}_result_error") (param (ref $result_array_{suffix})) (result i32)',
            "    local.get 0",
            f"    struct.get $result_array_{suffix} 1)",
        ])
        dir_fields = [("value", 0, f"(ref {array_type})"), ("file_type", 1, "i32"), ("inode", 2, "i64"), ("done", 3, "i32"), ("error", 4, "i32")]
        for field, index, output_type in dir_fields:
            lines.append(f'  (func (export "dir_array_{suffix}_result_{field}") (param (ref $result_dir_array_{suffix})) (result {output_type})')
            lines.append("    local.get 0")
            lines.append(f"    struct.get $result_dir_array_{suffix} {index}")
            if field == "value":
                lines.append("    ref.as_non_null")
            lines[-1] += ")"
    lines.append(")")
    return "\n".join(lines) + "\n"


def dew_scalar_type(item: Import, index: int, token: str) -> str:
    if token == "i32":
        return "U32"
    if token == "i64":
        if item.name == "fd_seek" and index == 1:
            return "I64"
        return "U64"
    if token == "v128":
        return "V128"
    if token == "(ref array)":
        if item.name.startswith(("fd_readv_array_", "fd_writev_array_")):
            suffix = array_suffix(item.name)
            assert suffix is not None
            return f"FixedArray<{ARRAY_DEW_TYPES[suffix]}>"
        suffix = array_suffix(item.name)
        if suffix is None:
            raise ValueError(f"cannot infer Dew array storage for {item.name}")
        return ARRAY_DEW_TYPES[suffix]
    raise ValueError(f"unsupported Dew parameter type {token}")


def parameter_names(item: Import) -> list[str]:
    name = item.name
    count = len(item.params)
    exact = {
        "handle_close": ["handle"],
        "proc_exit": ["status"],
        "sleep_for": ["nanoseconds"],
        "sleep_until": ["deadline_nanoseconds"],
        "fs_preopen_get": ["index"],
        "fd_rights": ["fd"],
        "fd_get_flags": ["fd"],
        "fd_set_flags": ["fd", "flags"],
        "fd_stat": ["fd"],
        "fd_seek": ["fd", "offset", "whence"],
        "fd_tell": ["fd"],
        "fd_set_size": ["fd", "size"],
        "fd_sync": ["fd"],
        "fd_datasync": ["fd"],
        "dir_iter_open": ["directory"],
        "dir_iter_rewind": ["iterator"],
        "socket_open": ["family", "socket_type", "protocol", "flags"],
        "socket_bind": ["fd", "family", "address_high", "address_low", "port", "scope_id"],
        "socket_connect": ["fd", "family", "address_high", "address_low", "port", "scope_id"],
        "socket_listen": ["fd", "backlog"],
        "socket_accept": ["fd", "flags"],
        "socket_local_address": ["fd"],
        "socket_peer_address": ["fd"],
        "socket_shutdown": ["fd", "how"],
        "dns_next": ["iterator"],
        "poll_add_fd": ["poll", "fd", "events", "userdata"],
        "poll_update_fd": ["poll", "fd", "events", "userdata"],
        "poll_remove_fd": ["poll", "fd"],
        "poll_add_timer": ["poll", "deadline_nanoseconds", "userdata"],
        "poll_remove_timer": ["poll", "timer"],
        "poll_wait": ["poll", "deadline_nanoseconds"],
        "poll_next": ["poll"],
    }
    if name in exact:
        return exact[name]
    if name.startswith("args_len_"):
        return ["index", "wtf"]
    if name.startswith("args_read_mem32_"):
        return ["index", "wtf", "memory", "pointer", "capacity"]
    if name.startswith("args_read_mem64_"):
        return ["index", "wtf", "memory", "pointer", "capacity"]
    if name.startswith("args_read_into_array_"):
        return ["index", "wtf", "destination", "offset", "capacity"]
    if name.startswith("args_read_array_"):
        return ["index", "wtf"]
    if name.startswith("env_len_"):
        return ["index", "field", "wtf"]
    if name.startswith("env_read_mem32_") or name.startswith("env_read_mem64_"):
        return ["index", "field", "wtf", "memory", "pointer", "capacity"]
    if name.startswith("env_read_into_array_"):
        return ["index", "field", "wtf", "destination", "offset", "capacity"]
    if name.startswith("env_read_array_"):
        return ["index", "field", "wtf"]
    if name.startswith("random_fill_mem"):
        return ["memory", "pointer", "length"]
    if name.startswith("random_fill_array_"):
        return ["destination", "byte_offset", "byte_length"]
    if name.startswith("fs_preopen_name_len_"):
        return ["index", "wtf"]
    if name.startswith("fs_preopen_name_read_mem"):
        return ["index", "wtf", "memory", "pointer", "capacity"]
    if name.startswith("fs_preopen_name_read_into_array_"):
        return ["index", "wtf", "destination", "offset", "capacity"]
    if name.startswith("fs_preopen_name_read_array_"):
        return ["index", "wtf"]
    if name.startswith("fd_read_mem") or name.startswith("fd_write_mem"):
        return ["fd", "memory", "pointer", "length"]
    if name.startswith("fd_read_array_"):
        return ["fd", "destination", "byte_offset", "byte_length"]
    if name.startswith("fd_write_array_"):
        return ["fd", "source", "byte_offset", "byte_length"]
    if name.startswith("fd_pread_mem") or name.startswith("fd_pwrite_mem"):
        return ["fd", "file_offset", "memory", "pointer", "length"]
    if name.startswith("fd_pread_array_"):
        return ["fd", "file_offset", "destination", "byte_offset", "byte_length"]
    if name.startswith("fd_pwrite_array_"):
        return ["fd", "file_offset", "source", "byte_offset", "byte_length"]
    if name.startswith(("fd_readv_mem", "fd_writev_mem")):
        return ["fd", "iovec_memory", "iovec_pointer", "iovec_count"]
    if name.startswith("fd_readv_array_"):
        return ["fd", "buffers", "first", "count"]
    if name.startswith("fd_writev_array_"):
        return ["fd", "buffers", "first", "count"]
    if name.startswith("path_open_mem"):
        return ["directory", "memory", "pointer", "length", "wtf", "flags", "rights"]
    if name.startswith("path_open_array_"):
        return ["directory", "path", "offset", "length", "wtf", "flags", "rights"]
    if name.startswith("path_stat_mem"):
        return ["directory", "memory", "pointer", "length", "wtf", "flags"]
    if name.startswith("path_stat_array_"):
        return ["directory", "path", "offset", "length", "wtf", "flags"]
    if name.startswith("path_create_dir_mem"):
        return ["directory", "memory", "pointer", "length", "wtf"]
    if name.startswith("path_create_dir_array_"):
        return ["directory", "path", "offset", "length", "wtf"]
    if name.startswith("path_remove_mem"):
        return ["directory", "memory", "pointer", "length", "wtf", "flags"]
    if name.startswith("path_remove_array_"):
        return ["directory", "path", "offset", "length", "wtf", "flags"]
    if name.startswith(("path_rename_mem", "path_link_mem")):
        return ["source_directory", "source_memory", "source_pointer", "source_length", "source_wtf", "destination_directory", "destination_memory", "destination_pointer", "destination_length", "destination_wtf", "flags"]
    if name.startswith(("path_rename_array_", "path_link_array_")):
        return ["source_directory", "source", "source_offset", "source_length", "source_wtf", "destination_directory", "destination", "destination_offset", "destination_length", "destination_wtf", "flags"]
    if name.startswith("dir_iter_next_len_"):
        return ["iterator", "wtf"]
    if name.startswith("dir_iter_next_mem"):
        return ["iterator", "wtf", "memory", "pointer", "capacity"]
    if name.startswith("dir_iter_next_into_array_"):
        return ["iterator", "wtf", "destination", "offset", "capacity"]
    if name.startswith("dir_iter_next_array_"):
        return ["iterator", "wtf"]
    if name.startswith("path_symlink_mem"):
        return ["target_memory", "target_pointer", "target_length", "target_wtf", "destination_directory", "destination_memory", "destination_pointer", "destination_length", "destination_wtf"]
    if name.startswith("path_symlink_array_"):
        return ["target", "target_offset", "target_length", "target_wtf", "destination_directory", "destination", "destination_offset", "destination_length", "destination_wtf"]
    if name.startswith("path_readlink_len_mem"):
        return ["directory", "path_memory", "path_pointer", "path_length", "path_wtf", "target_wtf"]
    if name.startswith("path_readlink_mem"):
        return ["directory", "path_memory", "path_pointer", "path_length", "path_wtf", "target_memory", "target_pointer", "target_capacity", "target_wtf"]
    if name.startswith("path_readlink_len_array_"):
        return ["directory", "path", "offset", "length", "path_wtf", "target_wtf"]
    if name.startswith("path_readlink_into_array_"):
        return ["directory", "path", "path_offset", "path_length", "path_wtf", "destination", "destination_offset", "target_capacity", "target_wtf"]
    if name.startswith("path_readlink_array_"):
        return ["directory", "path", "offset", "length", "path_wtf", "target_wtf"]
    if name.startswith("socket_recvfrom_mem"):
        return ["fd", "memory", "pointer", "length", "flags"]
    if name.startswith("socket_recvfrom_array_"):
        return ["fd", "destination", "byte_offset", "byte_length", "flags"]
    if name.startswith("socket_sendto_mem"):
        return ["fd", "memory", "pointer", "length", "family", "address_high", "address_low", "port", "scope_id", "flags"]
    if name.startswith("socket_sendto_array_"):
        return ["fd", "source", "byte_offset", "byte_length", "family", "address_high", "address_low", "port", "scope_id", "flags"]
    if name.startswith("dns_resolve_mem"):
        return ["memory", "pointer", "length", "wtf", "family", "flags"]
    if name.startswith("dns_resolve_array_"):
        return ["name", "offset", "length", "wtf", "family", "flags"]
    if count == 0:
        return []
    return [f"value{index}" for index in range(count)]


def public_result_type(namespace: str, kind: str) -> str:
    prefix = "FacetLowLevel" + "".join(part.title() for part in namespace.split("_"))
    return prefix + kind.removeprefix("Facet")


def dew_return_type(item: Import) -> str:
    kind = raw_result_kind(item)
    if kind == "direct":
        if not item.results:
            return "Unit"
        token = item.results[0]
        return "U64" if token == "i64" else "U32"
    if kind in RESULT_FIELDS:
        return public_result_type(namespace_for(item.name), kind)
    suffix = kind.rsplit("_", 1)[1]
    if kind.startswith("dir_array_"):
        entry = {"i8": "FacetDirectoryEntryI8", "i16": "FacetDirectoryEntryI16", "i32": "FacetDirectoryEntryI32"}[suffix]
        return f"Result<Option<{entry}>, FacetErrno>"
    return f"Result<{ARRAY_DEW_TYPES[suffix]}, FacetErrno>"


def host_return_type(item: Import) -> str:
    kind = raw_result_kind(item)
    if kind == "direct":
        return dew_return_type(item)
    if kind in RESULT_FIELDS:
        return RAW_RESULT_TYPES[kind]
    suffix = kind.rsplit("_", 1)[1]
    prefix = "FacetDirectoryArray" if kind.startswith("dir_array_") else "FacetArray"
    return prefix + suffix.upper() + "Result"


def render_root(_items: list[Import]) -> str:
    return "\n".join([
        "// Generated by tools/generate_facet_bindings.py. Do not edit.",
        "",
        "pub type FacetErrno = U32",
        "pub type FacetHandle = U32",
        "pub type FacetFd = U32",
        "pub type FacetDirectory = U32",
        "pub type FacetPoll = U32",
        "",
    ])


def render_module_body(namespace: str, imports: list[Import], include_header: bool = True) -> list[str]:
    items = [item for item in imports if namespace_for(item.name) == namespace]
    lines: list[str] = []
    if include_header:
        lines.append("// Generated by tools/generate_facet_bindings.py. Do not edit.")
        lines.append("")
        lines.append("import dew.std.facet.imports as @raw")
        lines.append("open dew.std.facet")
        if any("(ref array)" in item.params or allocating_result_suffix(item.results[0]) if item.results else False for item in items):
            lines.append("open dew.std.fixed_array")
        lines.append("")
    used_result_kinds = {
        raw_result_kind(item)
        for item in items
        if raw_result_kind(item) in RESULT_FIELDS
    }
    for kind, fields in RESULT_FIELDS.items():
        if kind in used_result_kinds:
            lines.append(f"pub struct {public_result_type(namespace, kind)} {{")
            for field, dew_type in fields:
                lines.append(f"  {field}: {dew_type}")
            lines.extend(["}", ""])
    directory_suffixes = {
        raw_result_kind(item).rsplit("_", 1)[1]
        for item in items
        if raw_result_kind(item).startswith("dir_array_")
    }
    for suffix in ("i8", "i16", "i32"):
        if suffix in directory_suffixes:
            lines.extend([
                f"pub struct FacetDirectoryEntry{suffix.upper()} {{",
                f"  name: {ARRAY_DEW_TYPES[suffix]}",
                "  file_type: U32",
                "  inode: U64",
                "}",
                "",
            ])
    for item in items:
        names = parameter_names(item)
        params = ",\n".join(f"  {name}: {dew_scalar_type(item, index, token)}" for index, (name, token) in enumerate(zip(names, item.params)))
        if params:
            signature = f"pub fn {item.name}(\n{params},\n) -> {dew_return_type(item)} {{"
        else:
            signature = f"pub fn {item.name}() -> {dew_return_type(item)} {{"
        lines.append(signature)
        args = ", ".join(names)
        call = f"@raw.{item.name}({args})"
        kind = raw_result_kind(item)
        if kind == "direct":
            lines.append(f"  {call}")
        elif kind in RESULT_FIELDS:
            prefix = RESULT_HELPER_PREFIXES[kind]
            lines.append(f"  let result = {call}")
            lines.append(f"  {public_result_type(namespace, kind)}::{{")
            for field, _dew_type in RESULT_FIELDS[kind]:
                lines.append(f"    {field}: @raw.{prefix}_{field}(result)")
            lines.append("  }")
        elif kind.startswith("array_"):
            suffix = kind.rsplit("_", 1)[1]
            lines.append(f"  let result = {call}")
            lines.append(f"  let error = @raw.array_{suffix}_result_error(result)")
            lines.append("  if error == 0u32 {")
            lines.append(f"    Result::Ok(@raw.array_{suffix}_result_value(result))")
            lines.append("  } else {")
            lines.append("    Result::Err(error)")
            lines.append("  }")
        else:
            suffix = kind.rsplit("_", 1)[1]
            entry_type = {"i8": "FacetDirectoryEntryI8", "i16": "FacetDirectoryEntryI16", "i32": "FacetDirectoryEntryI32"}[suffix]
            lines.append(f"  let result = {call}")
            lines.append(f"  let error = @raw.dir_array_{suffix}_result_error(result)")
            lines.append("  if error != 0u32 {")
            lines.append("    Result::Err(error)")
            lines.append(f"  }} else if @raw.dir_array_{suffix}_result_done(result) != 0u32 {{")
            lines.append("    Result::Ok(Option::None)")
            lines.append("  } else {")
            lines.append(f"    Result::Ok(Option::Some({entry_type}::{{")
            lines.append(f"      name: @raw.dir_array_{suffix}_result_value(result)")
            lines.append(f"      file_type: @raw.dir_array_{suffix}_result_file_type(result)")
            lines.append(f"      inode: @raw.dir_array_{suffix}_result_inode(result)")
            lines.append("    }))")
            lines.append("  }")
        lines.extend(["}", ""])
    return lines


def render_imports(imports: list[Import]) -> str:
    lines = [
        "// Generated by tools/generate_facet_bindings.py. Do not edit.",
        "",
        "open dew.std.facet",
        "open dew.std.fixed_array",
        "",
    ]
    for raw_type in RAW_RESULT_TYPES.values():
        lines.append(f"pub foreign type {raw_type}")
    for suffix in ("I8", "I16", "I32"):
        lines.append(f"pub foreign type FacetArray{suffix}Result")
        lines.append(f"pub foreign type FacetDirectoryArray{suffix}Result")
    lines.extend(["", 'foreign impl "facet" as FacetImports {'])
    helpers: set[str] = set()
    for item in imports:
        names = parameter_names(item)
        if len(names) != len(item.params):
            raise ValueError(f"parameter-name count mismatch for {item.name}")
        params = ", ".join(
            f"{name}: {dew_scalar_type(item, index, token)}"
            for index, (name, token) in enumerate(zip(names, item.params))
        )
        lines.append(
            f'  pub fn {item.name}({params}) -> {host_return_type(item)} = "{item.name}"'
        )
        kind = raw_result_kind(item)
        if kind in RESULT_FIELDS:
            prefix = RESULT_HELPER_PREFIXES[kind]
            helpers.update(f"{prefix}_{field}" for field, _ in RESULT_FIELDS[kind])
        elif kind.startswith("array_"):
            suffix = kind.rsplit("_", 1)[1]
            helpers.update(
                {f"array_{suffix}_result_value", f"array_{suffix}_result_error"}
            )
        elif kind.startswith("dir_array_"):
            suffix = kind.rsplit("_", 1)[1]
            helpers.update(
                f"dir_array_{suffix}_result_{field}"
                for field in ("value", "file_type", "inode", "done", "error")
            )
    for helper in sorted(helpers):
        scalar_match = next(
            (
                (kind, field, dew_type)
                for kind, fields in RESULT_FIELDS.items()
                for field, dew_type in fields
                if helper == f"{RESULT_HELPER_PREFIXES[kind]}_{field}"
            ),
            None,
        )
        if scalar_match is not None:
            kind, _field, output = scalar_match
            lines.append(
                f'  pub fn {helper}(value: {RAW_RESULT_TYPES[kind]}) -> {output} = "{helper}"'
            )
            continue
        match = re.fullmatch(r"array_(i8|i16|i32)_result_(value|error)", helper)
        if match:
            suffix, field = match.groups()
            input_type = "FacetArray" + suffix.upper() + "Result"
            output = ARRAY_DEW_TYPES[suffix] if field == "value" else "FacetErrno"
            lines.append(
                f'  pub fn {helper}(value: {input_type}) -> {output} = "{helper}"'
            )
            continue
        match = re.fullmatch(
            r"dir_array_(i8|i16|i32)_result_(value|file_type|inode|done|error)",
            helper,
        )
        assert match is not None
        suffix, field = match.groups()
        input_type = "FacetDirectoryArray" + suffix.upper() + "Result"
        output = (
            ARRAY_DEW_TYPES[suffix]
            if field == "value"
            else ("U64" if field == "inode" else "U32")
        )
        lines.append(
            f'  pub fn {helper}(value: {input_type}) -> {output} = "{helper}"'
        )
    lines.extend(["}", ""])
    return "\n".join(lines)


def render_dew_modules(imports: list[Import]) -> dict[Path, str]:
    output: dict[Path, str] = {
        ROOT / "std/facet.dew": render_root(imports),
        ROOT / "std/facet/imports.dew": render_imports(imports),
    }
    for namespace, relative, _module in PUBLIC_NAMESPACES:
        output[ROOT / relative] = (
            "\n".join(render_module_body(namespace, imports)).rstrip() + "\n"
        )
    return output


def smoke_argument(item: Import, index: int, token: str) -> str:
    if token == "i32":
        return "0u32"
    if token == "i64":
        return "0i64" if item.name == "fd_seek" and index == 1 else "0u64"
    if token == "v128":
        return "zero_v128"
    if token == "(ref array)":
        suffix = array_suffix(item.name)
        assert suffix is not None
        if item.name.startswith(("fd_readv_array_", "fd_writev_array_")):
            return f"refs_{suffix}"
        return f"array_{suffix}"
    raise ValueError(token)


def render_smoke(imports: list[Import]) -> str:
    aliases = {namespace: "@" + namespace for namespace, _, _ in PUBLIC_NAMESPACES}
    lines = ["// Generated by tools/generate_facet_bindings.py. Do not edit."]
    for namespace, _relative, module in PUBLIC_NAMESPACES:
        lines.append(f"import {module} as {aliases[namespace]}")
    lines.extend([
        "open dew.std.fixed_array",
        "open dew.std.wasm.intrinsics",
        "",
        "pub fn run() -> U32 {",
        "  let version = @core.abi_version()",
        "  if version == 4294967295u32 {",
        "    let array_i8 = FixedArray::make(1u32, 0u8)",
        "    let array_i16 = FixedArray::make(1u32, 0u16)",
        "    let array_i32 = FixedArray::make(1u32, 0u32)",
        "    let array_i64 = FixedArray::make(1u32, 0u64)",
        "    let zero_v128 = wasm_v128_splat_i32(0)",
        "    let array_v128 = FixedArray::make(1u32, zero_v128)",
        "    let refs_i8 = FixedArray::make(1u32, array_i8)",
        "    let refs_i16 = FixedArray::make(1u32, array_i16)",
        "    let refs_i32 = FixedArray::make(1u32, array_i32)",
        "    let refs_i64 = FixedArray::make(1u32, array_i64)",
        "    let refs_v128 = FixedArray::make(1u32, array_v128)",
    ])
    for call_index, item in enumerate(imports):
        if item.name == "abi_version":
            continue
        alias = aliases[namespace_for(item.name)]
        args = ", ".join(smoke_argument(item, index, token) for index, token in enumerate(item.params))
        expression = f"{alias}.{item.name}({args})"
        if item.name == "proc_exit":
            lines.append(f"    {expression}")
        else:
            lines.append(f"    let _facet_call_{call_index} = {expression}")
    lines.extend(["  } else {", "  }", "  version", "}", ""])
    return "\n".join(lines)


def outputs() -> dict[Path, str]:
    imports = canonical_imports()
    rendered = render_dew_modules(imports)
    rendered[ADAPTER] = render_wat(imports)
    rendered[SMOKE] = render_smoke(imports)
    return rendered


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    rendered = outputs()
    stale: list[str] = []
    for path, content in rendered.items():
        if args.check:
            if not path.exists() or path.read_text(encoding="utf-8") != content:
                stale.append(str(path.relative_to(ROOT)))
        else:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(content, encoding="utf-8")
            print(f"generated {path.relative_to(ROOT)}")
    if stale:
        raise SystemExit("stale generated Facet bindings: " + ", ".join(stale))
    if args.check:
        print(f"checked {len(rendered)} generated Facet binding files")


if __name__ == "__main__":
    main()
