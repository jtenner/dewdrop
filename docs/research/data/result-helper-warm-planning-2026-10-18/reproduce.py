#!/usr/bin/env python3
"""Repeat the Result warm-cache comparison from the repository root.

The measured run's exact native binaries are identified by SHA-256 in the
records. A rebuilt binary is a new measurement; this script records its hash.
--planning creates and then removes one temporary executable package.
"""
import argparse
import hashlib
import io
import json
import pathlib
import shutil
import subprocess
import tarfile
import time

COMMON_STD_COMMIT = '73cfa029da908a7fe84e09549f07bff4fb686167'
parser = argparse.ArgumentParser()
parser.add_argument("--cli", type=pathlib.Path, required=True)
parser.add_argument("--work", type=pathlib.Path, default=pathlib.Path("/tmp/dewdrop-result-warm-repeat"))
parser.add_argument("--planning", action="store_true")
args = parser.parse_args()
root = pathlib.Path.cwd()
evidence = pathlib.Path(__file__).resolve().parent
work = args.work.resolve()
work.mkdir(parents=True, exist_ok=False)
archive = subprocess.check_output(["git", "archive", COMMON_STD_COMMIT, "std"])
for variant in ["old", "new"]:
    with tarfile.open(fileobj=io.BytesIO(archive)) as files:
        files.extractall(work / variant, filter="data")
    shutil.copyfile(evidence / ("result-" + variant + ".dew.txt"), work / variant / "std/result.dew")
shutil.copyfile(evidence / "main.dew.txt", work / "main.dew")
shutil.copyfile(args.cli, work / "dew_cli.exe")
(work / "dew_cli.exe").chmod(0o755)
print("cli_sha256=" + hashlib.sha256((work / "dew_cli.exe").read_bytes()).hexdigest(), flush=True)
shutil.copyfile(evidence / "measure-cli.py", work / "measure-cli.py")
subprocess.run(["python3", str(work / "measure-cli.py")], cwd=root, check=True)
if args.planning:
    package = root / "src/_result_warm_probe"
    package.mkdir(exist_ok=False)
    try:
        source = (evidence / "planning-probe.mbt.txt").read_text().replace(
            "/tmp/dewdrop-implementation-2026-10-18/result-warm-planning", str(work))
        (package / "main.mbt").write_text(source)
        shutil.copyfile(evidence / "planning-probe.moon.pkg.txt", package / "moon.pkg")
        start = time.perf_counter()
        built = subprocess.run(["moon", "build", "--target", "native", "--release", "src/_result_warm_probe"], cwd=root, capture_output=True, text=True, timeout=29)
        meta = {"build_seconds": time.perf_counter() - start, "exit": built.returncode,
                "probe_source_sha256": hashlib.sha256(source.encode()).hexdigest()}
        (work / "planning-build.stdout").write_text(built.stdout)
        (work / "planning-build.stderr").write_text(built.stderr)
        print(json.dumps(meta), flush=True)
        if built.returncode:
            raise RuntimeError(built.stderr)
        binary = root / "_build/native/release/build/jtenner/dewdrop/_result_warm_probe/_result_warm_probe.exe"
        print("planning_binary_sha256=" + hashlib.sha256(binary.read_bytes()).hexdigest(), flush=True)
        start = time.perf_counter()
        measured = subprocess.run([str(binary)], capture_output=True, text=True, timeout=29)
        (work / "planning-raw.stdout").write_text(measured.stdout)
        (work / "planning-raw.stderr").write_text(measured.stderr)
        print("planning_run_seconds=" + str(time.perf_counter() - start), flush=True)
        print(measured.stdout, flush=True)
        if measured.returncode:
            raise RuntimeError(measured.stderr)
    finally:
        shutil.rmtree(package)
