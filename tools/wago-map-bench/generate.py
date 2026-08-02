#!/usr/bin/env python3
"""Generate a deterministic Map/Set growth workload without Dew loop dependencies."""

import argparse
from pathlib import Path


def keys(count: int) -> list[int]:
    value = 0x12345678
    output: list[int] = []
    for _ in range(count):
        value = (1664525 * value + 1013904223) & 0xFFFFFFFF
        output.append(value)
    return output


def render(count: int) -> str:
    values = keys(count)
    lines = [
        "open dew.std.map",
        "open dew.std.set",
        "",
        "pub fn main() -> Unit {",
        f"  let map = Map::singleton({values[0]}u32, 0)",
        f"  let set = Set::singleton({values[0]}u32)",
    ]
    for index, key in enumerate(values[1:], 1):
        lines.append(f"  map.insert({key}u32, {index})")
        lines.append(f"  set.insert({key}u32)")
    for index, key in enumerate(values):
        lines.append(
            f'  assert(map[{key}u32] == {index}, "map benchmark lookup {index}")'
        )
        lines.append(
            f'  assert(set.contains({key}u32), "set benchmark lookup {index}")'
        )
    lines.extend(["}", ""])
    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--count", type=int, default=512)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    if args.count < 2:
        raise SystemExit("--count must be at least 2")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(render(args.count), encoding="utf-8")


if __name__ == "__main__":
    main()
