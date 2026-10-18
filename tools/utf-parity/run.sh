#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
source tools/self-host-common.sh
self_host_measure "UTF parity case generation" python3 tools/utf-parity/generate_cases.py
# Debug native builds avoid the large release C optimizer pass. Dew output
# still uses the same production compiler pipeline and all parity checks.
self_host_measure "UTF parity generator build and Dew compilation" \
  moon run --target native -j 2 "$@" src/utf_parity_gen
self_host_measure "UTF parity runtime checks" node tools/utf-parity/parity.mjs
