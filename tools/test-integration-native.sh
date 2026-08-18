#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# The combined semantic runner has severe contention. Run one owning file at a
# time so that the lane has steady progress and bounded memory use.
files=(
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

for test_file in "${files[@]}"; do
  echo "== $test_file =="
  moon test --target native --include-skipped "$test_file" "$@"
done
