#!/usr/bin/env python3
"""Benchmark ordered, reordered, and one-missing component scalar replacement."""

from __future__ import annotations

import argparse
import json
import statistics
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TMP = ROOT / ".tmp" / "component-scalar-replacement-benchmark"


def source(mode: str, fields: int) -> str:
    declarations = "\n".join(f"  f{index}: I32" for index in range(fields))
    initializers = "\n".join(
        f"    f{index}: {'0' if index == 0 or index % 2 == 1 else f'value + {index}'}"
        for index in range(fields)
    )
    order = list(range(fields))
    if mode == "reversed":
        order.reverse()
    elif mode == "missing":
        order = order[1:]
    elif mode in {"direct", "direct-retained"}:
        order = list(range(0, fields, 2))
    direct = mode in {"direct", "direct-retained"}
    aliases = "" if direct else "\n".join(
        f"  let value{index} = aggregate.f{index}" for index in order
    )
    total = " + ".join(
        f"aggregate.f{index}" if direct else f"value{index}"
        for index in order
    )
    retained = mode in {"retained", "direct-retained"}
    helper = "\nfn retain(value: Aggregate) -> Aggregate {\n  value\n}\n" if retained else ""
    constructor = "retain(Aggregate {" if retained else "Aggregate {"
    close = "  })" if retained else "  }"
    return f"""struct Aggregate {{
{declarations}
}}
{helper}
pub fn main(value: I32) -> I32 {{
  let aggregate = {constructor}
{initializers}
{close}
{aliases}
  {total}
}}
"""


GENERIC_DIRECT = """struct Pair<t> {
  first: t
  second: t
}

fn selected<t>(first: t, second: t, choose_first: Bool) -> t {
  let pair = Pair {
    first: first
    second: second
  }
  if choose_first {
    pair.first
  } else {
    pair.second
  }
}

pub fn main(value: I32) -> I32 {
  selected(value, value + 1, false)
}
"""

GENERIC_RETAINED = """struct Pair<t> {
  first: t
  second: t
}

fn retain<t>(value: Pair<t>) -> Pair<t> {
  value
}

fn selected<t>(first: t, second: t, choose_first: Bool) -> t {
  let pair = retain(Pair {
    first: first
    second: second
  })
  if choose_first {
    pair.first
  } else {
    pair.second
  }
}

pub fn main(value: I32) -> I32 {
  selected(value, value + 1, false)
}
"""

MIXED_DIRECT = """struct Triple {
  first: I32
  second: I32
  third: I32
}

pub fn main(value: I32) -> I32 {
  let triple = Triple {
    first: value
    second: 0
    third: value + 1
  }
  let saved = triple.third
  triple.first + saved
}
"""

MIXED_RETAINED = """struct Triple {
  first: I32
  second: I32
  third: I32
}

fn retain(value: Triple) -> Triple {
  value
}

pub fn main(value: I32) -> I32 {
  let triple = retain(Triple {
    first: value
    second: 0
    third: value + 1
  })
  let saved = triple.third
  triple.first + saved
}
"""

FRESH_REFERENCE_DIRECT = """struct Token {
  value: I32
}

struct Pair {
  first: Token
  second: Token
}

fn selected(first: I32, second: I32) -> I32 {
  let pair = Pair {
    first: Token {
      value: first
    }
    second: Token {
      value: second
    }
  }
  pair.first.value + pair.second.value
}

pub fn main(value: I32) -> I32 {
  selected(value, value + 1)
}
"""

FRESH_REFERENCE_RETAINED = """struct Token {
  value: I32
}

struct Pair {
  first: Token
  second: Token
}

fn retain(value: Pair) -> Pair {
  value
}

fn selected(first: I32, second: I32) -> I32 {
  let pair = retain(Pair {
    first: Token {
      value: first
    }
    second: Token {
      value: second
    }
  })
  pair.first.value + pair.second.value
}

pub fn main(value: I32) -> I32 {
  selected(value, value + 1)
}
"""

REFERENCE_DIRECT = """struct Token {
  value: I32
}

struct Pair {
  first: Token
  second: Token
}

fn selected(first: Token, second: Token) -> I32 {
  let pair = Pair {
    first: first
    second: second
  }
  pair.first.value + pair.second.value
}

pub fn main(value: I32) -> I32 {
  selected(Token {
    value: value
  }, Token {
    value: value + 1
  })
}
"""

REFERENCE_RETAINED = """struct Token {
  value: I32
}

struct Pair {
  first: Token
  second: Token
}

fn retain(value: Pair) -> Pair {
  value
}

fn selected(first: Token, second: Token) -> I32 {
  let pair = retain(Pair {
    first: first
    second: second
  })
  pair.first.value + pair.second.value
}

pub fn main(value: I32) -> I32 {
  selected(Token {
    value: value
  }, Token {
    value: value + 1
  })
}
"""


