#!/usr/bin/env bash
set -uo pipefail
status=0
cd /data/workspace/wave1-item-08
export PATH=/data/workspace/tools:/data/home/.moon/bin:/usr/local/bin:/usr/bin:/bin
cleanup() {
  rm -rf _build .mooncakes .dew/cache
  find .tmp tools/dew-test -type f \( -name '*.wasm' -o -name '*harness*' \) -delete
}
trap cleanup EXIT
/usr/bin/time -v python3 tools/generate_iter_std.py --check || status=1
/usr/bin/time -v moon run --target native src/dew_test_gen -- .tmp/iter-tests.wasm dew.std dew.std std/tests/iter_adapters_test.dew std/tests/iter_adapters_test.dew || status=1
if [[ -f .tmp/iter-tests.wasm ]]; then
  /usr/bin/time -v node tools/dew-test/run.mjs --wasm .tmp/iter-tests.wasm || status=1
fi
/usr/bin/time -v moon run --target native src/module_snapshot_gen -- .tmp/iter-consumer.wasm production app.consumer consumer.dew docs/research/stdlib-wave1-08/consumer.dew fixture.callbacks provider.dew docs/research/stdlib-wave1-08/provider.dew || status=1
if [[ -f .tmp/iter-consumer.wasm ]]; then
set -e
/usr/bin/time -v wasm-tools print .tmp/iter-consumer.wasm -o .tmp/iter-consumer.wat
/usr/bin/time -v node --expose-gc docs/research/stdlib-wave1-08/check.mjs
/usr/bin/time -v python3 docs/research/stdlib-wave1-08/instrument.py
/usr/bin/time -v wasm-tools parse .tmp/iter-instrumented.wat -o .tmp/iter-instrumented.wasm
/usr/bin/time -v node docs/research/stdlib-wave1-08/allocations.mjs
fi
exit "$status"
