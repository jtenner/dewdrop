#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

root=$PWD
work=$root/.tmp/self-host-smoke
build_cache_args=()
cold_check=0
case "${1:-}" in
  "") ;;
  --clean)
    build_cache_args=(--no-build-cache)
    cold_check=1
    ;;
  *)
    echo "usage: tools/check-self-host-smoke.sh [--clean]" >&2
    exit 2
    ;;
esac

source tools/self-host-common.sh
self_host_ensure_starshine_ffi
parser_sources=(
  self_host/compiler/compiler_value_primitives.dew
  self_host/compiler/compiler_runtime_assertions.dew
  self_host/compiler/tokenizer.dew
  self_host/compiler/parser_ast.dew
  self_host/compiler/parser_derive_core.dew
  self_host/compiler/parser_derive_format.dew
  self_host/compiler/parser_core.dew
  self_host/compiler/parser_pattern.dew
  self_host/compiler/parser_expression.dew
  self_host/compiler/parser_control.dew
  self_host/compiler/parser_declaration_forms.dew
  self_host/compiler/parser_declarations.dew
  self_host/compiler/parser.dew
)
semantic_sources=(
  self_host/compiler/semantic_ids.dew
  self_host/compiler/semantic_hir.dew
  self_host/compiler/semantic_model.dew
  self_host/compiler/semantic_collection.dew
  self_host/compiler/semantic_body_lowering.dew
  self_host/compiler/semantic_resolved_types.dew
  self_host/compiler/semantic_module_interfaces.dew
  self_host/compiler/semantic_type_resolution.dew
  self_host/compiler/semantic_alias_resolution.dew
  self_host/compiler/semantic_program_interfaces.dew
  self_host/compiler/semantic_imported_semantics.dew
  self_host/compiler/semantic_value_shapes.dew
  self_host/compiler/semantic_function_plan.dew
  self_host/compiler/semantic_type_layouts.dew
  self_host/compiler/semantic_inference_types.dew
  self_host/compiler/semantic_local_unification.dew
  self_host/compiler/semantic_body_names.dew
  self_host/compiler/semantic_body_name_resolution.dew
  self_host/compiler/semantic_module_value_dependencies.dew
  self_host/compiler/semantic_basic_body_inference.dew
  self_host/compiler/semantic_module_value_inference.dew
  self_host/compiler/semantic_inference_merge.dew
  self_host/compiler/semantic_body_value_shapes.dew
  self_host/compiler/semantic_module_initialization.dew
  self_host/compiler/semantic_impl_index.dew
  self_host/compiler/semantic_body_evidence.dew
  self_host/compiler/semantic_lowering_plan.dew
  self_host/compiler/semantic_program_lowering.dew
  self_host/compiler/semantic_program_specialization.dew
  self_host/compiler/semantic_program_specialization_index.dew
  self_host/compiler/semantic_wasmgc_fragment_plan.dew
  self_host/compiler/semantic_wasm_body_link_index.dew
  self_host/compiler/semantic_program_link_plan.dew
  self_host/compiler/semantic_wasm_body_plan.dew
  self_host/compiler/semantic_body_flow.dew
)

if [[ "${DEW_SELF_HOST_FULL_VALIDATION:-0}" == "1" ]]; then
  tools/dew test \
  "${parser_sources[@]}" \
  self_host/compiler/tokenizer_test.dew \
  self_host/compiler/tokenizer_parity_test.dew \
  self_host/compiler/parser_type_test.dew \
  self_host/compiler/parser_pattern_test.dew \
  self_host/compiler/parser_expression_test.dew \
  self_host/compiler/parser_declaration_test.dew \
  self_host/compiler/parser_defer_test.dew \
  self_host/compiler/parser_test.dew

