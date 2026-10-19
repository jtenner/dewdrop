#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source tools/self-host-common.sh
compiler=${1:?usage: tools/test-transform-requests.sh COMPILER.wasm [node-facet|wago]}
runtime=${2:-node-facet}
work=.tmp/transform-requests
mkdir -p "$work"
for kind in local imported patterns record methods builders collections imported_methods raw_arrays wrappers casts syntax evaluation operators callbacks flow generics defaults; do
  args=("examples/transforms/$kind.dew")
  if [[ "$kind" == imported || "$kind" == imported_methods ]]; then
    args=("examples/transforms/$kind.dew" --module example.tools examples/transforms/tools.dew)
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
    node -e 'const fs=require("fs"); WebAssembly.instantiate(fs.readFileSync(process.argv[1])).then(({instance})=>{const value=instance.exports.main(); if(value!==42) throw Error(`expected 42, got ${value}`); console.log(`main() = ${value}`)})' "$work/$kind.wasm"
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

for kind in bad-signature sibling-declaration host-call array-bounds array-budget invalid-field float-default float-cast; do
  expected='invalid transform signature'
  if [[ "$kind" == sibling-declaration ]]; then
    expected='transform must produce one valid function body'
  elif [[ "$kind" == host-call ]]; then
    expected='checked call requires unsupported compile-time dispatch'
  elif [[ "$kind" == array-bounds ]]; then
    expected='array index out of bounds'
  elif [[ "$kind" == array-budget ]]; then
    expected='allocation limit exceeded'
  elif [[ "$kind" == invalid-field ]]; then
    expected='invalid generated field name'
  elif [[ "$kind" == float-default || "$kind" == float-cast ]]; then
    expected='unsupported scalar type'
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
  if ! rg -F -- "$expected" "$work/$kind.log" || [[ -e "$work/$kind.wasm" ]]; then
    echo "transform rejection lacked its diagnostic or wrote output: $kind" >&2
    exit 1
  fi
done
