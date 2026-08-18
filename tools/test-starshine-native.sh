#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# This lane is intentionally separate from routine Dewdrop validation.
moon test --target native -p jtenner/starshine "$@"
