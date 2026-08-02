#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
python3 tools/utf-parity/generate_cases.py
moon run --target native src/utf_parity_gen
node tools/utf-parity/parity.mjs
