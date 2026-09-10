#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Keep the routine lane inside Dewdrop. A workspace-wide `moon test` also runs
# every test in the pinned Starshine source module. Keep each measured package
# lane below the compiler activity limit instead of hiding one slow aggregate.
source tools/self-host-common.sh
read -r -a packages <<< "${DEW_NATIVE_TEST_PACKAGES:-tokenizer parser standard_sources semantic backend standard_loader compiler_driver}"
for package in "${packages[@]}"; do
  targets=("src/$package")
  if [[ ( "$package" == semantic || "$package" == backend ) && $# == 0 ]]; then
    # Measure each owning file and keep its failures visible.
    mapfile -t targets < <(rg --files "src/$package" -g '*_wbtest.mbt' -g '*_test.mbt' -g '!**/*_bench_test.mbt' | sort)
  fi
  for target in "${targets[@]}"; do
    self_host_measure "native $target tests" \
      moon test --target native --no-parallelize "$target" "$@"
  done
done
