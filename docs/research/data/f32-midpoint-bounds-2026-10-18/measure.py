"""Measure pinned controls and carry their complete build identity to samples."""
from pathlib import Path
import hashlib
import json
import platform
import subprocess
import sys
import time

root = Path(sys.argv[1]).resolve()
harness = Path(__file__).with_name("measure.mjs")
build = json.loads((root / "build.json").read_text())
fixtures = {identity: hashlib.sha256((root / (identity + ".wasm")).read_bytes()).hexdigest()
            for identity in ["before", "after"]}
for identity, digest in fixtures.items():
    if digest != build["builds"][identity]["wasm_sha256"]:
        raise RuntimeError("fixture differs from recorded build: " + identity)
records = []
for count in [1024, 4096, 16384, 65536]:
    for sample in range(3):
        for identity in ["before", "after"]:
            command = ["node", "--no-liftoff", "--expose-gc", str(harness),
                       str(root / (identity + ".wasm")), str(count)]
            start = time.monotonic()
            result = subprocess.run(command, text=True, capture_output=True, timeout=20)
            if result.returncode:
                raise RuntimeError((command, result.stdout, result.stderr))
            record = dict(identity=identity, sample=sample,
                          wallSeconds=time.monotonic() - start, **json.loads(result.stdout))
            records.append(record)
            print(json.dumps(record), flush=True)
report = dict(node=subprocess.check_output(["node", "--version"], text=True).strip(),
              environment=platform.platform(), architecture=platform.machine(),
              fixtures=fixtures, build_provenance=build,
              measurement_harness_sha256=hashlib.sha256(harness.read_bytes()).hexdigest(),
              samples=records)
(root / "samples.json").write_text(json.dumps(report, indent=2) + "\n")
