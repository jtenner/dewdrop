#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .tmp
python3 tools/generate_facet_adapter.py --check
tools/dew build \
  --link-wasm facet fixtures/facet/facet-adapter.wasm \
  -o .tmp/facet-smoke.wasm \
  fixtures/facet/facet-smoke.dew
wasm-tools validate --features all .tmp/facet-smoke.wasm
wasm-tools print .tmp/facet-smoke.wasm > .tmp/facet-smoke.wat
for name in \
  abi_version \
  fs_preopen_get \
  fd_read_array_i8 \
  fd_write_array_i8 \
  path_open_array_i8 \
  path_stat_array_i8 \
  path_create_dir_array_i8 \
  path_remove_array_i8 \
  path_rename_array_i8 \
  args_count \
  args_len_i8 \
  args_read_into_array_i8 \
  env_count \
  env_len_i8 \
  env_read_into_array_i8 \
  stdio_stdout \
  stdio_stderr
do
  grep -Fq "(import \"facet\" \"$name\"" .tmp/facet-smoke.wat
 done
if grep -Eq 'link:facet|wpsi|fs_scratch|args_get|env_get|sysstr' .tmp/facet-smoke.wat; then
  echo "Facet smoke module retained a legacy import" >&2
  exit 1
fi
echo "Facet bindings passed"
