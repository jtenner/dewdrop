#!/usr/bin/env python3
"""Write the same-process baseline/current Moon benchmark to the given path.

Run from the repository root:
  python3 docs/research/data/parse-cache-depth-admission-2026-10-18/reproduce_benchmark.py src/parser/parse_event_depth_bench_test.mbt
  moon bench --target native --no-parallelize src/parser/parse_event_depth_bench_test.mbt
Remove the temporary parser file after the run.
"""
from pathlib import Path
import re
import subprocess
import sys

baseline = "9d86b829292b1efa8f1aca32b0ff49565c878ee0"
source = subprocess.check_output(
    ["git", "show", baseline + ":src/parser/parse_event_artifact.mbt"], text=True
)
functions = list(re.finditer(r"^fn (parse_(?:read|write)_\w+)\(", source, re.M))
writers = []
for index, match in enumerate(functions):
    if match[1].startswith("parse_write_"):
        end = functions[index + 1].start() if index + 1 < len(functions) else len(source)
        writers.append(source[match.start():end])
writers = re.sub(r"\bparse_write_", "depth_baseline_parse_write_", "\n".join(writers))
benchmarks = r'''
test "bench parse-event depth admission current" (it : @bench.T) {
  let events = parse_event_binary_benchmark_events()
  it.bench(fn() { it.keep(serialize_parse_events(events).unwrap().length()) })
}

///|
test "bench parse-event depth admission baseline" (it : @bench.T) {
  let events = parse_event_binary_benchmark_events()
  it.bench(fn() {
    let writer = @cache_binary.Writer::new(size_hint=events.length() * 24 + 8)
    writer.write_u32_le(1U)
    writer.write_var_u64(events.length().to_uint64())
    for event in events { depth_baseline_parse_write_event(writer, event) }
    it.keep(writer.to_bytes().length())
  })
}
'''
Path(sys.argv[1]).write_text(writers + "\n///|\n" + benchmarks)
