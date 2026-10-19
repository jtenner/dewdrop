#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source tools/self-host-common.sh
compiler=${1:?usage: tools/test-transform-requests.sh COMPILER.wasm [node-facet|wago]}
runtime=${2:-node-facet}
work=.tmp/transform-requests
mkdir -p "$work"
for kind in local imported patterns record; do
  args=(examples/transforms/local.dew)
  if [[ "$kind" == imported ]]; then
    args=(examples/transforms/imported.dew --module example.tools examples/transforms/tools.dew)
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

for kind in bad-signature sibling-declaration host-call; do
  expected='invalid transform signature'
  if [[ "$kind" == sibling-declaration ]]; then
    expected='transform must produce one valid function body'
  elif [[ "$kind" == host-call ]]; then
    expected='compile-time calls require a direct function or enum constructor'
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
