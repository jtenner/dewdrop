#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

echo "== Dew standard library =="
tools/dew-test/run.sh

echo "== SWAR parity =="
tools/swar-parity/run.sh

echo "== UTF parity =="
tools/utf-parity/run.sh

echo "== WASI parity =="
tools/wasi-parity/run.sh

echo "== deterministic module snapshots: Node + Wago Core 3 =="
tools/module-snapshots/run.sh

python3 tools/check-architecture-cases.py --wat

echo "full Dew validation passed"
