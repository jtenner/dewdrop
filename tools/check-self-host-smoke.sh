#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

root=$PWD
work=$root/.tmp/self-host-smoke

tools/starshine-ffi.sh build
python3 tools/generate_starshine_ffi_consumer.py --check
parser_sources=(
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
  self_host/compiler/semantic_module_initialization.dew
  self_host/compiler/semantic_body_flow.dew
)

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
  self_host/compiler/semantic_impl_index.dew \
  self_host/compiler/semantic_impl_index_test.dew \
  self_host/compiler/semantic_trait_evidence.dew \
  self_host/compiler/semantic_trait_evidence_test.dew \
  self_host/compiler/semantic_body_evidence.dew \
  self_host/compiler/semantic_body_evidence_test.dew \
  self_host/compiler/semantic_inference_compaction.dew \
  self_host/compiler/semantic_inference_compaction_test.dew \
  self_host/compiler/semantic_inference_merge_test.dew \
  self_host/compiler/semantic_basic_body_inference_test.dew \
  self_host/compiler/semantic_callable_selection_test.dew \
  self_host/compiler/semantic_member_selection_test.dew \
  self_host/compiler/semantic_variant_selection_test.dew \
  self_host/compiler/semantic_operator_selection_test.dew

python3 tools/check-self-host-parser.py
python3 tools/check-self-host-semantics.py

rm -rf "$work"
mkdir -p "$work/a" "$work/b" "$work/reject-fingerprint" "$work/reject-count"

sources=(
  self_host/starshine/ffi.dew
  self_host/starshine/fingerprint.dew
  "${parser_sources[@]}"
  "${semantic_sources[@]}"
  self_host/compiler/request.dew
  self_host/compiler/starshine_module.dew
  self_host/compiler/main.dew
)

build_compiler() {
  local stage=$1
  tools/dew build \
    --link-wasm starshine starshine-mb/dist/ffi/starshine-ffi.wasm \
    --no-build-cache \
    -o "$work/$stage/compiler.wasm" \
    "${sources[@]}"
  wasm-tools validate --features all "$work/$stage/compiler.wasm"
}

write_request() {
  local stage=$1
  moon run --target native --release src/self_host_smoke_fixture -- \
    "$work/$stage/request.bin" \
    starshine-mb/dist/ffi/starshine-ffi.wasm \
    self_host/starshine/fingerprint-prefix.bin \
    output.wasm
}

run_compiler() {
  local stage=$1
  NODE_NO_WARNINGS=1 node tools/run-dew-wasi.mjs \
    "$work/$stage/compiler.wasm" \
    "$work/$stage/request.bin"
  wasm-tools validate --features all "$work/$stage/output.wasm"
  wasm-tools print "$work/$stage/output.wasm" | grep -Fq 'i32.const 73'
}

build_compiler a
build_compiler b
cmp "$work/a/compiler.wasm" "$work/b/compiler.wasm"
write_request a
write_request b
run_compiler a
run_compiler b
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
if NODE_NO_WARNINGS=1 node tools/run-dew-wasi.mjs \
  "$work/reject-fingerprint/compiler.wasm" \
  "$work/reject-fingerprint/request.bin"; then
  echo "self-host smoke accepted a mismatched compiler fingerprint" >&2
  exit 1
fi
test ! -e "$work/reject-fingerprint/output.wasm"

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
if NODE_NO_WARNINGS=1 node tools/run-dew-wasi.mjs \
  "$work/reject-count/compiler.wasm" \
  "$work/reject-count/request.bin"; then
  echo "self-host smoke accepted an unbounded module count" >&2
  exit 1
fi
test ! -e "$work/reject-count/output.wasm"

compiler_sha=$(sha256sum "$work/a/compiler.wasm" | cut -d' ' -f1)
output_sha=$(sha256sum "$work/a/output.wasm" | cut -d' ' -f1)
echo "self-host source-request smoke passed"
echo "compiler sha256: $compiler_sha"
echo "output sha256: $output_sha"
