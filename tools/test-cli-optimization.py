#!/usr/bin/env python3
"""Execute CLI optimization, cache, metadata, and failure-publication regressions."""

import argparse
import json
import os
from pathlib import Path
import shlex
import subprocess
import tempfile
import time

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--starshine", type=Path, required=True)
    args = parser.parse_args()
    (ROOT / ".tmp").mkdir(exist_ok=True)
    directory = Path(tempfile.mkdtemp(prefix="cli-optimization-", dir=ROOT / ".tmp"))
    environment = dict(os.environ, DEW_CACHE_DIR=str(directory / "cache"),
                       DEW_STARSHINE=str(args.starshine.resolve()))
    records = []

    def run(arguments, *, success=True, env=None):
        started = time.perf_counter()
        command = [str(value) for value in arguments]
        process = subprocess.run(command, cwd=ROOT, env=env or environment,
                                 text=True, capture_output=True, timeout=600, input="")
        elapsed = time.perf_counter() - started
        records.append(dict(command=command, seconds=elapsed, returncode=process.returncode,
                            stdout=process.stdout, stderr=process.stderr,
                            performance_bug=elapsed > 30))
        (directory / "report.json").write_text(json.dumps(records, indent=2) + "\n")
        if (process.returncode == 0) != success:
            raise AssertionError(f"unexpected status {process.returncode}: {command}\n"
                                 f"{process.stdout}{process.stderr}\nrecords: {directory}")
        return process.stdout

    dew = ROOT / "tools/dew"
    source = directory / "main.dew"
    source.write_text("pub fn main() -> I32 {\n  42\n}\n")
    plain = directory / "plain.wasm"
    fast = directory / "fast.wasm"
    hit = directory / "hit.wasm"
    printed = json.loads(run([dew, "build", "--optimize", "speed", "--print-passes"]))
    assert printed["passes"] == ["duplicate-function-elimination", "precompute", "inlining",
                                  "local-cse", "simplify-locals-nostructure", "coalesce-locals", "vacuum",
                                  "remove-unused-module-elements", "memory-packing",
                                  "reorder-locals", "strip-debug"]
    custom = json.loads(run([dew, "build", "--starshine-pass", "precompute",
                             "--starshine-pass", "vacuum", "--starshine-pass", "precompute",
                             "--print-passes"]))
    assert custom["passes"] == ["precompute", "vacuum", "precompute"]
    assert "build output cache: miss" in run([dew, "build", source, "-o", plain, "--cache-report"])
    assert "build output cache: miss" in run([dew, "build", source, "-o", fast,
                                              "--optimize", "speed", "--cache-report"])
    assert "build output cache: hit" in run([dew, "build", source, "-o", hit,
                                             "--optimize", "speed", "--cache-report"])
    assert hit.read_bytes() == fast.read_bytes()
    probe = ('const fs=require("node:fs"),assert=require("node:assert/strict");'
             'const e=new WebAssembly.Instance(new WebAssembly.Module(fs.readFileSync(process.argv[1]))).exports;'
             'e.__dew_init?.();assert.equal(e.main(),42);')
    for binary in [plain, fast, hit]:
        run(["wasm-tools", "validate", "--features", "all", binary])
        run(["node", "-e", probe, binary])
    standalone = directory / "standalone.wasm"
    run([dew, "optimize", plain, "-o", standalone])
    run(["node", "-e", probe, standalone])
    default_environment = dict(environment)
    default_environment.pop("DEW_STARSHINE")
    run([dew, "optimize", plain, "-o", standalone], env=default_environment)
    run(["node", "-e", probe, standalone])
    run([dew, "optimize", plain, "-o", standalone, "--optimize", "none"])
    assert standalone.read_bytes() == plain.read_bytes()
    assert json.loads(run([dew, "optimize", "--print-passes"]))["passes"] == printed["passes"]
    run([dew, "run", ROOT / "tests/run-pass/hello.dew", "--optimize", "speed"])
    tests = run([dew, "test", "--manifest", ROOT / "tests/cli/test-package/dew.modules.json",
                 "--optimize", "speed"])
    assert "Dew tests passed: 2" in tests, tests
    listed = run([dew, "test", "--manifest", ROOT / "tests/cli/test-package/dew.modules.json",
                  "--optimize", "speed", "--list"])
    assert "linked answer" in listed and "library answer" in listed, listed
    wat = directory / "fast.wat"
    run([dew, "build", source, "--emit", "wat", "--optimize", "speed", "-o", wat])
    run(["wasm-tools", "parse", wat, "-o", standalone])
    run(["node", "-e", probe, standalone])

    # A failed transform must retain the user's last artifact and must not
    # publish a successful whole-build cache entry for the failing schedule.
    previous = fast.read_bytes()
    before = set((directory / "cache/builds").glob("*.dba"))
    run([dew, "build", source, "-o", fast, "--starshine-pass", "unknown-dew-pass"], success=False)
    assert fast.read_bytes() == previous
    assert set((directory / "cache/builds").glob("*.dba")) == before
    run([dew, "build", source, "-o", fast, "--emit", "hir", "--optimize", "speed"], success=False)
    assert fast.read_bytes() == previous

    # A new optimizer executable must invalidate an otherwise identical key.
    wrapper = directory / "starshine"
    script = f'#!/usr/bin/env bash\nexec {shlex.quote(str(args.starshine.resolve()))} "$@"\n'
    wrapper.write_text(script)
    wrapper.chmod(0o755)
    custom_environment = dict(environment, DEW_STARSHINE=str(wrapper))
    command = [dew, "build", source, "-o", fast, "--optimize", "speed", "--cache-report"]
    assert "build output cache: miss" in run(command, env=custom_environment)
    assert "build output cache: hit" in run(command, env=custom_environment)
    wrapper.write_text(script + "# changed optimizer identity\n")
    assert "build output cache: miss" in run(command, env=custom_environment)
    assert fast.read_bytes() == previous
    print(f"CLI optimization checks passed; timed records: {directory / 'report.json'}")


if __name__ == "__main__":
    main()
