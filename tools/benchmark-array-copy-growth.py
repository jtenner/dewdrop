#!/usr/bin/env python3
"""Benchmark scalar-loop versus WasmGC array.copy growable Array growth."""

from __future__ import annotations

import argparse
import fcntl
import json
import os
import platform
import statistics
import subprocess
from contextlib import contextmanager
from pathlib import Path
from typing import Any, Iterator

ROOT = Path(__file__).resolve().parents[1]
TMP = ROOT / ".tmp" / "array-copy-growth-benchmark"
RUNTIME = ROOT / "src" / "backend" / "starshine_array_runtime.mbt"
LOCK = ROOT / ".tmp" / "array-growth-benchmark.lock"
COPY_BLOCK = """  grow.push(starshine_array_local_get(backing_local))
  grow.push(starshine_match_cast(array_type))
  grow.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
  append_starshine_instructions(
    grow,
    starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
  )
  grow.push(starshine_match_cast(array_type))
  grow.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
  append_starshine_instructions(
    grow,
    starshine_array_wrapper_field(wrapper_type, wrapper_local, 1),
  )
  grow.push(
    @lib.Instruction::array_copy(
      @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
      @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
    ),
  )"""
LOOP_BLOCK = """  grow.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
  grow.push(starshine_array_local_set(index_local))
  let copy_loop : Array[@lib.Instruction] = [
    starshine_array_local_get(index_local),
  ]
  append_starshine_instructions(
    copy_loop,
    starshine_array_wrapper_field(wrapper_type, wrapper_local, 1),
  )
  copy_loop.push(@lib.Instruction::i32_ge_u())
  copy_loop.push(@lib.Instruction::br_if(@lib.LabelIdx::new(1U)))
  copy_loop.push(starshine_array_local_get(backing_local))
  copy_loop.push(starshine_match_cast(array_type))
  copy_loop.push(starshine_array_local_get(index_local))
  append_starshine_instructions(
    copy_loop,
    starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
  )
  copy_loop.push(starshine_match_cast(array_type))
  copy_loop.push(starshine_array_local_get(index_local))
  copy_loop.push(
    @lib.Instruction::array_get(
      @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
    ),
  )
  copy_loop.push(
    @lib.Instruction::array_set(
      @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
    ),
  )
  copy_loop.push(starshine_array_local_get(index_local))
  copy_loop.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
  copy_loop.push(@lib.Instruction::i32_add())
  copy_loop.push(starshine_array_local_set(index_local))
  copy_loop.push(@lib.Instruction::br(@lib.LabelIdx::new(0U)))
  grow.push(
    @lib.Instruction::block(
      @lib.BlockType::void_(),
      @lib.Expr::new([
        @lib.Instruction::loop_(
          @lib.BlockType::void_(),
          @lib.Expr::new(copy_loop),
        ),
      ]),
    ),
  )"""


def run(
    command: list[str],
    *,
    capture: bool = False,
    env: dict[str, str] | None = None,
) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        command,
        cwd=ROOT,
        check=True,
        text=True,
        capture_output=capture,
        env=env,
    )


@contextmanager
def backend_variant_lock() -> Iterator[None]:
    """Serialize benchmark-only backend rewrites across local benchmark tools."""
    LOCK.parent.mkdir(parents=True, exist_ok=True)
    with LOCK.open("w", encoding="utf-8") as lock:
        fcntl.flock(lock.fileno(), fcntl.LOCK_EX)
        try:
            yield
        finally:
            fcntl.flock(lock.fileno(), fcntl.LOCK_UN)


def source(carrier: str, count: int) -> str:
    if carrier == "i32":
        type_ = "I32"
        value = "7"
    else:
        type_ = "String"
        value = '"abcdefgh"'
    return f"""open dew.std.array
open dew.std.string

pub fn keep(values: Array<{type_}>) -> U32 {{
  values.capacity()
}}

fn one() -> U32 {{
  let values = Array::new()
  let mut index = 0u32
  while index {{
    current if current < {count}u32 => {{
      values.push({value})
      continue current + 1u32
    }}
    _ => break values.length() + keep(values) - values.capacity()
  }}
}}

fn repeat(remaining: U32, total: U32) -> U32 {{
  if remaining == 0u32 {{
    total
  }} else {{
    repeat(remaining - 1u32, total + one())
  }}
}}

pub fn run(iterations: U32) -> U32 {{
  repeat(iterations, 0u32)
}}
"""


