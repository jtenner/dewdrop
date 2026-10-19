#!/usr/bin/env python3
"""Check raw array defaults with an existing native or JS CLI; no build step."""

import hashlib
import json
import os
from pathlib import Path
import platform
import subprocess
import sys
import time


ROOT = Path(__file__).resolve().parent.parent
if len(sys.argv) != 2:
    raise SystemExit("usage: tools/test-raw-array-defaults.py DEW_CLI")
CLI = Path(sys.argv[1]).resolve()
WORK = ROOT / ".tmp/raw-array-default-results"
WORK.mkdir(parents=True, exist_ok=True)
command = ["node", str(CLI)] if CLI.suffix == ".js" else [str(CLI)]
environment = dict(os.environ, DEW_STD_ROOT=str(ROOT), DEW_PROGRAM_CACHE="0")
prefix = """open dew.std.wasm.intrinsics
foreign type Handle
struct Item {
 value: I32
}
trait Answer {
 fn answer(self) -> I32
}
"""
cases = [
    ("unit", "Unit", 1, False),
    ("unit-product", "(Unit, Unit)", 1, False),
    ("product", "(I32, I64)", 1, True),
    ("nested-product", "(F32, (F64, V128))", 1, True),
    ("function", "fn(I32) -> I32", 1, False),
    ("trait", "Answer", 1, False),
    ("array", "WasmArray<I32>", 1, False),
    ("record", "Item", 1, True),
    ("nullable", "NullableRef<Handle>", 1, False),
    ("unit-bounds", "Unit", 0, True),
]
identity = {
    "cli": str(CLI),
    "cli_sha256": hashlib.sha256(CLI.read_bytes()).hexdigest(),
    "platform": platform.platform(),
    "machine": platform.machine(),
}
(WORK / "identity.json").write_text(json.dumps(identity, indent=2) + "\n")
samples = []
for name, type_, count, trap in cases:
    source = WORK / f"{name}.dew"
    output = WORK / f"{name}.wasm"
    output.unlink(missing_ok=True)
    if name == "nullable":
        body = """ let value = wasm_array_get(wasm_array_new_default::<NullableRef<Handle>>(1u32), 0u32)
 if wasm_ref_is_null(value) {
  42i32
 } else {
  0i32
 }
"""
    else:
        body = f" let _ = wasm_array_get(wasm_array_new_default::<{type_}>({count}u32), 0u32)\n 42i32\n"
    source.write_text(prefix + "pub fn main() -> I32 {\n" + body + "}\n")
    args = command + ["build", "--emit", "wasm", "--root", "example.app", "--module", "example.app", str(source), "-o", str(output)]
    start = time.monotonic()
    with (WORK / f"{name}.stdout").open("wb") as stdout, (WORK / f"{name}.stderr").open("wb") as stderr:
        process = subprocess.Popen(["timeout", "25s"] + args, cwd=ROOT, env=environment, stdout=stdout, stderr=stderr)
        _, status, usage = os.wait4(process.pid, 0)
        process.returncode = os.waitstatus_to_exitcode(status)
    sample = {
        "case": name,
        "seconds": round(time.monotonic() - start, 4),
        "peak_rss_kib": usage.ru_maxrss,
        "exit": process.returncode,
    }
    samples.append(sample)
    (WORK / "samples.json").write_text(json.dumps(samples, indent=2) + "\n")
    if process.returncode:
        raise AssertionError(f"{name}: compile failed; see {WORK / (name + '.stdout')} and stderr")
    runner = subprocess.run([
        "node", "-e", """const fs=require('fs');
const instance=new WebAssembly.Instance(new WebAssembly.Module(fs.readFileSync(process.argv[1])));
let trapped=false;
try { const result=instance.exports.main(); if(result!==42) throw Error(`expected 42, got ${result}`); }
catch(error) { if(!(error instanceof WebAssembly.RuntimeError)) throw error; trapped=true; }
if(trapped!==(process.argv[2]==='trap')) throw Error(`unexpected trap state: ${trapped}`);
console.log(trapped?'trap':'42');
""", str(output), "trap" if trap else "return",
    ], capture_output=True, text=True, check=True, timeout=25)
    sample["result"] = runner.stdout.strip()
    sample["wasm_bytes"] = output.stat().st_size
    sample["wasm_sha256"] = hashlib.sha256(output.read_bytes()).hexdigest()
    print(json.dumps(sample), flush=True)
(WORK / "samples.json").write_text(json.dumps(samples, indent=2) + "\n")
print("raw array default runtime checks passed")
