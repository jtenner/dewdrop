#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

mode="full"
if [[ ${1-} == "--quick" ]]; then
  mode="quick"
  shift
fi
if [[ $# -ne 0 ]]; then
  echo "usage: tools/check.sh [--quick]" >&2
  exit 2
fi

echo "== formatting =="
moon fmt --check

echo "== generated sources =="
python3 tools/generate_lane_std.py --check
python3 tools/generate_string_std.py --check
python3 tools/generate_wasi_std.py --check
python3 tools/generate_wasm_intrinsics_std.py --check
python3 tools/generate_fixed_array_std.py --check
python3 tools/generate_map_std.py --check
python3 tools/generate_set_std.py --check
python3 tools/generate_std_tests.py --check
node --test tools/dew-test/metadata.test.mjs tools/dew-abi-metadata.test.mjs
node --check tools/dew-abi-metadata.mjs
node --check tools/dew-abi.mjs
node --check tools/dew-wasm-consumer.mjs
node --check tools/wasm-metrics.mjs
python3 tools/dew_cli_test.py

targets=(native)
if [[ $mode == "full" ]]; then
  targets+=(wasm-gc js wasm)
fi
for target in "${targets[@]}"; do
  echo "== Dew tests: $target =="
  moon test --target "$target" src/tokenizer src/parser src/semantic src/backend
done

if [[ $mode == "quick" ]]; then
  echo "quick Dew validation passed"
  exit 0
fi

echo "== compiler CLI smoke =="
mkdir -p .tmp
export DEW_CACHE_DIR=.tmp/dew-check-interface-cache
rm -rf "$DEW_CACHE_DIR"
tools/dew check tests/module-snapshots/numeric/scalar.dew
tools/dew check --package-root . tests/module-snapshots/numeric/scalar.dew
rm -rf .tmp/incomplete-package-root
mkdir -p .tmp/incomplete-package-root/dew.std/std/preamble
cp std/preamble/00-builtins.dew \
  .tmp/incomplete-package-root/dew.std/std/preamble/00-builtins.dew
if tools/dew check --package-root .tmp/incomplete-package-root \
  tests/module-snapshots/numeric/scalar.dew \
  > .tmp/incomplete-package-error.txt 2>&1; then
  echo "expected incomplete dew.std package to fail closed" >&2
  exit 1
fi
grep -q 'cannot read standard source' .tmp/incomplete-package-error.txt
tools/dew check tests/module-snapshots/modules/std-wildcard-runtime.dew
tools/dew check --no-default-preamble \
  tests/module-snapshots/modules/std-wildcard-runtime.dew
tools/dew build tests/module-snapshots/numeric/scalar.dew -o .tmp/dew-std-disk.wasm
tools/dew build --bootstrap-std tests/module-snapshots/numeric/scalar.dew \
  -o .tmp/dew-std-bootstrap.wasm
cmp .tmp/dew-std-disk.wasm .tmp/dew-std-bootstrap.wasm
tools/dew build tests/module-snapshots/modules/std-wildcard-runtime.dew \
  -o .tmp/dew-std-wildcard-disk.wasm
tools/dew build --bootstrap-std \
  tests/module-snapshots/modules/std-wildcard-runtime.dew \
  -o .tmp/dew-std-wildcard-bootstrap.wasm
cmp .tmp/dew-std-wildcard-disk.wasm .tmp/dew-std-wildcard-bootstrap.wasm
rm -rf .tmp/dew-interface-cache
DEW_CACHE_DIR=.tmp/dew-interface-cache tools/dew check --cache-report \
  tests/module-snapshots/numeric/scalar.dew \
  > .tmp/dew-interface-cache-miss.txt
DEW_CACHE_DIR=.tmp/dew-interface-cache tools/dew check --cache-report \
  tests/module-snapshots/numeric/scalar.dew \
  > .tmp/dew-interface-cache-hit.txt
grep -q '^standard interface cache: miss$' .tmp/dew-interface-cache-miss.txt
grep -q '^standard interface cache: hit$' .tmp/dew-interface-cache-hit.txt
DEW_CACHE_DIR=.tmp/dew-interface-cache tools/dew build \
  tests/module-snapshots/numeric/scalar.dew -o .tmp/dew-cache-hit.wasm
cmp .tmp/dew-std-disk.wasm .tmp/dew-cache-hit.wasm
DEW_CACHE_DIR=.tmp/dew-interface-cache tools/dew check \
  --no-interface-cache --cache-report \
  tests/module-snapshots/numeric/scalar.dew \
  > .tmp/dew-interface-cache-disabled.txt
grep -q '^standard interface cache: disabled$' \
  .tmp/dew-interface-cache-disabled.txt
cache_file=$(find .tmp/dew-interface-cache/interfaces -type f | head -n 1)
printf 'corrupt' > "$cache_file"
if DEW_CACHE_DIR=.tmp/dew-interface-cache tools/dew check \
  tests/module-snapshots/numeric/scalar.dew \
  > .tmp/dew-interface-cache-corrupt.txt 2>&1; then
  echo "expected corrupt frozen-interface cache to fail visibly" >&2
  exit 1
fi
grep -q 'corrupt frozen-interface cache' \
  .tmp/dew-interface-cache-corrupt.txt
rm -rf .tmp/dew-interface-cache .tmp/dew-cache-package-root \
  .tmp/dew-cache-invalidation
mkdir -p .tmp/dew-cache-package-root/dew.std
cp -R std .tmp/dew-cache-package-root/dew.std/std
DEW_CACHE_DIR=.tmp/dew-cache-invalidation tools/dew check --cache-report \
  --package-root .tmp/dew-cache-package-root \
  tests/module-snapshots/numeric/scalar.dew \
  > .tmp/dew-cache-content-first.txt
printf '\n' >> .tmp/dew-cache-package-root/dew.std/std/option.dew
DEW_CACHE_DIR=.tmp/dew-cache-invalidation tools/dew check --cache-report \
  --package-root .tmp/dew-cache-package-root \
  tests/module-snapshots/numeric/scalar.dew \
  > .tmp/dew-cache-content-changed.txt
grep -q '^standard interface cache: miss$' .tmp/dew-cache-content-first.txt
grep -q '^standard interface cache: miss$' .tmp/dew-cache-content-changed.txt
test "$(find .tmp/dew-cache-invalidation/interfaces -type f | wc -l)" -eq 2
rm -rf .tmp/dew-interface-cache .tmp/dew-cache-package-root \
  .tmp/dew-cache-invalidation
tools/dew check --manifest tests/cli/multi-module/dew.json
tools/dew build \
  --manifest tests/cli/multi-module/dew.json \
  -o .tmp/dew-cli-smoke.wasm
tools/dew build --emit hir -o .tmp/dew-cli-smoke.hir \
  tests/module-snapshots/numeric/scalar.dew
tools/dew build --emit lowering -o .tmp/dew-cli-smoke.lowering \
  tests/module-snapshots/numeric/scalar.dew
tools/dew build --emit wat -o .tmp/dew-cli-smoke.wat \
  tests/module-snapshots/numeric/scalar.dew
test -s .tmp/dew-cli-smoke.hir
test -s .tmp/dew-cli-smoke.lowering
test -s .tmp/dew-cli-smoke.wat
grep -Fq '(@custom "dew.abi"' .tmp/dew-cli-smoke.wat
grep -Fq '(@custom "dew.metrics"' .tmp/dew-cli-smoke.wat
tools/dew run tests/module-snapshots/control-flow/short-circuit-runtime.dew \
  > .tmp/dew-cli-run.txt
grep -q '^control:short-circuit$' .tmp/dew-cli-run.txt
tools/dew build \
  tests/module-snapshots/generics/generic-erased-scalar-adapter-runtime.dew \
  -o .tmp/dew-abi-smoke.wasm
node tools/dew-abi.mjs .tmp/dew-abi-smoke.wasm list \
  > .tmp/dew-abi-list.json
grep -q '"export":"identity[$]dew[$]i32"' .tmp/dew-abi-list.json
node tools/dew-abi.mjs .tmp/dew-abi-smoke.wasm \
  call identity i32 i32 i32 '[42]' > .tmp/dew-abi-call.json
grep -q '"value":42' .tmp/dew-abi-call.json
node tools/wasm-metrics.mjs \
  tests/module-snapshots/generics/generic-erased-scalar-adapter-runtime.wat \
  .tmp/dew-abi-smoke.wasm \
  tests/performance-budgets/generic-erased-scalar-adapter.json \
  > .tmp/dew-generic-abi-metrics.json
wasm-tools parse \
  tests/abi-consumers/generic-v128-identity.wat \
  -o .tmp/dew-v128-consumer.wasm
node tools/dew-wasm-consumer.mjs \
  .tmp/dew-abi-smoke.wasm \
  .tmp/dew-v128-consumer.wasm \
  run i32 > .tmp/dew-v128-consumer.json
grep -q '"type":"i32","value":42' .tmp/dew-v128-consumer.json
tools/dew build \
  tests/module-snapshots/functions/generic-structural-callback-runtime.dew \
  -o .tmp/dew-callback-wrapper-budget.wasm
node tools/wasm-metrics.mjs \
  tests/module-snapshots/functions/generic-structural-callback-runtime.wat \
  .tmp/dew-callback-wrapper-budget.wasm \
  tests/performance-budgets/generic-structural-callback-adapter.json \
  > .tmp/dew-callback-wrapper-metrics.json
tools/dew build \
  tests/module-snapshots/functions/generic-aggregate-callback-adapter-runtime.dew \
  -o .tmp/dew-aggregate-callback-budget.wasm
node tools/wasm-metrics.mjs \
  tests/module-snapshots/functions/generic-aggregate-callback-adapter-runtime.wat \
  .tmp/dew-aggregate-callback-budget.wasm \
  tests/performance-budgets/generic-aggregate-callback-adapter.json \
  > .tmp/dew-aggregate-callback-metrics.json
wasm-tools parse \
  tests/abi-consumers/generic-aggregate-callback-i32.wat \
  -o .tmp/dew-aggregate-callback-consumer.wasm
node tools/dew-wasm-consumer.mjs \
  .tmp/dew-aggregate-callback-budget.wasm \
  .tmp/dew-aggregate-callback-consumer.wasm \
  run i32 > .tmp/dew-aggregate-callback-consumer.json
grep -q '"type":"i32","value":42' \
  .tmp/dew-aggregate-callback-consumer.json
wasm-tools parse \
  tests/abi-consumers/generic-enum-callback-i32.wat \
  -o .tmp/dew-enum-callback-consumer.wasm
node tools/dew-wasm-consumer.mjs \
  .tmp/dew-aggregate-callback-budget.wasm \
  .tmp/dew-enum-callback-consumer.wasm \
  run i32 > .tmp/dew-enum-callback-consumer.json
grep -q '"type":"i32","value":42' \
  .tmp/dew-enum-callback-consumer.json
tools/dew build \
  tests/module-snapshots/generics/generic-erased-fallback-runtime.dew \
  -o .tmp/dew-eqref-provider.wasm
wasm-tools parse \
  tests/abi-consumers/generic-eqref-identity.wat \
  -o .tmp/dew-eqref-consumer.wasm
node tools/dew-wasm-consumer.mjs \
  .tmp/dew-eqref-provider.wasm \
  .tmp/dew-eqref-consumer.wasm \
  run i32 > .tmp/dew-eqref-consumer.json
grep -q '"type":"i32","value":42' .tmp/dew-eqref-consumer.json
tools/dew build \
  --manifest tests/abi-consumers/imported-package/dew.json \
  -o .tmp/dew-imported-package-provider.wasm
node tools/dew-abi.mjs \
  .tmp/dew-imported-package-provider.wasm interface \
  > .tmp/dew-imported-package-abi.json
node --input-type=module -e '
  import { readFile } from "node:fs/promises";
  const [actual, expected] = await Promise.all([
    readFile(".tmp/dew-imported-package-abi.json", "utf8").then(JSON.parse),
    readFile("tests/abi-consumers/imported-package/expected-abi.json", "utf8").then(JSON.parse),
  ]);
  if (JSON.stringify(actual) !== JSON.stringify(expected)) {
    throw new Error("imported package ABI metadata changed");
  }
'
node tools/wasm-metrics.mjs \
  tests/module-snapshots/modules/imported-generic-callback-adapter-runtime.wat \
  .tmp/dew-imported-package-provider.wasm \
  tests/performance-budgets/imported-package-callback-adapter.json \
  > .tmp/dew-imported-package-metrics.json
node tools/dew-wasm-consumer.mjs \
  .tmp/dew-imported-package-provider.wasm \
  .tmp/dew-aggregate-callback-consumer.wasm \
  run i32 \
  fixture.main \
  64613b06a3d3e22a2949617ad72d8689b85d6bd37ccb282726f876a820b8c7f3 \
  > .tmp/dew-imported-package-consumer.json
if node tools/dew-wasm-consumer.mjs \
  .tmp/dew-imported-package-provider.wasm \
  .tmp/dew-aggregate-callback-consumer.wasm \
  run i32 \
  fixture.main \
  0000000000000000000000000000000000000000000000000000000000000000 \
  > .tmp/dew-incompatible-package-consumer.txt 2>&1; then
  echo "expected incompatible package interface to fail visibly" >&2
  exit 1
fi
grep -q 'interface fingerprint mismatch for fixture.main' \
  .tmp/dew-incompatible-package-consumer.txt
grep -q '"type":"i32","value":42' \
  .tmp/dew-imported-package-consumer.json
tools/dew build \
  tests/module-snapshots/generics/generic-enum-adapter-runtime.dew \
  -o .tmp/dew-enum-adapter-budget.wasm
node tools/wasm-metrics.mjs \
  tests/module-snapshots/generics/generic-enum-adapter-runtime.wat \
  .tmp/dew-enum-adapter-budget.wasm \
  tests/performance-budgets/generic-enum-adapter.json \
  > .tmp/dew-enum-adapter-metrics.json
tools/dew build \
  tests/module-snapshots/generics/generic-cyclic-aggregate-adapter-runtime.dew \
  -o .tmp/dew-cyclic-adapter-budget.wasm
node tools/wasm-metrics.mjs \
  tests/module-snapshots/generics/generic-cyclic-aggregate-adapter-runtime.wat \
  .tmp/dew-cyclic-adapter-budget.wasm \
  tests/performance-budgets/generic-cyclic-aggregate-adapter.json \
  > .tmp/dew-cyclic-adapter-metrics.json
tools/dew build \
  tests/module-snapshots/generics/generic-nested-aggregate-adapter-runtime.dew \
  -o .tmp/dew-nested-aggregate-budget.wasm
node tools/wasm-metrics.mjs \
  tests/module-snapshots/generics/generic-nested-aggregate-adapter-runtime.wat \
  .tmp/dew-nested-aggregate-budget.wasm \
  tests/performance-budgets/generic-nested-aggregate-adapter.json \
  > .tmp/dew-nested-aggregate-metrics.json
tools/dew build \
  tests/module-snapshots/functions/mutable-local-runtime.dew \
  -o .tmp/dew-mutable-cell-budget.wasm
node tools/wasm-metrics.mjs \
  tests/module-snapshots/functions/mutable-local-runtime.wat \
  .tmp/dew-mutable-cell-budget.wasm \
  tests/performance-budgets/mutable-capture-cells.json \
  > .tmp/dew-mutable-cell-metrics.json
tools/dew build \
  tests/module-snapshots/functions/generic-function-specialization-runtime.dew \
  -o .tmp/dew-materialized-specialization-budget.wasm
node tools/wasm-metrics.mjs \
  tests/module-snapshots/functions/generic-function-specialization-runtime.wat \
  .tmp/dew-materialized-specialization-budget.wasm \
  tests/performance-budgets/generic-materialized-specializations.json \
  > .tmp/dew-materialized-specialization-metrics.json
tools/dew build \
  tests/module-snapshots/functions/closure-directization-runtime.dew \
  -o .tmp/dew-closure-directization-budget.wasm
node tools/wasm-metrics.mjs \
  tests/module-snapshots/functions/closure-directization-runtime.wat \
  .tmp/dew-closure-directization-budget.wasm \
  tests/performance-budgets/closure-directization.json \
  > .tmp/dew-closure-directization-metrics.json
node --input-type=module -e '
  import { readFile } from "node:fs/promises";
  const bytes = await readFile(".tmp/dew-cli-smoke.wasm");
  const module = await WebAssembly.compile(bytes);
  const abiSections = WebAssembly.Module.customSections(module, "dew.abi");
  if (abiSections.length !== 1) {
    throw new Error("production binary lacks one dew.abi section");
  }
  const testSections = WebAssembly.Module.customSections(module, "dew.tests");
  if (testSections.length !== 0) {
    throw new Error("production binary contains dew.tests");
  }
  const metricSections = WebAssembly.Module.customSections(module, "dew.metrics");
  if (metricSections.length !== 1) {
    throw new Error("production binary lacks one dew.metrics section");
  }
  const metrics = new Uint8Array(metricSections[0]);
  if (
    metrics.length !== 8 ||
    metrics[0] !== 0x44 ||
    metrics[1] !== 0x57 ||
    metrics[2] !== 0x4d ||
    metrics[3] !== 0x31 ||
    metrics.slice(4).some((value) => value !== 0)
  ) {
    throw new Error("production binary contains invalid static metrics");
  }
'
wasm-tools parse \
  tests/module-snapshots/functions/generic-function-specialization-runtime.wat \
  -o .tmp/dew-missing-metrics.wasm
if node tools/wasm-metrics.mjs \
  tests/module-snapshots/functions/generic-function-specialization-runtime.wat \
  .tmp/dew-missing-metrics.wasm \
  > .tmp/dew-missing-metrics.txt 2>&1; then
  echo "expected missing dew.metrics metadata to fail visibly" >&2
  exit 1
fi
grep -q 'expected exactly one dew.metrics custom section, got 0' \
  .tmp/dew-missing-metrics.txt
cat > .tmp/dew-malformed-metrics.wat <<'EOF'
(module
  (@custom "dew.metrics" "bad")
)
EOF
wasm-tools parse .tmp/dew-malformed-metrics.wat \
  -o .tmp/dew-malformed-metrics.wasm
if node tools/wasm-metrics.mjs \
  .tmp/dew-malformed-metrics.wat \
  .tmp/dew-malformed-metrics.wasm \
  > .tmp/dew-malformed-metrics.txt 2>&1; then
  echo "expected malformed dew.metrics metadata to fail visibly" >&2
  exit 1
fi
grep -q 'unsupported or malformed dew.metrics custom section' \
  .tmp/dew-malformed-metrics.txt
if tools/dew check --no-default-preamble \
  tests/cli/no-default-preamble.dew > .tmp/dew-no-preamble-error.txt; then
  echo "expected no-default-preamble source to lose implicit assert" >&2
  exit 1
fi
grep -q 'UnknownValueName' .tmp/dew-no-preamble-error.txt
tools/dew check --no-default-preamble \
  tests/cli/no-default-explicit-preamble.dew
if tools/dew check tests/module-snapshots/names/unknown-value.dew > .tmp/dew-cli-error.txt; then
  echo "expected dew check to reject an invalid source" >&2
  exit 1
fi
grep -q '^DEW_ERROR$' .tmp/dew-cli-error.txt
tools/dew test --module dew.std std/tests/core_test.dew
tools/dew test --manifest tests/cli/test-package/dew.json
tools/dew test \
  --manifest tests/cli/test-package/dew.json \
  --list \
  > .tmp/dew-manifest-tests.txt
tail -n 2 .tmp/dew-manifest-tests.txt > .tmp/dew-manifest-test-identities.txt
cat > .tmp/dew-manifest-test-identities.expected <<'EOF'
fixture.library::tests/cli/test-package/library_test.dew::library answer
fixture.main::tests/cli/test-package/main_test.dew::linked answer
EOF
cmp .tmp/dew-manifest-test-identities.expected .tmp/dew-manifest-test-identities.txt
if tools/dew test \
  --module cli.message \
  tests/cli/assertion-message_test.dew \
  > .tmp/dew-assertion-message.txt 2>&1; then
  echo "expected failing assertion fixture to fail" >&2
  exit 1
fi
grep -Fq 'assertion failed: visible assertion λ' .tmp/dew-assertion-message.txt
if grep -q 'Traceback' .tmp/dew-assertion-message.txt; then
  echo "dew test leaked a Python traceback" >&2
  exit 1
fi

echo "== Dew standard library =="
tools/dew-test/run.sh

echo "== SWAR parity =="
tools/swar-parity/run.sh

echo "== UTF parity =="
tools/utf-parity/run.sh

echo "== WASI parity =="
tools/wasi-parity/run.sh

echo "== deterministic module snapshots: Node + Wago Core 3 =="
tools/module-snapshots/run.sh

echo "full Dew validation passed"
