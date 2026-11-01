set -euo pipefail
cd /data/workspace/wave1-item-08
export PATH=/data/workspace/tools:/data/home/.moon/bin:/usr/local/bin:/usr/bin:/bin
trap 'rm -rf _build .mooncakes .dew/cache; find .tmp tools/dew-test -type f \( -name "*.wasm" -o -name "*harness*" \) -delete' EXIT
/usr/bin/time -v python3 tools/generate_iter_std.py --check
/usr/bin/time -v wasm-tools parse .tmp/iter-consumer.wat -o .tmp/iter-consumer.wasm
/usr/bin/time -v node --expose-gc docs/research/stdlib-wave1-08/check.mjs
/usr/bin/time -v python3 docs/research/stdlib-wave1-08/instrument.py
/usr/bin/time -v wasm-tools parse .tmp/iter-instrumented.wat -o .tmp/iter-instrumented.wasm
/usr/bin/time -v node docs/research/stdlib-wave1-08/allocations.mjs
