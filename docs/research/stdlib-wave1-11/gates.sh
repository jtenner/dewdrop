set -uo pipefail
cd /data/workspace/wave1-item-11
export PATH=/data/workspace/wave1-control:/tmp/burn-starshine-fix-tools:/data/workspace/tools:/data/home/.moon/bin:/usr/local/bin:/usr/bin:/bin
export MOON_CC="$PWD/.tmp/process-cc"
mkdir -p .tmp/logs
trap 'rm -rf _build .mooncakes .dew/cache; find .tmp -type f \( -name "*.wasm" -o -name "*.wat" \) -delete' EXIT
status=0
run() {
 name=$1; shift
 /usr/bin/time -f 'TIME %e RSS_KB %M' "$@" > ".tmp/logs/$name.log" 2>&1
 rc=$?; echo "$name status=$rc"; tail -14 ".tmp/logs/$name.log"
 if [ "$rc" != 0 ]; then status=1; fi
 return "$rc"
}
run generator python3 tools/generate_io_process_std.py --check
run identities python3 tools/generate_standard_module_identities.py --check
run focused moon run -j 1 --target native src/dew_test_gen -- .tmp/process.wasm dew.std dew.std std/tests/io_process_test.dew std/tests/io_process_test.dew && run runtime node tools/dew-test/run.mjs --wasm .tmp/process.wasm
run consumer moon run -j 1 --target native src/module_snapshot_gen -- .tmp/consumer.wasm production app.process consumer.dew docs/research/stdlib-wave1-11/consumer.dew
run large_consumer moon run -j 1 --target native src/module_snapshot_gen -- .tmp/large-consumer.wasm production app.process large-consumer.dew docs/research/stdlib-wave1-11/large-consumer.dew
run wasi moon run -j 1 --target native src/module_snapshot_gen -- .tmp/wasi.wasm production app.wasi wasi.dew docs/research/stdlib-wave1-11/wasi.dew
if [ -f .tmp/consumer.wasm ] && [ -f .tmp/wasi.wasm ]; then run production_runtime node --expose-gc docs/research/stdlib-wave1-11/runtime.mjs .tmp/consumer.wasm .tmp/wasi.wasm .tmp/large-consumer.wasm; fi
run equivalence moon test -j 1 --target native src/standard_loader/interface_bundle_cache_wbtest.mbt --filter 'bootstrap and on-disk standard providers are byte identical'
run registry env DEW_NATIVE_TEST_PACKAGES=standard_sources bash tools/test-native.sh -j 1
run integration env DEW_INTEGRATION_TEST_FILES='src/semantic/standard_preamble_wbtest.mbt src/semantic/module_system_wbtest.mbt' bash tools/test-integration-native.sh -j 1
run info moon info --target native src/standard_sources
run generated bash tools/check-generated.sh
exit "$status"
