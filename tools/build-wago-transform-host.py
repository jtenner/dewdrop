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
facet_patch_inputs = [(path.name, path.read_bytes()) for path in sorted((host_source / "facet-patches").glob("*.patch"))]
identity_patches = [("wago/" + name, data) for name, data in patch_inputs] + [("facet/" + name, data) for name, data in facet_patch_inputs]
assert patch_inputs, "the pinned runtime needs its safety patches"
patch_hash = hashlib.sha256(b"".join(name.encode() + b"\0" + data + b"\0" for name, data in identity_patches)).hexdigest()
module = "github.com/wago-org/wago"
version = "v0.1.0-beta.13.0.20261020170030-7997c86c36e0"
metadata = json.loads(subprocess.check_output(
    ["go", "mod", "download", "-json", module + "@" + version],
    cwd=host_source, env=env,
))
assert metadata["Path"] == module and metadata["Version"] == version, metadata
parent = root / ".tmp/wago-transform-host"
parent.mkdir(parents=True, exist_ok=True)
work = Path(tempfile.mkdtemp(prefix="build-", dir=parent))
def extract_patched_module(metadata, source, patches):
    source.mkdir()
    prefix = metadata["Path"] + "@" + metadata["Version"] + "/"
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
    # A private Git root keeps git apply independent of the caller's worktree.
    subprocess.run(["git", "init", "-q", str(source)], check=True, env=env)
    for name, patch_bytes in patches:
        private_patch = work / (source.name + "-" + name)
        private_patch.write_bytes(patch_bytes)
        subprocess.run(["git", "-C", str(source), "apply", "--check", str(private_patch)], check=True, env=env)
        subprocess.run(["git", "-C", str(source), "apply", str(private_patch)], check=True, env=env)

source = work / "wago"
extract_patched_module(metadata, source, patch_inputs)
facet_module = "github.com/jtenner/wago-facet"
facet_version = "v0.1.0"
facet_metadata = json.loads(subprocess.check_output(
    ["go", "mod", "download", "-json", facet_module + "@" + facet_version],
    cwd=host_source, env=env,
))
assert facet_metadata["Path"] == facet_module and facet_metadata["Version"] == facet_version, facet_metadata
facet_source = work / "facet"
extract_patched_module(facet_metadata, facet_source, facet_patch_inputs)
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
    file.write("replace " + facet_module + " => " + json.dumps(str(facet_source)) + "\n")
if args.test:
    subprocess.run(["go", "test", "-mod=mod", "-race", "-run", "TestWorker", "-count=1", "-timeout=45s", "."], cwd=build, env=env, check=True)
output.parent.mkdir(parents=True, exist_ok=True)
subprocess.run([
    "go", "build", "-mod=mod", "-ldflags=-X main.runtimePatchIdentity=" + patch_hash + " -X main.workerPluginIdentity=" + host_source_hash,
    "-o", str(output), ".",
], cwd=build, env=env, check=True)
identity = {
    "module": module, "version": version, "commit": "7997c86c36e05cfba4c4f39cabb026a318f55fc0", "module_sum": metadata["Sum"],
    "patch_sha256": patch_hash, "patches": {name: hashlib.sha256(data).hexdigest() for name, data in identity_patches}, "host_sha256": hashlib.sha256(output.read_bytes()).hexdigest(),
    "facet_version": facet_version, "facet_sum": facet_metadata["Sum"], "facet_private_source": str(facet_source),
    "tests_run": args.test, "private_source": str(source), "host_source_sha256": host_source_hash,
}
output.with_name(output.name + ".identity.json").write_text(json.dumps(identity, indent=2) + "\n")
print("Pinned Wago host ready:", output)
