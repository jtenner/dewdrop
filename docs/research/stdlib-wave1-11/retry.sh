set -uo pipefail
cd /data/workspace/wave1-item-11
export PATH=/data/workspace/wave1-control:/tmp/burn-starshine-fix-tools:/data/workspace/tools:/data/home/.moon/bin:/usr/local/bin:/usr/bin:/bin
export MOON_CC="$PWD/.tmp/process-cc"
trap 'rm -rf _build .mooncakes .dew/cache; find .tmp -type f \( -name "*.wasm" -o -name "*.wat" \) -delete' EXIT
/usr/bin/time -f 'TIME %e RSS_KB %M' env DEW_INTEGRATION_TEST_FILES='src/semantic/standard_preamble_wbtest.mbt src/semantic/module_system_wbtest.mbt' bash tools/test-integration-native.sh -j 1 > .tmp/logs/integration_retry.log 2>&1
rc=$?
awk '/Total tests:|self-host timing:|performance bug|TIME |failed:/' .tmp/logs/integration_retry.log | cut -c1-350
status=$rc
run() {
 name=$1; shift
 /usr/bin/time -f 'TIME %e RSS_KB %M' "$@" > ".tmp/logs/$name.log" 2>&1
 rc=$?; echo "$name status=$rc"
 if [ "$rc" != 0 ]; then status=1; fi
 return "$rc"
}
run consumer_retry moon run -j 1 --target native src/module_snapshot_gen -- .tmp/consumer.wasm production app.process consumer.dew docs/research/stdlib-wave1-11/consumer.dew
run large_consumer_retry moon run -j 1 --target native src/module_snapshot_gen -- .tmp/large-consumer.wasm production app.process large-consumer.dew docs/research/stdlib-wave1-11/large-consumer.dew
run wasi_retry moon run -j 1 --target native src/module_snapshot_gen -- .tmp/wasi.wasm production app.wasi wasi.dew docs/research/stdlib-wave1-11/wasi.dew
if [ -f .tmp/consumer.wasm ] && [ -f .tmp/wasi.wasm ] && [ -f .tmp/large-consumer.wasm ]; then
 run production_runtime_retry node --expose-gc docs/research/stdlib-wave1-11/runtime.mjs .tmp/consumer.wasm .tmp/wasi.wasm .tmp/large-consumer.wasm
fi
exit "$status"
