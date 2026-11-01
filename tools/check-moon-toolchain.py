#!/usr/bin/env python3
"""Check the owner-selected SDK and its bundled core without changing it."""
import json
import os
from pathlib import Path
import shutil
import subprocess

root = Path(__file__).resolve().parents[1]
pins = json.loads((root / "tools/MOON_TOOLCHAIN.json").read_text())
for tool, args in (("moon", ["version"]), ("moonc", ["-v"])):
    actual = subprocess.check_output([tool, *args], text=True).splitlines()[0]
    if actual != pins[tool]:
        raise SystemExit(f"{tool} mismatch: expected {pins[tool]!r}; got {actual!r}")
moon_home = Path(os.environ.get("MOON_HOME", Path(shutil.which("moonc")).resolve().parents[1]))
core = moon_home / "lib/core/moon.mod"
expected = f'version = "{pins["core"]}"'
if expected not in core.read_text().splitlines():
    raise SystemExit(f"core mismatch: expected {expected} in {core}")
print(f'MoonBit baseline checked: {pins["core"]}')
