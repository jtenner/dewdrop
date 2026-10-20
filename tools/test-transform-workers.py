#!/usr/bin/env python3
"""Check the local Wago worker plugin with the real compiler interpreter."""
from pathlib import Path
import hashlib
import json
import os
import platform
import subprocess
import sys
import tempfile
import time

root = Path(__file__).resolve().parent.parent
if len(sys.argv) != 3:
    raise SystemExit("usage: tools/test-transform-workers.py COMPILER.wasm HOST")
compiler, host = (Path(value).resolve() for value in sys.argv[1:])
parent = root / ".tmp/transform-workers"
parent.mkdir(parents=True, exist_ok=True)
work = Path(tempfile.mkdtemp(prefix="run-", dir=parent))
relative = work.relative_to(root)
fixture = root / "_build/native/release/build/jtenner/dewdrop/self_host_bootstrap_fixture/self_host_bootstrap_fixture.exe"
adapted = work / "compiler.wasm"
subprocess.run([sys.executable, "tools/prepare-wago-compiler.py", str(compiler), str(adapted)], cwd=root, check=True)
heap = os.environ.get("DEW_TRANSFORM_GC_HEAP", "512MiB")
nursery = os.environ.get("DEW_TRANSFORM_GC_NURSERY", "64MiB")
identity = {"compiler": str(compiler), "compiler_sha256": hashlib.sha256(compiler.read_bytes()).hexdigest(),
            "adapted_sha256": hashlib.sha256(adapted.read_bytes()).hexdigest(), "compiler_bytes": compiler.stat().st_size,
            "host": str(host), "host_sha256": hashlib.sha256(host.read_bytes()).hexdigest(), "platform": platform.platform(),
            "harness_sha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
            "gc_heap": heap, "gc_nursery": nursery}
(work / "identity.json").write_text(json.dumps(identity, indent=2) + "\n")
samples = []
for label, workers in (("serial", "0"), ("parallel", "2")):
    request, output, cache = (relative / (label + suffix) for suffix in (".bin", ".wasm", ".cache"))
    subprocess.run([str(fixture), str(request), "starshine-mb/dist/ffi/starshine-ffi.wasm",
                    "self_host/starshine/fingerprint-prefix.bin", str(output), "example.app", "examples/transforms/parallel.dew",
                    "--standard-root", str(root), "--transform-cache", "-", str(cache), "--cache-report"], cwd=root, check=True)
    command = [str(host), "run", "-p8", "--core", "3", "--local", "--locked", "--no-input",
               "--gc-heap", heap, "--gc-nursery", nursery, str(adapted), str(request)]
    env = dict(os.environ, WAGO_HOME=str(work / (label + "-home")), DEW_TRANSFORM_WORKERS=workers,
               DEW_COMPILER_FINGERPRINT=identity["compiler_sha256"])
    start = time.monotonic()
    with (work / (label + ".log")).open("wb") as log:
        child = subprocess.Popen(command, cwd=root, env=env, stdout=log, stderr=subprocess.STDOUT)
        _, status, usage = os.wait4(child.pid, 0)
        child.returncode = os.waitstatus_to_exitcode(status)
    sample = {"label": label, "command": command, "seconds": time.monotonic() - start,
              "rss_kib": usage.ru_maxrss, "exit": child.returncode, "workers": workers,
              "request_sha256": hashlib.sha256((root / request).read_bytes()).hexdigest()}
    samples.append(sample)
    (work / "samples.json").write_text(json.dumps(samples, indent=2) + "\n")
    print(json.dumps(sample), flush=True)
    if child.returncode:
        raise SystemExit((work / (label + ".log")).read_text())
    log = (work / (label + ".log")).read_text()
    if "transform result cache: miss" not in log:
        raise AssertionError((label, "cache must be a cold miss", log))
    used_workers = "transform workers: 2 applications, 2 workers" in log
    if used_workers != (workers == "2"):
        raise AssertionError((label, "worker execution differs from requested mode", log))
    subprocess.run(["wasm-tools", "validate", "--features", "all", str(output)], cwd=root, check=True)
    subprocess.run(["node", "-e", 'WebAssembly.instantiate(require("fs").readFileSync(process.argv[1])).then(({instance})=>{instance.exports.__dew_init?.();const value=instance.exports.main();if(value!==42)throw Error(`expected 42, got ${value}`);console.log(`main() = ${value}`)})', str(output)], cwd=root, check=True)
for suffix in (".wasm", ".cache"):
    serial, parallel = ((work / (label + suffix)).read_bytes() for label in ("serial", "parallel"))
    if serial != parallel:
        raise AssertionError("serial and worker bytes differ: " + suffix)
    print(suffix + " equal: " + hashlib.sha256(serial).hexdigest(), flush=True)
print("Worker checks passed: " + str(work), flush=True)
