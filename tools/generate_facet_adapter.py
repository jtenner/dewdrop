#!/usr/bin/env python3
"""Build the checked-in complete Facet 0.1 Dew adapter fixture."""

import argparse
import subprocess
import tempfile
from pathlib import Path

from generate_facet_bindings import ADAPTER, FACET_SPEC_REVISION, canonical_imports, outputs

ROOT = Path(__file__).resolve().parents[1]
TARGET = ROOT / "fixtures/facet/facet-adapter.wasm"


def audit_source() -> None:
    expected = outputs()[ADAPTER]
    actual = ADAPTER.read_text(encoding="utf-8") if ADAPTER.exists() else ""
    if actual != expected:
        raise SystemExit(
            "tools/facet-adapter.wat differs from generated Facet bindings at "
            + FACET_SPEC_REVISION
            + "; run tools/generate_facet_bindings.py"
        )
    imports = canonical_imports()
    if len(imports) != 261:
        raise SystemExit(f"Facet adapter import count is {len(imports)}, want 261")


def build(destination: Path) -> None:
    audit_source()
    subprocess.run(
        ["wasm-tools", "parse", str(ADAPTER), "-o", str(destination)],
        check=True,
        cwd=ROOT,
    )
    subprocess.run(
        ["wasm-tools", "validate", "--features", "all", str(destination)],
        check=True,
        cwd=ROOT,
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    if args.check:
        with tempfile.TemporaryDirectory() as directory:
            candidate = Path(directory) / "facet-adapter.wasm"
            build(candidate)
            if not TARGET.exists() or TARGET.read_bytes() != candidate.read_bytes():
                raise SystemExit(
                    "fixtures/facet/facet-adapter.wasm is stale; "
                    "run tools/generate_facet_adapter.py"
                )
        print(f"checked {TARGET.relative_to(ROOT)}")
        return
    TARGET.parent.mkdir(parents=True, exist_ok=True)
    build(TARGET)
    print(f"generated {TARGET.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
