#!/usr/bin/env bash
set -uo pipefail
cd /data/workspace/wave1-final-fixtures
D="$PWD/docs/research/data/stdlib-wave1-final-fixtures"
export PATH="$D/native-tools:/data/workspace/tools:/data/home/.moon/bin:/usr/local/bin:/usr/bin:/bin"
export MOON_CC="$D/native-tools/cc"
cleanup() {
 python3 - <<'PY'
from pathlib import Path
import shutil
for p in ['_build','.mooncakes','.dew/cache','tools/module-snapshots/__pycache__']:shutil.rmtree(p,ignore_errors=True)
for p in Path('tools/dew-test').glob('*.wasm'):p.unlink()
PY
}
trap cleanup EXIT
mkdir -p _build
/usr/bin/time -p python3 "$D/check-wat.py" > "$D/wat-runtime.log" 2>&1
wat=$?
printf 'wat %s\n' "$wat" > "$D/status"
/usr/bin/time -p bash tools/module-snapshots/run.sh --jobs 2 --target-dir _build > "$D/after.log" 2>&1
snap=$?
printf 'snapshots %s\n' "$snap" >> "$D/status"
exit "$((wat || snap))"
