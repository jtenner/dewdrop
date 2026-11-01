set -euo pipefail
cd /data/workspace/wave1-item-10
export PATH="$PWD/.tmp/bin:/data/home/.moon/bin:/usr/local/bin:/usr/bin:/bin"
export MOON_CC="$PWD/.tmp/bin/clang"
trap 'rm -rf _build .mooncakes .dew/cache; find .tmp -name "*.wasm" -delete' EXIT
/usr/bin/time -v moon run --target native -j 1 src/dew_test_gen -- .tmp/focused.wasm dew.std dew.std std/tests/io_buffered_test.dew std/tests/io_buffered_test.dew dew.std std/tests/02_io_test.dew std/tests/02_io_test.dew
/usr/bin/time -v node tools/dew-test/run.mjs --wasm .tmp/focused.wasm
/usr/bin/time -p python3 tools/generate_io_std.py --check
/usr/bin/time -v moon run --target native -j 1 src/module_snapshot_gen -- .tmp/consumer.wasm .tmp/consumer.dew
/usr/bin/time -v env DEW_NATIVE_TEST_PACKAGES=standard_sources bash tools/test-native.sh -j 1
/usr/bin/time -v node --expose-gc .tmp/bench.mjs
