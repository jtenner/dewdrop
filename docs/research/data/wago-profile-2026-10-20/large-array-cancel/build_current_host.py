#!/usr/bin/env python3
"""Build a private current-main control, profile, or runtime-patch host.

Run from the recorded Dewdrop checkout. The baseline identity must describe
the checksum-verified 7997c86c host, including its safety and Facet patches.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import time

root = Path(__file__).resolve().parents[5]
data = Path(__file__).resolve().parent
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("baseline_host", type=Path)
parser.add_argument("output", type=Path)
parser.add_argument("--runtime-patch", type=Path)
parser.add_argument("--plain", action="store_true", help="omit all diagnostic code")
parser.add_argument("--distance-counters", action="store_true")
args = parser.parse_args()
assert not (args.plain and args.distance_counters)
assert not (args.runtime_patch and args.distance_counters)
baseline = args.baseline_host.resolve()
identity = json.loads(baseline.with_name(baseline.name + ".identity.json").read_text())
assert identity["commit"] == "7997c86c36e05cfba4c4f39cabb026a318f55fc0"
assert hashlib.sha256(baseline.read_bytes()).hexdigest() == identity["host_sha256"]
work = Path(tempfile.mkdtemp(prefix="current-host-", dir=root / ".tmp/wago-investigation-2026-10-20"))
source = work / "wago"
shutil.copytree(identity["private_source"], source, ignore=shutil.ignore_patterns(".git"))
facet = work / "facet"
shutil.copytree(identity["facet_private_source"], facet, ignore=shutil.ignore_patterns(".git"))
subprocess.run(["git", "init", "-q", str(source)], check=True)
patches = []
if args.runtime_patch:
    patches.append(args.runtime_patch.resolve())
if not args.plain:
    patches.append(data / "current-main-diagnostic.patch")
if args.distance_counters:
    patches.append(data / "distance-counter.patch")
for patch in patches:
    subprocess.run(["git", "-C", str(source), "apply", "--check", str(patch)], check=True)
    subprocess.run(["git", "-C", str(source), "apply", str(patch)], check=True)
host = work / "host"
host.mkdir()
inputs = root / "tools/wago-transform-host"
digest = hashlib.sha256()
for path in [inputs / "go.mod", inputs / "go.sum", *sorted(inputs.glob("*.go"))]:
    content = path.read_bytes()
    (host / path.name).write_bytes(content)
    if not path.name.endswith("_test.go"):
        digest.update(path.name.encode() + b"\0" + content + b"\0")
assert digest.hexdigest() == identity["host_source_sha256"], "production host inputs changed"
if not args.plain:
    main = host / "main.go"
    content = main.read_text()
    assert "diagnosticprofile" not in content
    content = content.replace("import (", 'import (\n "github.com/wago-org/wago/diagnosticprofile"', 1)
    content = content.replace("func main() {", "func main() {\n diagnosticprofile.Start()\n defer diagnosticprofile.Finish()", 1)
    main.write_text(content)
with (host / "go.mod").open("a") as stream:
    stream.write("\nreplace github.com/wago-org/wago => " + json.dumps(str(source)) + "\n")
    stream.write("replace github.com/jtenner/wago-facet => " + json.dumps(str(facet)) + "\n")
variant = {
    "baseline": identity,
    "plain": args.plain,
    "distance_counters": args.distance_counters,
    "patches": {path.name: hashlib.sha256(path.read_bytes()).hexdigest() for path in patches},
}
variant_hash = hashlib.sha256(json.dumps(variant, sort_keys=True).encode()).hexdigest()
output = args.output.resolve()
output.parent.mkdir(parents=True, exist_ok=True)
command = [
    "mise", "exec", "go@1.27.2", "--", "go", "build", "-C", str(host), "-mod=mod",
    "-ldflags=-X main.runtimePatchIdentity=" + variant_hash + " -X main.workerPluginIdentity=" + identity["host_source_sha256"],
    "-o", str(output), ".",
]
started = time.monotonic()
subprocess.run(command, check=True, env=dict(os.environ, GOWORK="off", GOMAXPROCS="4"))
variant.update({
    "build_seconds": time.monotonic() - started,
    "command": command,
    "runtime_identity": variant_hash,
    "private_source": str(source),
    "host_source": str(host),
    "host_sha256": hashlib.sha256(output.read_bytes()).hexdigest(),
})
output.with_name(output.name + ".diagnostic.json").write_text(json.dumps(variant, indent=2) + "\n")
print(output)
