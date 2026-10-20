#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source tools/self-host-common.sh
compiler=${1:?usage: tools/test-transform-requests.sh COMPILER.wasm [node-facet|wago]}
runtime=${2:-node-facet}
work=.tmp/transform-requests
mkdir -p "$work"
read -r -a examples <<< "${DEW_TRANSFORM_EXAMPLES-local imported patterns record methods builders collections imported_methods raw_arrays wrappers casts syntax evaluation operators callbacks flow generics defaults scalar_values signature_info signatures type_info declarations constants constant_state imported_constants repeated_imports generated_imports quotes nested_quotes syntax_tree arguments floats strings overloads nulls type_queries typed_reflection typed_repair typed_generics bytes vectors generic_queries generic_traits dynamic_traits generic_closures generic_query_api generic_float_defaults generic_selected_methods generic_selected_operators generic_trait_impl generic_trait_method_bounds generic_trait_trait_arguments default_references generic_function_identity generic_identity_nested generic_identity_closures generic_identity_evidence text_operations loop_guards bytecode memory memory_state packed_integers packed_storage}"
for kind in "${examples[@]}"; do
  args=("examples/transforms/$kind.dew")
  if [[ "$kind" == imported || "$kind" == imported_methods || "$kind" == repeated_imports || "$kind" == generated_imports ]]; then
    args=("examples/transforms/$kind.dew" --module example.tools examples/transforms/tools.dew)
  elif [[ "$kind" == imported_constants ]]; then
    args=("examples/transforms/$kind.dew" --module example.constant_tools examples/transforms/constant_tools.dew)
  elif [[ "$kind" == patterns ]]; then
    args=(examples/transforms/patterns.dew)
  elif [[ "$kind" == record ]]; then
    args=(examples/transforms/record.dew)
  fi
  self_host_measure "transform request: $kind" \
    moon run --target native --release src/self_host_bootstrap_fixture -- \
      "$work/$kind.bin" starshine-mb/dist/ffi/starshine-ffi.wasm \
      self_host/starshine/fingerprint-prefix.bin "$work/$kind.wasm" \
      example.app "${args[@]}"
  self_host_measure "transform compilation ($runtime): $kind" \
    self_host_run_cached_failure "$runtime" "$compiler" "$work/$kind.bin"
  self_host_measure "transform output validation: $kind" \
    wasm-tools validate --features all "$work/$kind.wasm"
  self_host_measure "transform output execution: $kind" \
    node -e 'const fs=require("fs"); WebAssembly.instantiate(fs.readFileSync(process.argv[1])).then(({instance})=>{instance.exports.__dew_init?.(); const value=instance.exports.main(); if(value!==42) throw Error(`expected 42, got ${value}`); console.log(`main() = ${value}`)})' "$work/$kind.wasm"
done

