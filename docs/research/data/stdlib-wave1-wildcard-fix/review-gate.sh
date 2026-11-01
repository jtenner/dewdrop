#!/bin/bash
set -uo pipefail
cd /data/workspace/wave1-wildcard-fix
D="$PWD/docs/research/data/stdlib-wave1-wildcard-fix"
export PATH="$D/native-tools:/data/workspace/tools:/data/home/.moon/bin:$PATH"
export MOON_CC="$PWD/docs/research/data/stdlib-wave1/native-tools/cc"
exec 9>/data/workspace/wave1-control/build.lock
flock -x 9 || exit $?
cleanup() { rm -rf _build .mooncakes .dew/cache .tmp/wildcard tools/module-snapshots/__pycache__; }
trap cleanup EXIT
mkdir -p .tmp/wildcard
/usr/bin/time -p python3 "$D/snapshots.py" > "$D/snapshot-review.log" 2>&1
