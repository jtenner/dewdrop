#!/usr/bin/env python3
"""Check late imports against the selected on-disk standard package.

Pass a built dew_cli.js file. This test does not run Moon builds.
"""

import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import time

ROOT = Path(__file__).resolve().parent.parent
CLI = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else ROOT / "_build/js/release/build/jtenner/dewdrop/dew_cli/dew_cli.js"
WORK = ROOT / ".tmp/late-transform-imports"
WORK.mkdir(parents=True, exist_ok=True)

TRANSFORM = '''import dewdrop.ast as @ast
import dewdrop.transform as @transform
transform fn generate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {
  ctx.import_module("dew.std.map", "generated_map")
  node.with_body(@ast.source("@generated_map.selected_marker"))
}
#generate
pub fn main() -> I32 {
  0i32
}
'''


def compile_source(package, source, label, expected_error=None):
    output = package / f"{label}.wasm"
    command = ["node", "--stack-size=65500", str(CLI), "build", "--std-root", str(package),
               "--no-program-cache", "--no-cache-pack", "--no-interface-cache",
               "--no-parse-event-cache", str(source), "-o", str(output)]
    start = time.monotonic()
    log_path = WORK / f"{label}.log"
    with log_path.open("wb") as log:
        process = subprocess.Popen(command, cwd=ROOT, stdout=log, stderr=subprocess.STDOUT)
        _, status, usage = os.wait4(process.pid, 0)
        process.returncode = os.waitstatus_to_exitcode(status)
    sample = {"case": label, "seconds": round(time.monotonic() - start, 3),
              "max_rss_kb": usage.ru_maxrss, "exit": process.returncode}
    with (WORK / "samples.jsonl").open("a") as samples:
        samples.write(json.dumps(sample) + "\n")
    print(json.dumps(sample), flush=True)
    text = log_path.read_text()
    if expected_error is None:
        if process.returncode != 0:
            raise AssertionError(f"{label}: compiler failed\n{text}")
    elif process.returncode == 0 or expected_error not in text or output.exists():
        raise AssertionError(f"{label}: expected {expected_error!r}, no output, and an error\n{text}")
    if sample["seconds"] > 30:
        raise AssertionError(f"{label}: compiler exceeded 30 seconds")
    return output


def assert_main(output, expected):
    subprocess.run(["node", "-e", '''const fs = require("fs");
WebAssembly.instantiate(fs.readFileSync(process.argv[1])).then(({instance}) => {
  const actual = instance.exports.main();
  const expected = Number(process.argv[2]);
  if (actual !== expected) throw Error(`expected ${expected}, got ${actual}`);
  console.log(`main() = ${actual}`);
});''', str(output), str(expected)], check=True)


with tempfile.TemporaryDirectory(prefix="package-", dir=WORK) as temporary:
    package = Path(temporary)
    shutil.copytree(ROOT / "std", package / "std")
    source = package / "main.dew"
    source.write_text("pub fn main() -> I32 {\n 42i32\n}\n")
    json_source = package / "std/json.dew"
    json_bytes = json_source.read_bytes()
    json_source.unlink()
    assert_main(compile_source(package, source, "ordinary-sparse"), 42)
    json_source.write_bytes(json_bytes)
    source.write_text(TRANSFORM)
    selected_map = package / "std/map.dew"
    selected_map.write_text("pub let selected_marker = 42i32\n")
    assert_main(compile_source(package, source, "selected-42"), 42)
    selected_map.write_text("pub let selected_marker = 43i32\n")
    assert_main(compile_source(package, source, "selected-43"), 43)
    selected_map.unlink()
    compile_source(package, source, "missing-late-source", "cannot read standard source")

print("late transform import tests passed")
