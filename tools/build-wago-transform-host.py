#!/usr/bin/env python3
"""Build the pinned transform host with GC safety and isolated worker patches."""
from pathlib import Path
import argparse
import hashlib
import json
import os
import subprocess
import tempfile
import zipfile

root = Path(__file__).resolve().parent.parent
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("output", type=Path)
parser.add_argument("--test", action="store_true", help="run the host reference safety tests")
args = parser.parse_args()
output = args.output.resolve()
env = dict(os.environ, GOWORK="off")
host_source = root / "tools/wago-transform-host"
patch_inputs = [(path.name, path.read_bytes()) for path in sorted((host_source / "patches").glob("*.patch"))]
assert patch_inputs, "the pinned runtime needs its safety patches"
patch_hash = hashlib.sha256(b"".join(name.encode() + b"\0" + data + b"\0" for name, data in patch_inputs)).hexdigest()
module = "github.com/wago-org/wago"
version = "v0.0.0-20260915172549-2dd978ccda6f"
metadata = json.loads(subprocess.check_output(
    ["go", "mod", "download", "-json", module + "@" + version],
    cwd=host_source, env=env,
))
assert metadata["Path"] == module and metadata["Version"] == version, metadata
parent = root / ".tmp/wago-transform-host"
parent.mkdir(parents=True, exist_ok=True)
work = Path(tempfile.mkdtemp(prefix="build-", dir=parent))
source = work / "wago"
source.mkdir()
prefix = module + "@" + version + "/"
with zipfile.ZipFile(metadata["Zip"]) as archive:
    for entry in archive.infolist():
        assert entry.filename.startswith(prefix), entry.filename
        relative = Path(entry.filename[len(prefix):])
        assert not relative.is_absolute() and ".." not in relative.parts, relative
        destination = source / relative
        if entry.is_dir():
            destination.mkdir(parents=True, exist_ok=True)
        else:
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(archive.read(entry))
# A private Git root keeps git apply independent of the caller's worktree prefix.
subprocess.run(["git", "init", "-q", str(source)], check=True, env=env)
for name, patch_bytes in patch_inputs:
    private_patch = work / name
    private_patch.write_bytes(patch_bytes)
    subprocess.run(["git", "-C", str(source), "apply", "--check", str(private_patch)], check=True, env=env)
    subprocess.run(["git", "-C", str(source), "apply", str(private_patch)], check=True, env=env)
if args.test:
    subprocess.run([
        "go", "test", "./src/core/compiler/backend/railshot/shared", "./src/wago",
        "-run", "TestGCFrameRootPlan|TestGCDecoderTupleReferenceSurvivesAdjacentScalarRead|TestGCReferenceRead|TestGCSharedReference|TestManagedIsolatedFork|TestManagedForkContext",
        "-count=1",
    ], cwd=source, env=env, check=True)
build = work / "host"
build.mkdir()
host_inputs = [host_source / "go.mod", host_source / "go.sum", *sorted(host_source.glob("*.go"))]
source_digest = hashlib.sha256()
for source_input in host_inputs:
    source_bytes = source_input.read_bytes()
    (build / source_input.name).write_bytes(source_bytes)
    if not source_input.name.endswith("_test.go"):
        source_digest.update(source_input.name.encode() + b"\0" + source_bytes + b"\0")
host_source_hash = source_digest.hexdigest()
with (build / "go.mod").open("a") as file:
    # JSON quoting is also valid Go module string quoting, including spaces.
    file.write("\nreplace " + module + " => " + json.dumps(str(source)) + "\n")
if args.test:
    subprocess.run(["go", "test", "-mod=mod", "-race", "-run", "TestWorker", "-count=1", "-timeout=45s", "."], cwd=build, env=env, check=True)
output.parent.mkdir(parents=True, exist_ok=True)
subprocess.run([
    "go", "build", "-mod=mod", "-ldflags=-X main.runtimePatchIdentity=" + patch_hash + " -X main.workerPluginIdentity=" + host_source_hash,
    "-o", str(output), ".",
], cwd=build, env=env, check=True)
identity = {
    "module": module, "version": version, "module_sum": metadata["Sum"],
    "patch_sha256": patch_hash, "patches": {name: hashlib.sha256(data).hexdigest() for name, data in patch_inputs}, "host_sha256": hashlib.sha256(output.read_bytes()).hexdigest(),
    "tests_run": args.test, "private_source": str(source), "host_source_sha256": host_source_hash,
}
output.with_name(output.name + ".identity.json").write_text(json.dumps(identity, indent=2) + "\n")
print("Pinned Wago host ready:", output)
