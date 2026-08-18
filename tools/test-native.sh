#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Keep the routine lane inside Dewdrop. A workspace-wide `moon test` also runs
# every test in the pinned Starshine source module.
moon test --target native \
  src/tokenizer src/parser src/standard_sources src/semantic src/backend \
  src/standard_loader src/compiler_driver "$@"
