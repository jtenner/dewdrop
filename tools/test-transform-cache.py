#!/usr/bin/env python3
"""Fresh-process transform cache checks. Called by test-transform-cache.sh."""
from pathlib import Path
import hashlib
import json
import os
import platform
import subprocess
import struct
import sys
import tempfile
import time

root = Path.cwd()
mode, compiler = sys.argv[1:3]
work = Path(tempfile.mkdtemp(prefix="run-", dir=root / ".tmp/transform-cache"))
relative_work = work.relative_to(root)
fixture = root / "_build/native/release/build/jtenner/dewdrop/self_host_bootstrap_fixture/self_host_bootstrap_fixture.exe"
compiler_path = Path(compiler).resolve()
env = dict(os.environ, DEW_COMPILER_FINGERPRINT=hashlib.sha256(compiler_path.read_bytes()).hexdigest())
(work / "identity.json").write_text(json.dumps({"compiler": str(compiler_path), "sha256": env["DEW_COMPILER_FINGERPRINT"], "mode": mode, "platform": platform.platform()}, indent=2) + "\n")
unused = relative_work / "unused.dew"
unused.write_bytes(b"\xff unused source pool")
samples = []
outputs = []


def request(label, prior, cache_output=None, module_output=None):
    req = relative_work / (label + ".bin")
    out = module_output or relative_work / (label + ".wasm")
    command = [str(fixture), str(req), "starshine-mb/dist/ffi/starshine-ffi.wasm", "self_host/starshine/fingerprint-prefix.bin", str(out), "example.app", "examples/transforms/local.dew", "--pool-module", "cache.unused", str(unused), "--standard-root", str(root), "--cache-report"]
    if prior is not None:
        command.extend(["--transform-cache", str(prior), str(cache_output or relative_work / (label + ".cache"))])
    subprocess.run(command, check=True)
    return req, out


def run(label, prior, expected, *, success=True, cache_output=None, module_output=None):
    req, out = request(label, prior, cache_output, module_output)
    command = ([str(compiler_path), "--compile-request", str(req)] if mode == "native" else ["node", "--stack-size=65500", "tools/run-dew-facet.mjs", str(compiler_path), str(req)])
    start = time.monotonic()
    with (work / (label + ".log")).open("wb") as log:
        child = subprocess.Popen(command, env=env, stdout=log, stderr=subprocess.STDOUT)
        _, status, usage = os.wait4(child.pid, 0)
        child.returncode = os.waitstatus_to_exitcode(status)
    sample = {"label": label, "command": command, "seconds": time.monotonic() - start, "rss_kib": usage.ru_maxrss, "exit": child.returncode}
    samples.append(sample)
    (work / "samples.json").write_text(json.dumps(samples, indent=2) + "\n")
    print(json.dumps(sample), flush=True)
    log = (work / (label + ".log")).read_text()
    assert (child.returncode == 0) == success, (label, log)
    if expected:
        assert "transform result cache: " + expected in log, (label, log)
    if not success:
        assert not out.exists(), (label, "failed compile wrote output")
        return log
    data = out.read_bytes()
    outputs.append(hashlib.sha256(data).hexdigest())
    subprocess.run(["wasm-tools", "validate", "--features", "all", str(out)], check=True)
    subprocess.run(["node", "-e", 'WebAssembly.instantiate(require("fs").readFileSync(process.argv[1])).then(({instance})=>{instance.exports.__dew_init?.();const value=instance.exports.main();if(value!==42)throw Error(`expected42 got${value}`)})', str(out)], check=True)


class Reader:
    """Read trusted version-1 test records, with useful bounds failures."""
    def __init__(self, data):
        self.data, self.offset = data, 0

    def take(self, count):
        assert 0 <= count <= len(self.data) - self.offset, (self.offset, count)
        result = self.data[self.offset:self.offset + count]
        self.offset += count
        return result

    def u32(self):
        return struct.unpack("<I", self.take(4))[0]

    def blob(self):
        return self.take(self.u32())


