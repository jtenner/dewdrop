"""Build the two exact, committed tokenizer controls from the repository root."""
from pathlib import Path
import hashlib
import json
import os
import subprocess
import sys
import time


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


root = Path(sys.argv[1]).resolve()
root.mkdir(parents=True, exist_ok=True)
repo = Path.cwd()
here = Path(__file__).resolve().parent
revisions = {
    "before": "6a881286bc3f3a99e3f02b08224f313eada894d7",
    "after": "ee41a4b19a19614d3e0175fdb884aec15106e087",
}
generator = repo / "_build/native/release/build/jtenner/dewdrop/dew_test_gen/dew_test_gen.exe"
common = [
    ("compiler_value_primitives.dew", repo / "self_host/compiler/compiler_value_primitives.dew"),
    ("tokenizer_f32_decimal_test.dew", repo / "self_host/compiler/tokenizer_f32_decimal_test.dew"),
    ("tokenizer_f32_bounded_test.dew", repo / "self_host/compiler/tokenizer_f32_bounded_test.dew"),
    ("scaling.dew", here / "scaling.dew"),
]
metadata = {
    "repository_head": subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip(),
    "repository_status": subprocess.check_output(["git", "status", "--porcelain"], text=True),
    "working_diff_sha256": hashlib.sha256(subprocess.check_output(["git", "diff", "HEAD", "--binary"])).hexdigest(),
    "generator": {"path": str(generator), "sha256": sha256(generator)},
    "common_sources": {name: {"path": str(path), "sha256": sha256(path)} for name, path in common},
    "harness_sha256": {name: sha256(here / name) for name in ["build.py", "measure.py", "measure.mjs", "scaling.dew"]},
    "builds": {},
}
env = dict(os.environ, DEW_STD_ROOT=str(repo))
for identity, revision in revisions.items():
    tokenizer = root / ("tokenizer-" + identity + ".dew")
    tokenizer.write_bytes(subprocess.check_output([
        "git", "show", revision + ":self_host/compiler/tokenizer.dew",
    ]))
    output = root / (identity + ".wasm")
    command = [str(generator), str(output), "self_host.compiler"]
    for name, path in [common[0], ("tokenizer.dew", tokenizer), *common[1:]]:
        command += ["self_host.compiler", name, str(path)]
    start = time.monotonic()
    result = subprocess.run(command, env=env, text=True, capture_output=True, timeout=25)
    elapsed = time.monotonic() - start
    log = root / (identity + "-generate.log")
    log.write_text(result.stdout + result.stderr)
    record = {
        "tokenizer_commit": revision,
        "tokenizer_sha256": sha256(tokenizer),
        "generator_sha256": metadata["generator"]["sha256"],
        "command": command,
        "environment": {"DEW_STD_ROOT": str(repo)},
        "elapsed_seconds": elapsed,
        "exit_status": result.returncode,
        "log_sha256": sha256(log),
        "log": log.read_text(),
    }
    if result.returncode == 0:
        record["wasm_sha256"] = sha256(output)
        record["wasm_bytes"] = output.stat().st_size
    metadata["builds"][identity] = record
    (root / "build.json").write_text(json.dumps(metadata, indent=2) + "\n")
    print(identity, f"{elapsed:.3f} seconds", "exit", result.returncode, flush=True)
    if result.returncode:
        print(log.read_text(), file=sys.stderr)
        raise SystemExit(result.returncode)
if sha256(generator) != metadata["generator"]["sha256"]:
    raise RuntimeError("test generator changed during the two builds")
for name, path in common:
    if sha256(path) != metadata["common_sources"][name]["sha256"]:
        raise RuntimeError("common source changed during the two builds: " + name)
