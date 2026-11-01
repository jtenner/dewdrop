#!/bin/bash
set -uo pipefail
cd /data/workspace/wave1-wildcard-fix
export PATH=/data/workspace/tools:/data/home/.moon/bin:$PATH
export MOON_CC="$PWD/docs/research/data/stdlib-wave1/native-tools/cc"
exec 9>/data/workspace/wave1-control/build.lock
flock -x 9 || exit $?
cleanup() { rm -rf _build .mooncakes .dew/cache .tmp/wildcard; }
trap cleanup EXIT
mkdir -p .tmp/wildcard
/usr/bin/time -p env DEW_INTEGRATION_TEST_FILES=src/semantic/program_function_type_preflight_wbtest.mbt bash tools/test-integration-native.sh -j 1 > docs/research/data/stdlib-wave1-wildcard-fix/red-focused.log 2>&1
