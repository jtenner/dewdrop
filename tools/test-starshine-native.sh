#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# This lane is intentionally separate from routine Dewdrop validation.
# MoonBit's native debug linker needs more than the usual 8 MiB stack for
# the full pinned pass/fuzz test modules. Keep a larger caller limit intact.
starshine_test_stack_kib=$(ulimit -S -s)
if [[ "$starshine_test_stack_kib" != unlimited ]] && (( starshine_test_stack_kib < 65536 )); then
  ulimit -S -s 65536
  echo "Starshine native test stack: 65536 KiB" >&2
fi
moon test --target native -p jtenner/starshine "$@"
