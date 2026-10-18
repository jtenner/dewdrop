#!/usr/bin/env python3
"""Run the isolated owner-key proof from the Dewdrop repository root.

Both runs use the same baseline pack implementation. The candidate substitutes
only the recorded owner function. Full parse-cache tests are separate.
"""
import hashlib
import json
import pathlib
import subprocess
import tempfile
import time

BASELINE = "7ac4abc716079c85d1db6f521f57c44d1e718acd"
root = pathlib.Path.cwd()
evidence = pathlib.Path(__file__).resolve().parent
with tempfile.TemporaryDirectory(prefix="dewdrop-owner-proof-") as name:
    work = pathlib.Path(name)
    (work / "moon.mod").write_text('name = "owner_proof"\nversion = "0.1.0"\nimport { "moonbitlang/x@0.5.5" }\n')
    (work / "moon.pkg").write_text('import { "moonbitlang/core/buffer", "moonbitlang/core/encoding/utf8", "moonbitlang/x/crypto" }\n')
    (work / ".mooncakes").symlink_to(root / ".mooncakes", target_is_directory=True)
    for filename in ["artifact_pack_lazy.mbt", "artifact_pack.mbt", "codec.mbt", "blake3.mbt"]:
        data = subprocess.check_output(["git", "show", BASELINE + ":src/cache_binary/" + filename])
        (work / filename).write_bytes(data)
        print(filename, "sha256=" + hashlib.sha256(data).hexdigest(), flush=True)
    (work / "owner_wbtest.mbt").write_bytes((evidence / "probe_wbtest.mbt.txt").read_bytes())
    for label, filename in [("red", "baseline-owner.mbt.txt"), ("green", "candidate-owner.mbt.txt")]:
        data = (evidence / filename).read_bytes()
        (work / "owner.mbt").write_bytes(data)
        start = time.monotonic()
        result = subprocess.run(["moon", "test", "--target", "native", "--no-parallelize", "--frozen"], cwd=work, capture_output=True, text=True)
        print(json.dumps({"label": label, "exit": result.returncode, "seconds": time.monotonic() - start, "owner_sha256": hashlib.sha256(data).hexdigest()}), flush=True)
        print(result.stdout, flush=True)
        print(result.stderr, flush=True)
        expected = 2 if label == "red" else 0
        if result.returncode != expected:
            raise SystemExit("unexpected proof result")
