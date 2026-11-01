set -euo pipefail
cd /data/workspace/wave1-item-01
export PATH=/data/workspace/tools:/data/home/.moon/bin:/usr/local/bin:/usr/bin:/bin
trap 'rm -rf _build .mooncakes .dew/cache; find .tmp tools/dew-test -type f \( -name "*.wasm" -o -name "*.harness.*" \) -delete; rm -f .tmp/oracle_test.dew .tmp/consumer.dew .tmp/consumer.wat' EXIT
exec > .tmp/gates.log 2>&1
/usr/bin/time -f 'generator %e s %M KiB' python3 tools/generate_text_iteration_std.py --check
node docs/research/stdlib-wave1-01-oracle.mjs
/usr/bin/time -f 'focused %e s %M KiB' moon run --target native src/dew_test_gen -- .tmp/focused.wasm dew.std dew.std std/tests/decimal_parse_test.dew std/tests/decimal_parse_test.dew dew.std oracle_test.dew .tmp/oracle_test.dew
/usr/bin/time -f 'focused runtime %e s %M KiB' node tools/dew-test/run.mjs --wasm .tmp/focused.wasm
/usr/bin/time -f 'production %e s %M KiB' moon run --target native src/dew_cli -- build .tmp/consumer.dew -o .tmp/consumer.wasm
/usr/bin/time -f 'production wat %e s %M KiB' wasm-tools print .tmp/consumer.wasm -o .tmp/consumer.wat
node --expose-gc docs/research/stdlib-wave1-01-bench.mjs
