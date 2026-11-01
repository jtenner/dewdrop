#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
python3 tools/check-moon-toolchain.py
exec python3 tools/module-snapshots/run.py "$@"
