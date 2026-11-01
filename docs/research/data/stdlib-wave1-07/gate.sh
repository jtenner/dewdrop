set -uo pipefail
export PATH=/data/workspace/tools:/data/home/.moon/bin:/usr/local/bin:/usr/bin:/bin
export MOON_CC="$PWD/.tmp/cc"
mkdir -p .tmp/logs
trap 'rm -rf _build .mooncakes .dew/cache; find .tmp -type f \( -name "*.wasm" -o -name "*.wat" -o -name "*.harness.mjs" \) -delete' EXIT
status=0
run() {
 name=$1; shift
 /usr/bin/time -p "$@" > ".tmp/logs/$name.log" 2>&1
 code=$?
 cat ".tmp/logs/$name.log"
 echo "EXIT $name $code"
 if [ "$code" -ne 0 ]; then status=1; fi
}
run generator python3 tools/generate_sha256_std.py --check
run stream-compile moon run --target native -j 1 src/dew_test_gen -- .tmp/stream.wasm dew.std dew.std std/tests/sha256_stream_test.dew std/tests/sha256_stream_test.dew
if [ -f .tmp/stream.wasm ]; then run stream node tools/dew-test/run.mjs --wasm .tmp/stream.wasm; fi
run oneshot-compile moon run --target native -j 1 src/dew_test_gen -- .tmp/oneshot.wasm dew.std dew.std std/tests/08_sha256_test.dew std/tests/08_sha256_test.dew
if [ -f .tmp/oneshot.wasm ]; then run oneshot node tools/dew-test/run.mjs --wasm .tmp/oneshot.wasm; fi
run consumer moon run --target native -j 1 src/dew_cli -- build .tmp/consumer.dew -o .tmp/consumer.wasm
if [ -f .tmp/consumer.wasm ]; then run measure node --expose-gc .tmp/measure.mjs; fi
exit "$status"
