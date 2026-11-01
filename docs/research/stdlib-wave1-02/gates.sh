set -euo pipefail
cd /data/workspace/wave1-item-02
export PATH=/data/workspace/tools:/data/home/.moon/bin:/usr/local/bin:/usr/bin:/bin
mkdir -p .tmp
cat > .tmp/clang <<'CC'
#!/usr/bin/env bash
exec /usr/bin/clang "$@" -fbracket-depth=4096 -g0 -O0
CC
chmod +x .tmp/clang
export MOON_CC="$PWD/.tmp/clang"
trap 'rm -rf _build .mooncakes .dew/cache; rm -f .tmp/trim-consumer.dew; find .tmp -name "*.wasm" -delete' EXIT
/usr/bin/time -v python3 tools/generate_string_std.py --check
/usr/bin/time -v moon run -j 1 --target native src/dew_test_gen -- .tmp/trim.wasm dew.std dew.std std/tests/string_trim_test.dew std/tests/string_trim_test.dew
/usr/bin/time -v node tools/dew-test/run.mjs --wasm .tmp/trim.wasm
python3 docs/research/stdlib-wave1-02/bench.py
/usr/bin/time -v moon run -j 1 --target native src/module_snapshot_gen -- .tmp/trim-consumer.wasm production app.trim trim-consumer.dew .tmp/trim-consumer.dew
/usr/bin/time -v node --expose-gc docs/research/stdlib-wave1-02/bench.mjs