tools/dew test \
  "${parser_sources[@]}" \
  "${semantic_sources[@]}" \
  self_host/compiler/semantic_ids_test.dew \
  self_host/compiler/semantic_collection_test.dew \
  self_host/compiler/semantic_body_test.dew \
  self_host/compiler/semantic_type_resolution_test.dew \
  self_host/compiler/semantic_module_interfaces_test.dew \
  self_host/compiler/semantic_program_interfaces_test.dew \
  self_host/compiler/semantic_body_name_resolution_test.dew \
  self_host/compiler/semantic_module_value_dependencies_test.dew \
  self_host/compiler/semantic_module_value_inference_test.dew \
  self_host/compiler/semantic_module_initialization_test.dew \
  self_host/compiler/semantic_body_flow_test.dew \
  self_host/compiler/semantic_derive_expansion_test.dew \
  self_host/compiler/semantic_imported_semantics_test.dew \
  self_host/compiler/semantic_value_shapes_test.dew \
  self_host/compiler/semantic_function_plan_test.dew \
  self_host/compiler/semantic_type_layouts_test.dew \
  self_host/compiler/semantic_imported_selection_test.dew \
  self_host/compiler/semantic_local_unification_test.dew \
  self_host/compiler/semantic_impl_index_test.dew \
  self_host/compiler/semantic_trait_evidence.dew \
  self_host/compiler/semantic_trait_evidence_test.dew \
  self_host/compiler/semantic_body_evidence_test.dew \
  self_host/compiler/semantic_inference_compaction.dew \
  self_host/compiler/semantic_inference_compaction_test.dew \
  self_host/compiler/semantic_inference_merge_test.dew \
  self_host/compiler/semantic_body_value_shapes_test.dew \
  self_host/compiler/semantic_lowering_plan_test.dew \
  self_host/compiler/semantic_program_lowering_test.dew \
  self_host/compiler/semantic_program_specialization_test.dew \
  self_host/compiler/semantic_wasmgc_fragment_plan_test.dew \
  self_host/compiler/semantic_program_link_plan_test.dew \
  self_host/compiler/semantic_basic_body_inference_test.dew \
  self_host/compiler/semantic_callable_selection_test.dew \
  self_host/compiler/semantic_member_selection_test.dew \
  self_host/compiler/semantic_variant_selection_test.dew \
  self_host/compiler/semantic_operator_selection_test.dew

  python3 tools/check-self-host-parser.py
  python3 tools/check-self-host-semantics.py
else
  echo "self-host: parser and semantic lanes are owned by tools/test-native.sh"
fi

rm -rf "$work"
mkdir -p "$work/a" "$work/b" "$work/reject-fingerprint" "$work/reject-count"

sources=(
  self_host/starshine/ffi.dew
  self_host/starshine/fingerprint.dew
  "${parser_sources[@]}"
  "${semantic_sources[@]}"
  self_host/compiler/request.dew
  self_host/compiler/facet_runtime.dew
  self_host/compiler/starshine_builtin_emit.dew
  self_host/compiler/starshine_runtime_emit.dew
  self_host/compiler/starshine_module.dew
  self_host/compiler/main.dew
)

build_compiler() {
  local stage=$1
  self_host_measure "smoke compiler $stage build" tools/dew build \
    --link-wasm starshine starshine-mb/dist/ffi/starshine-ffi.wasm \
    --link-wasm facet fixtures/facet/facet-adapter.wasm \
    "${build_cache_args[@]}" \
    -o "$work/$stage/compiler.wasm" \
    "${sources[@]}"
  self_host_measure "smoke compiler $stage validation" \
    wasm-tools validate --features all "$work/$stage/compiler.wasm"
}

write_request() {
  local stage=$1
  self_host_measure "smoke request $stage build" \
    moon run --target native --release src/self_host_smoke_fixture -- \
      "$work/$stage/request.bin" \
      starshine-mb/dist/ffi/starshine-ffi.wasm \
      self_host/starshine/fingerprint-prefix.bin \
      ".tmp/self-host-smoke/$stage/output.wasm"
}

