#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# These tests construct hundreds or thousands of compiler objects. Keep them
# available without charging their runtime to every small compiler edit.
moon test --target native --include-skipped \
  src/semantic/body_flow_stress_wbtest.mbt \
  src/semantic/call_inference_stress_wbtest.mbt \
  src/semantic/impl_method_stress_wbtest.mbt \
  src/semantic/lowering_plan_stress_wbtest.mbt \
  src/semantic/object_field_inference_stress_wbtest.mbt \
  src/semantic/pattern_match_loop_stress_wbtest.mbt "$@"