def build(name: str, text: str) -> Path:
    source_path = TMP / f"{name}.dew"
    wasm_path = TMP / f"{name}.wasm"
    source_path.write_text(text, encoding="utf-8")
    subprocess.run(
        [str(ROOT / "tools" / "dew"), "build", str(source_path), "-o", str(wasm_path)],
        cwd=ROOT,
        check=True,
        stdout=subprocess.DEVNULL,
    )
    return wasm_path


def measure(paths: list[Path], expected: int, samples: int, batch: int) -> dict[str, list[float]]:
    runner = r"""
const fs = require('fs');
const { performance } = require('perf_hooks');
(async () => {
  const expected = Number(process.argv[1]);
  const samples = Number(process.argv[2]);
  const batch = Number(process.argv[3]);
  const paths = process.argv.slice(4);
  const instances = [];
  const report = {};
  for (const path of paths) {
    const { instance } = await WebAssembly.instantiate(fs.readFileSync(path), {});
    for (let i = 0; i < 10000; i++) if (instance.exports.main(7) !== expected) throw new Error('bad result');
    instances.push(instance);
    report[path] = [];
  }
  for (let sample = 0; sample < samples; sample++) {
    for (let offset = 0; offset < paths.length; offset++) {
      const index = (sample + offset) % paths.length;
      const start = performance.now();
      for (let iteration = 0; iteration < batch; iteration++) {
        if (instances[index].exports.main(7) !== expected) throw new Error('bad result');
      }
      report[paths[index]].push((performance.now() - start) * 1000 / batch);
    }
  }
  process.stdout.write(JSON.stringify(report));
})().catch(error => { console.error(error); process.exit(1); });
"""
    completed = subprocess.run(
        ["node", "-e", runner, str(expected), str(samples), str(batch), *(str(path) for path in paths)],
        cwd=ROOT,
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(completed.stdout)


def wat_count(path: Path, instruction: str) -> int:
    wat = subprocess.run(
        ["wasm-tools", "print", str(path)],
        check=True,
        capture_output=True,
        text=True,
    ).stdout
    return wat.count(instruction)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--fields", type=int, default=32)
    parser.add_argument("--samples", type=int, default=10000)
    parser.add_argument("--batch", type=int, default=100)
    args = parser.parse_args()
    if args.fields < 2 or args.samples < 1 or args.batch < 1:
        parser.error("fields must be at least two; samples and batch must be positive")
    TMP.mkdir(parents=True, exist_ok=True)
    ordered = build("ordered", source("ordered", args.fields))
    reversed_ = build("reversed", source("reversed", args.fields))
    missing = build("missing", source("missing", args.fields))
    retained = build("retained", source("retained", args.fields))
    direct = build("direct", source("direct", args.fields))
    direct_retained = build(
        "direct-retained", source("direct-retained", args.fields),
    )
    generic = build("generic", GENERIC_DIRECT)
    generic_retained = build("generic-retained", GENERIC_RETAINED)
    mixed = build("mixed", MIXED_DIRECT)
    mixed_retained = build("mixed-retained", MIXED_RETAINED)
    fresh_reference = build("fresh-reference", FRESH_REFERENCE_DIRECT)
    fresh_reference_retained = build(
        "fresh-reference-retained", FRESH_REFERENCE_RETAINED,
    )
    reference = build("reference", REFERENCE_DIRECT)
    reference_retained = build("reference-retained", REFERENCE_RETAINED)
    selected = list(range(0, args.fields, 2))
    expected = sum(0 if index == 0 else 7 + index for index in selected)
    raw = measure(
        [
            ordered,
            reversed_,
            missing,
            retained,
            direct,
            direct_retained,
        ],
        expected,
        args.samples,
        args.batch,
    )
    generic_raw = measure(
        [generic, generic_retained],
        8,
        args.samples,
        args.batch,
    )
    mixed_raw = measure(
        [mixed, mixed_retained],
        15,
        args.samples,
        args.batch,
    )
    fresh_reference_raw = measure(
        [fresh_reference, fresh_reference_retained],
        15,
        args.samples,
        args.batch,
    )
    reference_raw = measure(
        [reference, reference_retained],
        15,
        args.samples,
        args.batch,
    )
    ordered_median = statistics.median(raw[str(ordered)])
    reversed_median = statistics.median(raw[str(reversed_)])
    missing_median = statistics.median(raw[str(missing)])
    retained_median = statistics.median(raw[str(retained)])
    direct_median = statistics.median(raw[str(direct)])
    direct_retained_median = statistics.median(raw[str(direct_retained)])
    generic_median = statistics.median(generic_raw[str(generic)])
    generic_retained_median = statistics.median(
        generic_raw[str(generic_retained)],
    )
    mixed_median = statistics.median(mixed_raw[str(mixed)])
    mixed_retained_median = statistics.median(mixed_raw[str(mixed_retained)])
    fresh_reference_median = statistics.median(
        fresh_reference_raw[str(fresh_reference)],
    )
    fresh_reference_retained_median = statistics.median(
        fresh_reference_raw[str(fresh_reference_retained)],
    )
    reference_median = statistics.median(reference_raw[str(reference)])
    reference_retained_median = statistics.median(
        reference_raw[str(reference_retained)],
    )
    print(json.dumps({
        "fields": args.fields,
        "samples": args.samples,
        "batch": args.batch,
        "ordered_median_us": round(ordered_median, 4),
        "reversed_median_us": round(reversed_median, 4),
        "missing_median_us": round(missing_median, 4),
        "retained_median_us": round(retained_median, 4),
        "direct_median_us": round(direct_median, 4),
        "direct_retained_median_us": round(direct_retained_median, 4),
        "generic_median_us": round(generic_median, 4),
        "generic_retained_median_us": round(generic_retained_median, 4),
        "mixed_median_us": round(mixed_median, 4),
        "mixed_retained_median_us": round(mixed_retained_median, 4),
        "fresh_reference_median_us": round(fresh_reference_median, 4),
        "fresh_reference_retained_median_us": round(
            fresh_reference_retained_median, 4,
        ),
        "reference_median_us": round(reference_median, 4),
        "reference_retained_median_us": round(reference_retained_median, 4),
        "ordered_ratio": round(ordered_median / retained_median, 4),
        "reversed_ratio": round(reversed_median / retained_median, 4),
        "missing_ratio": round(missing_median / retained_median, 4),
        "direct_ratio": round(direct_median / direct_retained_median, 4),
        "generic_ratio": round(
            generic_median / generic_retained_median, 4,
        ),
        "mixed_ratio": round(mixed_median / mixed_retained_median, 4),
        "fresh_reference_ratio": round(
            fresh_reference_median / fresh_reference_retained_median, 4,
        ),
        "reference_ratio": round(
            reference_median / reference_retained_median, 4,
        ),
        "ordered_wasm_bytes": ordered.stat().st_size,
        "reversed_wasm_bytes": reversed_.stat().st_size,
        "missing_wasm_bytes": missing.stat().st_size,
        "retained_wasm_bytes": retained.stat().st_size,
        "direct_wasm_bytes": direct.stat().st_size,
        "direct_retained_wasm_bytes": direct_retained.stat().st_size,
        "generic_wasm_bytes": generic.stat().st_size,
        "generic_retained_wasm_bytes": generic_retained.stat().st_size,
        "mixed_wasm_bytes": mixed.stat().st_size,
        "mixed_retained_wasm_bytes": mixed_retained.stat().st_size,
        "fresh_reference_wasm_bytes": fresh_reference.stat().st_size,
        "fresh_reference_retained_wasm_bytes": fresh_reference_retained.stat().st_size,
        "reference_wasm_bytes": reference.stat().st_size,
        "reference_retained_wasm_bytes": reference_retained.stat().st_size,
        "ordered_struct_new": wat_count(ordered, "struct.new"),
        "ordered_struct_get": wat_count(ordered, "struct.get"),
        "reversed_struct_new": wat_count(reversed_, "struct.new"),
        "reversed_struct_get": wat_count(reversed_, "struct.get"),
        "missing_struct_new": wat_count(missing, "struct.new"),
        "missing_struct_get": wat_count(missing, "struct.get"),
        "retained_struct_new": wat_count(retained, "struct.new"),
        "retained_struct_get": wat_count(retained, "struct.get"),
        "direct_struct_new": wat_count(direct, "struct.new"),
        "direct_struct_get": wat_count(direct, "struct.get"),
        "direct_retained_struct_new": wat_count(direct_retained, "struct.new"),
        "direct_retained_struct_get": wat_count(direct_retained, "struct.get"),
        "generic_struct_new": wat_count(generic, "struct.new"),
        "generic_struct_get": wat_count(generic, "struct.get"),
        "generic_retained_struct_new": wat_count(generic_retained, "struct.new"),
        "generic_retained_struct_get": wat_count(generic_retained, "struct.get"),
        "mixed_struct_new": wat_count(mixed, "struct.new"),
        "mixed_struct_get": wat_count(mixed, "struct.get"),
        "mixed_retained_struct_new": wat_count(mixed_retained, "struct.new"),
        "mixed_retained_struct_get": wat_count(mixed_retained, "struct.get"),
        "fresh_reference_struct_new": wat_count(fresh_reference, "struct.new"),
        "fresh_reference_struct_get": wat_count(fresh_reference, "struct.get"),
        "fresh_reference_retained_struct_new": wat_count(fresh_reference_retained, "struct.new"),
        "fresh_reference_retained_struct_get": wat_count(fresh_reference_retained, "struct.get"),
        "reference_struct_new": wat_count(reference, "struct.new"),
        "reference_struct_get": wat_count(reference, "struct.get"),
        "reference_retained_struct_new": wat_count(reference_retained, "struct.new"),
        "reference_retained_struct_get": wat_count(reference_retained, "struct.get"),
    }, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