run_compiler() {
  local stage=$1
  self_host_measure "smoke compiler $stage execution" self_host_run_node_facet \
    "$work/$stage/compiler.wasm" \
    "$work/$stage/request.bin"
  self_host_measure "smoke output $stage validation" \
    wasm-tools validate --features all "$work/$stage/output.wasm"
  local wat="$work/$stage/output.wat"
  wasm-tools print "$work/$stage/output.wasm" > "$wat"
  grep -Fq 'local.get 0' "$wat"
  grep -Fq 'local.get 1' "$wat"
  test "$(grep -Ec 'call [0-9]+' "$wat")" -ge 2
  grep -Fq 'i32.const 35' "$wat"
  grep -Fq 'local.set 0' "$wat"
  grep -Fq 'i32.const 70' "$wat"
  grep -Fq 'i32.eq' "$wat"
  grep -Fq 'i32.gt_u' "$wat"
  grep -Fq '(struct (field i32) (field i64))' "$wat"
  grep -Fq '(sub (struct))' "$wat"
  grep -Eq '\(sub final [0-9]+ \(struct \(field i32\)\)\)' "$wat"
  grep -Eq '\(sub final [0-9]+ \(struct \(field i32\) \(field i64\)\)\)' "$wat"
  grep -Eq 'struct.new [0-9]+' "$wat"
  grep -Eq 'struct.get [0-9]+ 0' "$wat"
  grep -Fq 'i64.add' "$wat"
  grep -Fq 'i64.sub' "$wat"
  grep -Fq 'i64.gt_u' "$wat"
  grep -Fq 'f32.neg' "$wat"
  grep -Fq 'f32.add' "$wat"
  grep -Fq 'f64.mul' "$wat"
  grep -Fq 'call_ref' "$wat"
  grep -Fq 'ref.func' "$wat"
  grep -Fq 'declare func' "$wat"
  grep -Fq '(field funcref)' "$wat"
  grep -Fq 'i32.const -2147483648' "$wat"
  test "$(grep -Fc 'if (result i32)' "$wat")" -ge 2
  grep -Fq 'return' "$wat"
  grep -Fq 'unreachable' "$wat"
  grep -Fq 'loop' "$wat"
  grep -Fq 'br 2' "$wat"
  grep -Fq 'br 1' "$wat"
  grep -Fq 'i32.const 3' "$wat"
  test "$(grep -Fc 'i32.add' "$wat")" -ge 2
}

build_compiler a
if (( cold_check )); then
  build_compiler b
else
  cp "$work/a/compiler.wasm" "$work/b/compiler.wasm"
fi
cmp "$work/a/compiler.wasm" "$work/b/compiler.wasm"
write_request a
if (( cold_check )); then
  write_request b
else
  cp "$work/a/request.bin" "$work/b/request.bin"
fi
run_compiler a
if (( cold_check )); then
  run_compiler b
else
  cp "$work/a/output.wasm" "$work/b/output.wasm"
fi
cmp "$work/a/output.wasm" "$work/b/output.wasm"

cp "$work/a/compiler.wasm" "$work/reject-fingerprint/compiler.wasm"
cp "$work/a/request.bin" "$work/reject-fingerprint/request.bin"
python3 - "$work/reject-fingerprint/request.bin" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
data = bytearray(path.read_bytes())
data[-1] ^= 1
path.write_bytes(data)
PY
accepted_output_sha=$(sha256sum "$work/a/output.wasm" | cut -d' ' -f1)
if self_host_run_node_facet \
  "$work/reject-fingerprint/compiler.wasm" \
  "$work/reject-fingerprint/request.bin"; then
  echo "self-host smoke accepted a mismatched compiler fingerprint" >&2
  exit 1
fi
test "$(sha256sum "$work/a/output.wasm" | cut -d' ' -f1)" = "$accepted_output_sha"

cp "$work/a/compiler.wasm" "$work/reject-count/compiler.wasm"
cp "$work/a/request.bin" "$work/reject-count/request.bin"
python3 - "$work/reject-count/request.bin" <<'PY'
from pathlib import Path
import struct
import sys
path = Path(sys.argv[1])
data = bytearray(path.read_bytes())
offset = 20
output_length = struct.unpack_from("<I", data, offset)[0]
offset += 4 + output_length
root_length = struct.unpack_from("<I", data, offset)[0]
offset += 4 + root_length
struct.pack_into("<I", data, offset, 0xFFFFFFFF)
path.write_bytes(data)
PY
if self_host_run_node_facet \
  "$work/reject-count/compiler.wasm" \
  "$work/reject-count/request.bin"; then
  echo "self-host smoke accepted an unbounded module count" >&2
  exit 1
fi
test "$(sha256sum "$work/a/output.wasm" | cut -d' ' -f1)" = "$accepted_output_sha"

compiler_sha=$(sha256sum "$work/a/compiler.wasm" | cut -d' ' -f1)
output_sha=$(sha256sum "$work/a/output.wasm" | cut -d' ' -f1)
echo "self-host source-request smoke passed"
echo "compiler sha256: $compiler_sha"
echo "output sha256: $output_sha"
