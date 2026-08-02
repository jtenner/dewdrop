#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
python3 tools/wasi-parity/generate_cases.py
moon run --target native --release src/wasi_parity_gen
node tools/wasi-parity/parity.mjs