cat > "$work/bad-signature.dew" <<'DEW'
import dewdrop.ast as @ast
transform fn wrong(node: @ast.FnNode, ctx: I32) -> @ast.FnNode {
  node
}
#wrong
pub fn main() -> I32 {
  0i32
}
DEW
cat > "$work/sibling-declaration.dew" <<'DEW'
import dewdrop.ast as @ast
import dewdrop.transform as @transform
transform fn wrong(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {
  @ast.with_body(node, @ast.source("1i32\n}\nfn injected() -> I32 {\n2i32"))
}
#wrong
pub fn main() -> I32 {
  0i32
}
DEW

cat > "$work/host-call.dew" <<'DEW'
import dewdrop.ast as @ast
import dewdrop.transform as @transform
fn ping() -> I32 {
  42i32
}
foreign import "env" as Host {
  pub fn ping() -> I32 = "ping"
}
transform fn wrong(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {
  @ast.with_body(node, @ast.integer(Host.ping()))
}
#wrong
pub fn main() -> I32 {
  0i32
}
DEW

for kind in array-bounds array-budget invalid-field; do
  expression='wasm_array_get(wasm_array_new_default::<I32>(1u32), 1u32)'
  if [[ "$kind" == array-budget ]]; then
    expression='wasm_array_get(wasm_array_new_default::<I32>(4294967295u32), 0u32)'
  elif [[ "$kind" == invalid-field ]]; then
    expression='0i32'
  fi
  body="node.with_body(@ast.integer($expression))"
  if [[ "$kind" == invalid-field ]]; then
    body='node.with_body(@ast.name("value").field("x) + 1"))'
  fi
  cat > "$work/$kind.dew" <<DEW
import dewdrop.ast as @ast
import dewdrop.transform as @transform
open dew.std.wasm.intrinsics
transform fn wrong(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {
  $body
}
#wrong
pub fn main() -> I32 {
  0i32
}
DEW
done

cat > "$work/float-default.dew" <<'DEW'
import dewdrop.ast as @ast
import dewdrop.transform as @transform
open dew.std.wasm.intrinsics
fn first<t>() -> Option<t> {
  Some(wasm_array_get(wasm_array_new_default::<t>(1u32), 0u32))
}
transform fn wrong(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {
  let value = match first::<F32>() {
    Some(value) => value
    None => 1.0f32
  }
  node.with_body(@ast.integer(wasm_unsafe_bitcast::<F32, I32>(-value)))
}
#wrong
pub fn main() -> I32 {
  0i32
}
DEW

cat > "$work/float-cast.dew" <<'DEW'
import dewdrop.ast as @ast
import dewdrop.transform as @transform
open dew.std.wasm.intrinsics
transform fn wrong(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {
  let value = wasm_unsafe_bitcast::<I32, F32>(1065353216i32)
  node.with_body(@ast.integer(wasm_unsafe_bitcast::<F32, I32>(-value)))
}
#wrong
pub fn main() -> I32 {
  0i32
}
DEW

cat > "$work/boxed-float.dew" <<'DEW'
import dewdrop.ast as @ast
import dewdrop.transform as @transform
open dew.std.wasm.intrinsics
fn boxed_cast<a, b>(value: a) -> Option<b> {
  Some(wasm_unsafe_bitcast::<a, b>(value))
}
transform fn wrong(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {
  let value = match boxed_cast::<I32, F32>(1065353216i32) {
    Some(value) => value
    None => 0.0f32
  }
  node.with_body(@ast.integer(wasm_unsafe_bitcast::<F32, I32>(-value)))
}
#wrong
pub fn main() -> I32 {
  0i32
}
DEW

cat > "$work/float-field.dew" <<'DEW'
import dewdrop.ast as @ast
import dewdrop.transform as @transform
open dew.std.wasm.intrinsics
struct Box<t> {
  value: t
}
fn boxed<a, b>(value: a) -> Box<b> {
  Box::{
    value: wasm_unsafe_bitcast::<a, b>(value)
  }
}
transform fn wrong(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {
  let data = boxed::<I32, F32>(1065353216i32)
  node.with_body(@ast.integer(wasm_unsafe_bitcast::<F32, I32>(data.value + data.value)))
}
#wrong
pub fn main() -> I32 {
  0i32
}
DEW

cat > "$work/declaration-kind.dew" <<'DEW'
import dewdrop.ast as @ast
import dewdrop.transform as @transform
transform fn wrong(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {
  ctx.add_type("fn generated() -> I32 {\n 42i32\n}")
  node
}
#wrong
pub fn main() -> I32 {
  42i32
}
DEW

cat > "$work/import-alias.dew" <<'DEW'
import dewdrop.ast as @ast
import dewdrop.transform as @transform
transform fn wrong(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {
  ctx.import_module("dew.std.option", "invalid.alias")
  node
}
#wrong
pub fn main() -> I32 {
  42i32
}
DEW

cat > "$work/mutable-global.dew" <<'DEW'
import dewdrop.ast as @ast
import dewdrop.transform as @transform
let mut answer = 42i32
transform fn wrong(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {
  node.with_body(@ast.integer(answer))
}
#wrong
pub fn main() -> I32 {
  0i32
}
DEW

cat > "$work/foo-u32.dew" <<'DEW'
import dewdrop.ast as @ast
import dewdrop.transform as @transform
struct Foo<t> {}
builtin absent<t>() -> Foo<t> = "ref_null"
transform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {
 let _ = absent::<U32>()
 node.with_body(@ast.integer(42i32))
}
#replace
pub fn main() -> I32 {
 0i32
}
DEW

cat > "$work/foo-handle.dew" <<'DEW'
import dewdrop.ast as @ast
import dewdrop.transform as @transform
foreign type Handle
struct Foo<t> {}
builtin absent<t>() -> Foo<t> = "ref_null"
transform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {
 let _ = absent::<Handle>()
 node.with_body(@ast.integer(42i32))
}
#replace
pub fn main() -> I32 {
 0i32
}
DEW

cat > "$work/bad-is-null-result.dew" <<'DEW'
import dewdrop.ast as @ast
import dewdrop.transform as @transform
builtin wrong(value: String) -> String = "ref_is_null"
transform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {
 let _ = wrong("x")
 node.with_body(@ast.integer(42i32))
}
#replace
pub fn main() -> I32 {
 0i32
}
DEW

cat > "$work/bad-is-null-unit.dew" <<'DEW'
import dewdrop.ast as @ast
import dewdrop.transform as @transform
builtin wrong(value: String) -> Unit = "ref_is_null"
transform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {
 let _ = wrong("x")
 node.with_body(@ast.integer(42i32))
}
#replace
pub fn main() -> I32 {
 0i32
}
DEW

cat > "$work/generic-hidden-result.dew" <<'DEW'
import dewdrop.ast as @ast
import dewdrop.transform as @transform
builtin hidden<t>(a: I32, b: I32) -> t = "i32.add"
fn trigger<t>() -> Unit {
  let _ = hidden::<t>(1i32, 2i32)
}
transform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {
  trigger::<String>()
  node.with_body(@ast.integer(42i32))
}
#replace
pub fn main() -> I32 {
  0i32
}
DEW

read -r -a rejections <<< "${DEW_TRANSFORM_REJECTIONS-bad-signature sibling-declaration host-call array-bounds array-budget invalid-field float-default float-cast boxed-float float-field declaration-kind import-alias mutable-global foo-u32 foo-handle bad-is-null-result bad-is-null-unit generic-hidden-result}"
for kind in "${rejections[@]}"; do
  expected='invalid transform signature'
  if [[ "$kind" == foo-u32 || "$kind" == foo-handle ]]; then
    expected='null reference'
  elif [[ "$kind" == bad-is-null-result || "$kind" == bad-is-null-unit ]]; then
    expected='result carrier'
  fi
  if [[ "$kind" == generic-hidden-result ]]; then
    expected='generic intrinsic result needs a concrete checked carrier'
  elif [[ "$kind" == sibling-declaration ]]; then
    expected='transform must produce one valid function body'
  elif [[ "$kind" == host-call ]]; then
    expected='checked call requires unsupported compile-time dispatch'
  elif [[ "$kind" == array-bounds ]]; then
    expected='array index out of bounds'
  elif [[ "$kind" == array-budget ]]; then
    expected='allocation limit exceeded'
  elif [[ "$kind" == invalid-field ]]; then
    expected='invalid generated field name'
  elif [[ "$kind" == mutable-global ]]; then
    expected='mutable module bindings'
  elif [[ "$kind" == declaration-kind ]]; then
    expected='expected one valid generated declaration'
  elif [[ "$kind" == import-alias ]]; then
    expected='invalid generated import'
  elif [[ "$kind" == float-default || "$kind" == float-cast || "$kind" == boxed-float || "$kind" == float-field ]]; then
    expected='Wasm integer intrinsic requires an integer|floating-point value has an incompatible checked carrier|Wasm unsafe cast requires the same scalar carrier'
  fi
  rm -f "$work/$kind.wasm"
  self_host_measure "transform rejection request: $kind" \
    moon run --target native --release src/self_host_bootstrap_fixture -- \
      "$work/$kind.bin" starshine-mb/dist/ffi/starshine-ffi.wasm \
      self_host/starshine/fingerprint-prefix.bin "$work/$kind.wasm" \
      example.app "$work/$kind.dew"
  if self_host_measure "transform rejection ($runtime): $kind" \
    self_host_run_cached_failure "$runtime" "$compiler" "$work/$kind.bin" \
    > "$work/$kind.log" 2>&1; then
    cat "$work/$kind.log"
    echo "expected transform rejection: $kind" >&2
    exit 1
  fi
  cat "$work/$kind.log"
  if ! rg -- "$expected" "$work/$kind.log" || [[ -e "$work/$kind.wasm" ]]; then
    echo "transform rejection lacked its diagnostic or wrote output: $kind" >&2
    exit 1
  fi
done
