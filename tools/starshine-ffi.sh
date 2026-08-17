#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

command="${1:-check}"
case "$command" in
  check|build|generate) ;;
  *)
    echo "usage: tools/starshine-ffi.sh [check|build|generate]" >&2
    exit 2
    ;;
esac

if ! git -C starshine-mb rev-parse --verify HEAD >/dev/null 2>&1; then
  echo "Starshine submodule is not initialized; run: git submodule update --init --recursive" >&2
  exit 1
fi

run_ffi() {
  (
    cd starshine-mb
    bun ffi "$command"
  )
}

if [[ -e starshine-mb/moon.work ]]; then
  run_ffi
else
  cleanup() {
    rm -f starshine-mb/moon.work
  }
  trap cleanup EXIT
  cat > starshine-mb/moon.work <<'EOF'
members = [
  ".",
]
EOF
  run_ffi
  cleanup
  trap - EXIT
fi
