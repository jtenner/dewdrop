set -euo pipefail
cd /data/workspace/wave1-item-03
mkdir -p .tmp/bin
cat > .tmp/bin/clang <<'WRAPPER'
#!/bin/sh
exec /usr/bin/clang "$@" -fbracket-depth=4096 -g0 -O0
WRAPPER
chmod +x .tmp/bin/clang
ln -sf /usr/bin/ar .tmp/bin/llvm-ar
export PATH="$PWD/.tmp/bin:/data/home/.moon/bin:/usr/local/bin:/usr/bin:/bin"
export CC="$PWD/.tmp/bin/clang"
export MOON_CC="$PWD/.tmp/bin/clang"
cleanup() {
  rm -rf _build .mooncakes .dew/cache
  rm -f .tmp/prefix-*.dew .tmp/dense-*.dew
  find .tmp tools/dew-test -type f \( -name '*.wasm' -o -name '*.wat' \) -delete
}
trap cleanup EXIT
exec > docs/research/data/stdlib-wave1-03/gate.log 2>&1
python3 tools/check-moon-toolchain.py
/usr/bin/time -f 'focused compile: %e s; max RSS %M KiB' moon run --target native -j1 src/dew_test_gen -- .tmp/split.wasm dew.std dew.std std/tests/text_split_test.dew std/tests/text_split_test.dew
/usr/bin/time -f 'focused runtime: %e s; max RSS %M KiB' node tools/dew-test/run.mjs --wasm .tmp/split.wasm
/usr/bin/time -f 'generator check: %e s; max RSS %M KiB' python3 tools/generate_text_iteration_std.py --check
/usr/bin/time -f 'production compile: %e s; max RSS %M KiB' moon run --target native -j1 src/module_snapshot_gen -- .tmp/consumer.wasm production app.split consumer.dew docs/research/data/stdlib-wave1-03/consumer.dew
/usr/bin/time -f 'production runtime: %e s; max RSS %M KiB' node tools/module-snapshots/run-main.mjs .tmp/consumer.wasm
/usr/bin/time -f 'benchmark gate: %e s; max RSS %M KiB' python3 docs/research/data/stdlib-wave1-03/benchmark.py
rm -f .tmp/prefix-*.dew .tmp/dense-*.dew
