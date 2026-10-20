#!/usr/bin/env python3
"""Write the frozen build identity used by the Dew transform-result cache."""
from __future__ import annotations

import hashlib
from pathlib import Path
import struct
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
STUB = "self_host/compiler/transform_cache_identity.dew"


def build_identity() -> str:
    names = subprocess.check_output(
        ["rg", "--files", "src", "std", "self_host/compiler", "self_host/starshine",
         "starshine-mb/src", "starshine-mb/ffi/src"], cwd=ROOT, text=True,
    ).splitlines()
    selected = {
        name for name in names
        if name != STUB and Path(name).suffix in {".mbt", ".c", ".dew", ".pkg", ".json"}
        and not name.endswith(("_test.dew", "_test.mbt", "_wbtest.mbt"))
    }
    selected.update({
        "moon.mod", "starshine-mb/moon.mod", "starshine-mb/ffi/moon.mod",
        "starshine-mb/dist/ffi/starshine-ffi.wasm", "fixtures/facet/facet-adapter.wasm",
        "tools/generate_transform_cache_identity.py", "tools/check-self-host-bootstrap.sh",
        "tools/moonbit-time-provider.wat", "tools/generate_starshine_ffi_consumer.py",
    })
    digest = hashlib.sha256(b"DEW_TRANSFORM_COMPILER_BUILD_V1\0")
    version = subprocess.check_output(["moon", "version"], cwd=ROOT)
    digest.update(struct.pack("<I", len(version)))
    digest.update(version)
    digest.update(struct.pack("<I", len(selected)))
    for name in sorted(selected):
        path = ROOT / name
        data = path.read_bytes()  # Missing required inputs are a build error.
        label = name.encode("utf-8")
        digest.update(struct.pack("<I", len(label)))
        digest.update(label)
        digest.update(struct.pack("<Q", len(data)))
        digest.update(hashlib.sha256(data).digest())
    return digest.hexdigest()


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit("usage: generate_transform_cache_identity.py OUTPUT.dew")
    identity = build_identity()
    output = Path(sys.argv[1])
    if output.resolve() == ROOT / STUB:
        raise SystemExit("the checked-in empty identity must not be replaced")
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(
        "// Generated compiler build identity. Regenerate for every compiler build.\n"
        "fn ct_transform_compiler_identity() -> Bytes {\n"
        f'  b"{identity}"\n'
        "}\n", encoding="utf-8",
    )
    print(f"transform compiler identity: {identity}")


if __name__ == "__main__":
    main()
