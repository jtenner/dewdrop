set -uo pipefail
cd /data/workspace/wave1-item-04
export PATH=/data/workspace/tools:/data/home/.moon/bin:/usr/local/bin:/usr/bin:/bin
export MOON_CC="$PWD/.tmp/moon-cc"
cleanup() {
 rm -rf _build .mooncakes .dew/cache
 find .tmp tools/dew-test -type f \( -name '*.wasm' -o -name '*harness*' \) -delete
}
trap cleanup EXIT
status=0
run() {
 local name="$1"; shift
 /usr/bin/time -v "$@" > ".tmp/$name.log" 2>&1
 local code=$?
 echo "$name exit=$code"
 if [ "$code" -ne 0 ]; then tail -35 ".tmp/$name.log"; status=1; fi
}
run focused-compile moon run -j 1 --target native src/dew_test_gen -- .tmp/path-tests.wasm dew.std dew.std std/tests/path_parts_test.dew std/tests/path_parts_test.dew dew.std std/tests/09_host_test.dew std/tests/09_host_test.dew
if [ -f .tmp/path-tests.wasm ]; then
 run focused-run node tools/dew-test/run.mjs --wasm .tmp/path-tests.wasm
 cat .tmp/focused-run.log
fi
run generator python3 tools/generate_host_std.py --check
run native env "DEW_NATIVE_TEST_PACKAGES=standard_sources standard_loader" bash tools/test-native.sh -j 1
run consumer-compile moon run -j 1 --target native src/dew_cli -- build .tmp/consumer.dew -o .tmp/consumer.wasm
if [ -f .tmp/consumer.wasm ]; then
 run consumer-run node -e 'const fs=require("fs"); (async()=>{const m=await WebAssembly.compile(fs.readFileSync(".tmp/consumer.wasm")); if(WebAssembly.Module.imports(m).length)throw Error("host imports"); const i=await WebAssembly.instantiate(m,{}); if(i.exports.main()!==1)throw Error("consumer result"); console.log("production consumer: 1 passed, 0 failed; no host imports")})().catch(e=>{console.error(e);process.exit(1)})'
fi
for size in 64 512 4096; do
 run "bench-$size-compile" moon run -j 1 --target native src/dew_cli -- build ".tmp/bench-$size.dew" -o ".tmp/bench-$size.wasm"
done
if [ -f .tmp/bench-4096.wasm ]; then
 run benchmark node --expose-gc docs/research/data/stdlib-wave1-04/bench.mjs
 cat .tmp/benchmark.log
fi
exit "$status"
