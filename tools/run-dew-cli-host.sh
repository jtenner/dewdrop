#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
target_dir="${DEW_HOST_TARGET_DIR:-$root/_build}"
case "$target_dir" in
  /*) ;;
  *) target_dir="$root/$target_dir" ;;
esac
target=js
for argument in "$@"; do
  case "$argument" in
    --compile-request|--link-wasm)
      target=wasm-gc
      break
      ;;
  esac
done
cd "$root"
if [[ "$target" == wasm-gc ]]; then
  moon run --target-dir "$target_dir" --target wasm-gc --release -j 8 \
    --build-only src/dew_cli >/dev/null
  exec moonrun --stack-size 65500 \
    "$target_dir/wasm-gc/release/build/jtenner/dewdrop/dew_cli/dew_cli.wasm" \
    -- "$@"
fi
moon run --target-dir "$target_dir" --target js --release -j 8 \
  --build-only src/dew_cli >/dev/null
exec node --stack-size=65500 --enable-source-maps \
  "$target_dir/js/release/build/jtenner/dewdrop/dew_cli/dew_cli.js" "$@"
