#!/usr/bin/env bash

self_host_measure() {
  local label=$1
  shift
  local start_ns end_ns elapsed_ms status
  start_ns=$(date +%s%N)
  status=0
  "$@" || status=$?
  end_ns=$(date +%s%N)
  elapsed_ms=$(( (end_ns - start_ns) / 1000000 ))
  printf 'self-host timing: %s: %d.%03d seconds\n' \
    "$label" "$((elapsed_ms / 1000))" "$((elapsed_ms % 1000))" >&2
  if (( elapsed_ms > 30000 )); then
    printf 'self-host performance bug: %s exceeded 30 seconds\n' "$label" >&2
  fi
  return "$status"
}

self_host_ensure_starshine_ffi() {
  local provider=starshine-mb/dist/ffi/starshine-ffi.wasm
  local stale=0
  if [[ ! -f "$provider" ]]; then
    stale=1
  elif find \
    starshine-mb/src \
    starshine-mb/ffi/src \
    starshine-mb/scripts \
    -type f \
    \( -name '*.mbt' -o -name '*.json' -o -name '*.ts' -o -name '*.pkg' \) \
    -newer "$provider" \
    -print -quit | grep -q .; then
    stale=1
  elif [[ starshine-mb/moon.mod.json -nt "$provider" ]]; then
    stale=1
  fi

  if (( stale )); then
    tools/starshine-ffi.sh build
  else
    echo "self-host: reusing current Starshine FFI module"
  fi
  python3 tools/generate_starshine_ffi_consumer.py --check
}

self_host_run_wasi() {
  NODE_NO_WARNINGS=1 node --no-liftoff tools/run-dew-wasi.mjs "$@"
}

self_host_run_wasi_cached_failure() {
  local compiler=$1
  local request=$2
  if [[ ! -f "$compiler" || ! -f "$request" ]]; then
    echo "self-host: compiler or request file is missing" >&2
    return 2
  fi
  local cache_root=.tmp/self-host-cache/wasi-failures
  local key
  key=$(
    {
      sha256sum "$compiler"
      sha256sum "$request"
      printf '%s\n' node-no-liftoff-v1
    } | sha256sum | cut -d' ' -f1
  )
  local status_file=$cache_root/$key.status
  local log_file=$cache_root/$key.log
  if [[ -f "$status_file" && -f "$log_file" ]]; then
    echo "self-host: reusing unchanged failing compiler stage" >&2
    cat "$log_file" >&2
    return "$(<"$status_file")"
  fi

  mkdir -p "$cache_root"
  local temporary_log=$cache_root/$key.tmp
  local status=0
  if self_host_run_wasi "$compiler" "$request" >"$temporary_log" 2>&1; then
    cat "$temporary_log"
    rm -f "$temporary_log"
    return 0
  else
    status=$?
    cat "$temporary_log" >&2
    mv "$temporary_log" "$log_file"
    printf '%s\n' "$status" > "$status_file"
    return "$status"
  fi
}

self_host_files_digest() {
  if (( $# == 0 )); then
    printf '%s\n' empty
    return
  fi
  sha256sum "$@" | sha256sum | cut -d' ' -f1
}
