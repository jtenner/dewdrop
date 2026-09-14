#!/usr/bin/env python3
"""Resolve Node Wasm CPU samples with a linked compiler's function names."""
import argparse
from collections import Counter
import json
from pathlib import Path
import re


def sections(data):
    if data[:8] != b"\0asm\1\0\0\0":
        raise ValueError("expected a core Wasm V1 module")
    reader = Reader(data, 8)
    while reader.offset < len(data):
        start = reader.offset
        kind = reader.byte()
        payload = reader.take(reader.number())
        yield kind, payload, data[start:reader.offset]


class Reader:
    def __init__(self, data, offset=0):
        self.data, self.offset = data, offset

    def take(self, size):
        end = self.offset + size
        if end > len(self.data):
            raise ValueError("truncated Wasm metadata")
        result = self.data[self.offset:end]
        self.offset = end
        return result

    def byte(self):
        return self.take(1)[0]

    def number(self):
        value = 0
        for shift in range(0, 35, 7):
            byte = self.byte()
            value |= (byte & 127) << shift
            if byte < 128:
                if value > 0xFFFFFFFF:
                    raise ValueError("Wasm metadata integer exceeds U32")
                return value
        raise ValueError("invalid Wasm metadata integer")

    def string(self):
        return self.take(self.number()).decode("utf-8")


def function_names(data):
    names = {}
    for kind, payload, _ in sections(data):
        if kind != 0:
            continue
        reader = Reader(payload)
        if reader.string() != "name":
            continue
        while reader.offset < len(payload):
            kind = reader.byte()
            part = Reader(reader.take(reader.number()))
            if kind == 1:
                for _ in range(part.number()):
                    index, name = part.number(), part.string()
                    if index in names:
                        raise ValueError(f"duplicate function name index {index}")
                    names[index] = name
    return names


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("profile", type=Path)
    parser.add_argument("wasm", type=Path)
    parser.add_argument("--original-wasm", type=Path,
                        help="verify that adding names kept executable sections identical")
    args = parser.parse_args()
    data = args.wasm.read_bytes()
    if args.original_wasm:
        original = args.original_wasm.read_bytes()
        executable = lambda content: [raw for kind, _, raw in sections(content) if kind != 0]
        if executable(data) != executable(original):
            raise ValueError("profile and named Wasm executable sections differ")
    names = function_names(data)
    profile = json.loads(args.profile.read_text())
    nodes = {node["id"]: node for node in profile["nodes"]}
    samples, deltas = profile["samples"], profile["timeDeltas"]
    if len(samples) != len(deltas):
        raise ValueError("profile sample and duration counts differ")
    costs = Counter()
    for node, duration in zip(samples, deltas):
        name = nodes[node]["callFrame"]["functionName"]
        match = re.fullmatch(r"wasm-function\[(\d+)\]", name)
        if match:
            name = names.get(int(match[1]), name)
        costs[name] += duration / 1000
    print(json.dumps({"profile": str(args.profile), "wasm": str(args.wasm),
                      "executable_sections_verified": args.original_wasm is not None,
                      "total_sample_ms": sum(costs.values()),
                      "self_ms": dict(costs.most_common())}, indent=2))


if __name__ == "__main__":
    main()
