#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v why3 >/dev/null 2>&1; then
  echo "proofs: Why3 is not installed" >&2
  exit 1
fi
if ! command -v z3 >/dev/null 2>&1 && \
  ! command -v alt-ergo >/dev/null 2>&1 && \
  ! command -v cvc5 >/dev/null 2>&1; then
  echo "proofs: no supported solver is installed" >&2
  exit 1
fi

printf 'proofs: '
moon version | head -n 1
printf 'proofs: '
why3 --version
moon prove src/compiler_proofs
