#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Keep the routine lane inside Dewdrop. A workspace-wide `moon test` also runs
# every test in the pinned Starshine source module. Keep each measured package
# lane below the compiler activity limit instead of hiding one slow aggregate.
source tools/self-host-common.sh
for package in \
  tokenizer parser standard_sources semantic backend standard_loader compiler_driver
do
  self_host_measure "native $package tests" \
    moon test --target native "src/$package" "$@"
done