def payload_hash(payload):
    # The existing request tool writes BLAKE3(prefix + provider). An empty
    # provider gives BLAKE3(payload), with no extra crypto tool or host API.
    prefix = relative_work / "hash.payload"
    empty = relative_work / "empty-provider.wasm"
    encoded = relative_work / "hash-request.bin"
    prefix.write_bytes(payload)
    empty.write_bytes(b"")
    subprocess.run([str(fixture), str(encoded), str(empty), str(prefix),
                    "hash-output.wasm", "example.app", "examples/transforms/local.dew"], check=True)
    reader = Reader(encoded.read_bytes())
    assert reader.take(20) == struct.pack("<IIIII", 0x44574352, 1, 1, 0, 1)
    reader.blob()  # Output path.
    reader.blob()  # Root module.
    for _ in range(reader.u32()):
        reader.blob()
        for _ in range(reader.u32()):
            reader.blob()
            reader.blob()
    for _ in range(reader.u32()):
        reader.blob()
        reader.blob()
    for _ in range(reader.u32()):
        reader.blob()
        reader.blob()
    assert reader.u32() == 0
    reader.blob()  # Standard identity.
    reader.take(24)  # Six session flags.
    digest = reader.blob()
    assert len(digest) == 32
    return digest


def invalid_generated_source(artifact):
    reader = Reader(artifact[76:])
    payload = bytearray()
    def u32(value):
        payload.extend(struct.pack("<I", value))
    def blob(value):
        u32(len(value))
        payload.extend(value)
    count = reader.u32()
    u32(count)
    changed = 0
    for _ in range(count):
        module = reader.blob()
        blob(module)
        count = reader.u32()
        u32(count)
        for _ in range(count):
            blob(reader.blob())
            source = reader.blob()
            if module == b"example.app" and b"pub fn main()" in source:
                assert b"42i32" in source, source
                source = source.replace(b"42i32", b"true", 1)
                changed += 1
            blob(source)
            u32(reader.u32())
    assert changed == 1, changed
    payload.extend(reader.take(len(reader.data) - reader.offset))
    return artifact[:40] + payload_hash(payload) + struct.pack("<I", len(payload)) + payload


run("cold", "-", "miss")
prior = relative_work / "cold.cache"
assert prior.stat().st_size > 76
for i in range(3):
    run(f"hit-{i}", prior, "hit")
    assert (relative_work / f"hit-{i}.cache").read_bytes() == prior.read_bytes()
for i in range(3):
    run(f"disabled-{i}", None, "disabled" if mode == "native" else None)
damaged = bytearray(prior.read_bytes())
damaged[40] ^= 1
bad = relative_work / "damaged.cache"
bad.write_bytes(damaged)
run("corrupt", bad, "miss")
unused.write_bytes(unused.read_bytes() + b" changed")
run("dependency-change", prior, "miss")
unused.write_bytes(b"\xff unused source pool")
sentinel = relative_work / "keep.cache"
sentinel.write_bytes(b"keep the last artifact")
run("output-error", prior, None, success=False, cache_output=sentinel, module_output=relative_work / "missing/output.wasm")
assert sentinel.read_bytes() == b"keep the last artifact"
forged = relative_work / "invalid-source.cache"
forged.write_bytes(invalid_generated_source(prior.read_bytes()))
bad_log = run("cached-source-error", forged, None, success=False, cache_output=sentinel)
assert ("error:" in bad_log if mode == "native" else "self-host smoke:" in bad_log), bad_log
assert "unexpected call" not in bad_log.lower(), bad_log
assert ("LocalTypeMismatch" in bad_log if mode == "native" else "count type constraint=1" in bad_log), bad_log
assert sentinel.read_bytes() == b"keep the last artifact"
assert len(set(outputs)) == 1, outputs
(work / "outputs.json").write_text(json.dumps(outputs, indent=2) + "\n")
print(f"All cache checks passed. Evidence: {relative_work}")
