#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

mode="full"
if [[ ${1-} == "--quick" ]]; then
  mode="quick"
  shift
fi
if [[ $# -ne 0 ]]; then
  echo "usage: tools/check.sh [--quick]" >&2
  exit 2
fi

echo "== formatting =="
moon fmt --check

tools/check-generated.sh
tools/check-moon-targets.sh "$mode"
tools/check-compile-request.sh
tools/check-self-host-smoke.sh

if [[ "$mode" == quick ]]; then
  echo "quick Dew validation passed"
  exit 0
fi

tools/test-integration-native.sh
tools/test-stress-native.sh
tools/check-cli-cache-abi.sh
tools/check-suites.sh
