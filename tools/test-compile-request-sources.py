#!/usr/bin/env python3
"""Run exact standard-source request cases with built native binaries; no Moon."""
import hashlib
import json
import os
from pathlib import Path
import platform
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parent.parent
if len(sys.argv) != 3:
    raise SystemExit("usage: tools/test-compile-request-sources.py DEW_CLI FIXTURE")
CLI, FIXTURE = [Path(value).resolve() for value in sys.argv[1:]]
WORK = ROOT / ".tmp/compile-request-sources"
WORK.mkdir(parents=True, exist_ok=True)


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


identity = {"cli": str(CLI), "cli_sha256": digest(CLI), "fixture": str(FIXTURE),
            "fixture_sha256": digest(FIXTURE), "machine": platform.machine(),
            "platform": platform.platform()}
(WORK / "identity.json").write_text(json.dumps(identity, indent=2) + "\n")
samples = []
for case in ["basic", "pooled-custom-path", "pooled-extra-file",
             "pooled-standard-transform", "explicit-standard"]:
    request = WORK / f"{case}.bin"
    output = WORK / f"{case}.wasm"
    output.unlink(missing_ok=True)
    subprocess.run([str(FIXTURE), str(request), str(output), case], cwd=ROOT,
                   check=True, timeout=25)
    environment = dict(os.environ)
    cache = WORK / f"forbidden-cache-{case}"
    environment.update(DEW_CACHE_DIR=str(cache), DEW_PARSE_EVENT_CACHE="1",
                       DEW_INTERFACE_CACHE="1", DEW_BODY_CACHE="1")
    launcher = ["node", str(CLI)] if CLI.suffix == ".js" else [str(CLI)]
    command = ["timeout", "25s", *launcher, "--compile-request", str(request)]
    start = time.monotonic()
    with (WORK / f"{case}.stdout").open("wb") as stdout, (WORK / f"{case}.stderr").open("wb") as stderr:
        process = subprocess.Popen(command, cwd=ROOT, env=environment,
                                   stdout=stdout, stderr=stderr)
        _, status, usage = os.wait4(process.pid, 0)
        process.returncode = os.waitstatus_to_exitcode(status)
    sample = {"case": case, "command": command, "seconds": round(time.monotonic() - start, 4),
              "peak_rss_kib": usage.ru_maxrss, "exit": process.returncode,
              "request_sha256": digest(request)}
    samples.append(sample)
    (WORK / "samples.json").write_text(json.dumps(samples, indent=2) + "\n")
    print(json.dumps(sample), flush=True)
    if process.returncode:
        raise AssertionError(f"{case}: CLI failed; see {WORK / (case + '.stdout')} and stderr")
    if cache.exists():
        raise AssertionError(f"{case}: uncached request created a cache")
    sample["wasm_sha256"] = digest(output)
    sample["wasm_bytes"] = output.stat().st_size
    subprocess.run(["node", "-e", '''const fs=require("fs");
WebAssembly.instantiate(fs.readFileSync(process.argv[1])).then(({instance})=>{
  const actual=instance.exports.main();
  if(actual!==42) throw Error(`expected 42, got ${actual}`);
});''', str(output)], check=True, timeout=25)
(WORK / "samples.json").write_text(json.dumps(samples, indent=2) + "\n")
print("native compile-request source tests passed")
