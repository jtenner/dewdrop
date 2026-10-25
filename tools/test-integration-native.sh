#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source tools/self-host-common.sh

# The combined semantic runner has severe contention. Run one owning file at a
# time so that the lane has steady progress and bounded memory use.
files=(
  src/backend/btree_storage_primitives_wbtest.mbt
  src/backend/starshine_lane_types_wbtest.mbt
  src/backend/starshine_packed_primitives_wbtest.mbt
  src/backend/starshine_program_link_wbtest.mbt
  src/semantic/frozen_interface_cache_wbtest.mbt
  src/semantic/imported_semantics_wbtest.mbt
  src/semantic/module_system_wbtest.mbt
  src/semantic/program_link_plan_wbtest.mbt
  src/semantic/program_optimization_wbtest.mbt
  src/semantic/queue_wbtest.mbt
  src/semantic/red_black_tree_wbtest.mbt
  src/semantic/set_wbtest.mbt
  src/semantic/show_wbtest.mbt
  src/semantic/stack_wbtest.mbt
  src/semantic/standard_preamble_wbtest.mbt
  src/semantic/text_hash_wbtest.mbt
  src/semantic/text_iteration_wbtest.mbt
  src/semantic/text_ordering_wbtest.mbt
)

# Select owning files for a focused integration run; keep the full list by default.
if [[ -n "${DEW_INTEGRATION_TEST_FILES:-}" ]]; then
  read -r -a files <<< "$DEW_INTEGRATION_TEST_FILES"
fi

test_status=0
for test_file in "${files[@]}"; do
  echo "== $test_file =="
  self_host_measure "native integration $test_file" \
    moon test --target native --include-skipped "$test_file" "$@" || test_status=1
done
exit "$test_status"