def compile_variant(variant: str, workloads: list[dict[str, Any]]) -> None:
    out = TMP / variant
    out.mkdir(parents=True, exist_ok=True)
    for workload in workloads:
        wasm = out / f"{workload['name']}.wasm"
        run(
            [
                str(ROOT / "tools" / "dew"),
                "build",
                str(workload["source"]),
                "-o",
                str(wasm),
            ],
            capture=True,
            env={
                **os.environ,
                "DEW_BUILD_CACHE": "0",
                "DEW_PARSE_EVENT_CACHE": "0",
                "DEW_INTERFACE_CACHE": "0",
                "DEW_BODY_CACHE": "0",
            },
        )
        workload.setdefault("variants", {})[variant] = str(wasm)
        workload.setdefault("sizes", {})[variant] = wasm.stat().st_size


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--samples", type=int, default=101)
    parser.add_argument("--rounds", type=int, default=5)
    parser.add_argument("--target-elements", type=int, default=262144)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    if args.samples < 4 or args.rounds < 1:
        parser.error("samples >= 4 and rounds >= 1 are required")
    TMP.mkdir(parents=True, exist_ok=True)
    workloads = []
    for carrier in ("i32", "string"):
        for count in (4, 8, 16, 32, 64, 512):
            name = f"{carrier}-{count}"
            path = TMP / f"{name}.dew"
            path.write_text(source(carrier, count), encoding="utf-8")
            workloads.append(
                {
                    "name": name,
                    "carrier": carrier,
                    "count": count,
                    "source": path,
                }
            )
    with backend_variant_lock():
        original = RUNTIME.read_text(encoding="utf-8")
        if original.count(COPY_BLOCK) != 1:
            raise RuntimeError("backend does not contain expected array.copy block")
        try:
            compile_variant("copy", workloads)
            RUNTIME.write_text(
                original.replace(COPY_BLOCK, LOOP_BLOCK), encoding="utf-8"
            )
            compile_variant("loop", workloads)
        finally:
            RUNTIME.write_text(original, encoding="utf-8")
    specs = TMP / "specs.json"
    specs.write_text(json.dumps(workloads, default=str), encoding="utf-8")
    runner=r'''const fs=require('fs'),{performance}=require('perf_hooks');(async()=>{const ss=JSON.parse(fs.readFileSync(process.argv[1])),samples=+process.argv[2],rounds=+process.argv[3],target=+process.argv[4],out={};for(const s of ss){const ins={};for(const v of ['loop','copy'])ins[v]=(await WebAssembly.instantiate(fs.readFileSync(s.variants[v]),{})).instance;const b=Math.max(1,Math.min(10000,Math.floor(target/s.count))),expected=b*s.count;for(const v of ['loop','copy'])for(let w=0;w<30;w++)if(ins[v].exports.run(b)!==expected)throw Error('bad');out[s.name]={batch:b,rounds:[]};for(let r=0;r<rounds;r++){let row={loop:[],copy:[]};for(let n=0;n<samples;n++){const order=(n+r)%2?['copy','loop']:['loop','copy'];for(const v of order){let t=performance.now(),a=ins[v].exports.run(b),ns=(performance.now()-t)*1e6/b;if(a!==expected)throw Error('bad');row[v].push(ns)}}out[s.name].rounds.push(row)}}process.stdout.write(JSON.stringify(out))})().catch(e=>{console.error(e);process.exit(1)})'''
    raw = json.loads(
        run(
            [
                "node",
                "-e",
                runner,
                str(specs),
                str(args.samples),
                str(args.rounds),
                str(args.target_elements),
            ],
            capture=True,
        ).stdout
    )
    results = {}
    for workload in workloads:
        loops = []
        copies = []
        deltas = []
        for row in raw[workload["name"]]["rounds"]:
            loop = statistics.median(row["loop"])
            copy = statistics.median(row["copy"])
            loops.append(loop)
            copies.append(copy)
            deltas.append((copy / loop - 1) * 100)
        results[workload["name"]] = {
            "loop_ns_per_op": round(statistics.median(loops), 2),
            "copy_ns_per_op": round(statistics.median(copies), 2),
            "delta_percent": round(statistics.median(deltas), 2),
            "round_deltas_percent": [round(value, 2) for value in deltas],
            "wasm_bytes": workload["sizes"],
        }
    report = {
        "environment": {
            "platform": platform.platform(),
            "node": run(["node", "--version"], capture=True).stdout.strip(),
        },
        "methodology": {
            "samples_per_round": args.samples,
            "rounds": args.rounds,
            "warmups": 30,
            "target_elements": args.target_elements,
            "negative_delta_is_faster": True,
        },
        "workloads": results,
    }
    encoded = json.dumps(report, indent=2, sort_keys=True) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(encoded, encoding="utf-8")
    print(encoded, end="")


if __name__ == "__main__":
    main()
