#!/usr/bin/env python3
"""Build the pinned transform host with the bounded GC reference repair."""
from pathlib import Path
import argparse
import hashlib
import json
import os
import shutil
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
patch = host_source / "patches/gc-frame-reference-liveness.patch"
patch_hash = hashlib.sha256(patch.read_bytes()).hexdigest()
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
subprocess.run(["git", "-C", str(source), "apply", "--check", str(patch)], check=True, env=env)
subprocess.run(["git", "-C", str(source), "apply", str(patch)], check=True, env=env)
if args.test:
    subprocess.run([
        "go", "test", "./src/core/compiler/backend/railshot/shared", "./src/wago",
        "-run", "TestGCFrameRootPlan|TestGCDecoderTupleReferenceSurvivesAdjacentScalarRead|TestGCReferenceRead|TestGCSharedReference",
        "-count=1",
    ], cwd=source, env=env, check=True)
build = work / "host"
build.mkdir()
for name in ("go.mod", "go.sum", "main.go"):
    shutil.copyfile(host_source / name, build / name)
with (build / "go.mod").open("a") as file:
    # JSON quoting is also valid Go module string quoting, including spaces.
    file.write("\nreplace " + module + " => " + json.dumps(str(source)) + "\n")
output.parent.mkdir(parents=True, exist_ok=True)
subprocess.run([
    "go", "build", "-mod=mod", "-ldflags=-X main.runtimePatchIdentity=" + patch_hash,
    "-o", str(output), ".",
], cwd=build, env=env, check=True)
identity = {
    "module": module, "version": version, "module_sum": metadata["Sum"],
    "patch_sha256": patch_hash, "host_sha256": hashlib.sha256(output.read_bytes()).hexdigest(),
    "tests_run": args.test, "private_source": str(source),
}
output.with_name(output.name + ".identity.json").write_text(json.dumps(identity, indent=2) + "\n")
print("Pinned Wago host ready:", output)
