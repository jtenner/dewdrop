#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Keep the routine lane inside Dewdrop. A workspace-wide `moon test` also runs
# every test in the pinned Starshine source module. Keep each measured package
# lane below the compiler activity limit instead of hiding one slow aggregate.
source tools/self-host-common.sh
if ! command -v rg >/dev/null 2>&1; then
  echo "native test runner requires rg on PATH; no tests were selected" >&2
  exit 127
fi
read -r -a packages <<< "${DEW_NATIVE_TEST_PACKAGES:-tokenizer parser standard_sources transforms semantic backend standard_loader compiler_driver}"
test_status=0
for package in "${packages[@]}"; do
  targets=("src/$package")
  if [[ ( "$package" == semantic || "$package" == backend || "$package" == compiler_driver ) && $# == 0 ]]; then
    # Measure each owning file and keep its failures visible.
    if ! native_test_paths="$(rg --files "src/$package" -g '*_wbtest.mbt' -g '*_test.mbt' -g '!**/*_bench_test.mbt' | sort)"; then
      echo "failed to list native test files in src/$package" >&2
      exit 1
    fi
    if [[ -z "$native_test_paths" ]]; then
      echo "no native test files found in src/$package" >&2
      exit 1
    fi
    mapfile -t targets <<< "$native_test_paths"
  fi
  for target in "${targets[@]}"; do
    self_host_measure "native $target tests" \
      moon test --target native --no-parallelize "$target" "$@" || test_status=1
  done
done
exit "$test_status"
