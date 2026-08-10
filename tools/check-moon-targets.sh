#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

mode="${1:-full}"
if [[ "$mode" != quick && "$mode" != full ]]; then echo "usage: tools/check-moon-targets.sh [quick|full]" >&2; exit 2; fi

if [[ $mode == "quick" ]]; then
  echo "== Dew tests: native =="
  moon test --target native \
    src/tokenizer src/parser src/standard_sources src/semantic src/backend \
    src/standard_loader src/compiler_driver
else
  targets=(native wasm-gc js wasm)
  processors=$(getconf _NPROCESSORS_ONLN 2>/dev/null || printf '1')
  if [[ ! $processors =~ ^[1-9][0-9]*$ ]]; then
    processors=1
  fi
  target_jobs=${DEW_CHECK_TARGET_JOBS:-$processors}
  if [[ ! $target_jobs =~ ^[1-9][0-9]*$ ]]; then
    echo "DEW_CHECK_TARGET_JOBS must be a positive integer" >&2
    exit 2
  fi
  if ((target_jobs > ${#targets[@]})); then
    target_jobs=${#targets[@]}
  fi
  test_root=.tmp/dew-check-moon-targets
  mkdir -p "$test_root/logs"
  node_stack_size=${DEW_CHECK_NODE_STACK_SIZE:-8192}
  if [[ ! $node_stack_size =~ ^[1-9][0-9]*$ ]]; then
    echo "DEW_CHECK_NODE_STACK_SIZE must be a positive integer" >&2
    exit 2
  fi
  node_binary=$(command -v node)
  node_stack_bin="$test_root/node-stack-bin"
  mkdir -p "$node_stack_bin"
  printf '#!/usr/bin/env bash\nexec %q --stack-size=%q "$@"\n' \
    "$node_binary" "$node_stack_size" > "$node_stack_bin/node"
  chmod +x "$node_stack_bin/node"
  echo "== Dew tests: native, wasm-gc, js, wasm ($target_jobs concurrent targets) =="
  test_failure=0
  for ((start = 0; start < ${#targets[@]}; start += target_jobs)); do
    pids=()
    for ((index = start; index < start + target_jobs && index < ${#targets[@]}; index++)); do
      target=${targets[index]}
      if [[ $target == js ]]; then
        PATH="$PWD/$node_stack_bin:$PATH" moon test --frozen \
          --target "$target" \
          --target-dir "$test_root/$target" \
          src/tokenizer src/parser src/standard_sources src/semantic src/backend \
          src/standard_loader src/compiler_driver \
          > "$test_root/logs/$target.txt" 2>&1 &
      else
        moon test --frozen \
          --target "$target" \
          --target-dir "$test_root/$target" \
          src/tokenizer src/parser src/standard_sources src/semantic src/backend \
          src/standard_loader src/compiler_driver \
          > "$test_root/logs/$target.txt" 2>&1 &
      fi
      pids+=("$!")
    done
    for pid in "${pids[@]}"; do
      if ! wait "$pid"; then
        test_failure=1
      fi
    done
  done
  for target in "${targets[@]}"; do
    echo "-- $target --"
    cat "$test_root/logs/$target.txt"
  done
  if ((test_failure != 0)); then
    exit 1
  fi
fi

