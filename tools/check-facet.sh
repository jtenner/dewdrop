#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .tmp
python3 tools/generate_facet_bindings.py --check
python3 tools/generate_facet_adapter.py --check

obsolete=(
  std/fs/facet.dew
  std/process/facet.dew
  std/facet/fs/sync.dew
  std/facet/net/dns.dew
)
for path in "${obsolete[@]}"; do
  if [[ -e "$path" ]]; then
    echo "obsolete Facet module remains: $path" >&2
    exit 1
  fi
done

# Reach every public Facet namespace and retain every canonical Facet 0.1 import.
tools/dew build \
  --link-wasm facet fixtures/facet/facet-adapter.wasm \
  -o .tmp/facet-import-smoke.wasm \
  fixtures/facet/facet-import-smoke.dew
wasm-tools validate --features all .tmp/facet-import-smoke.wasm
wasm-tools print .tmp/facet-import-smoke.wasm > .tmp/facet-import-smoke.wat
PYTHONPATH=tools python3 - <<'PY'
import re
from pathlib import Path

from generate_facet_bindings import canonical_imports

wat = Path(".tmp/facet-import-smoke.wat").read_text(encoding="utf-8")
actual = re.findall(r'\(import "facet" "([^"]+)"', wat)
expected = [item.name for item in canonical_imports()]
if len(actual) != len(expected) or set(actual) != set(expected):
    missing = sorted(set(expected) - set(actual))
    extra = sorted(set(actual) - set(expected))
    raise SystemExit(
        f"Facet smoke inventory differs; count={len(actual)} missing={missing} extra={extra}"
    )
PY
if grep -Eq 'link:facet|wpsi|fs_scratch|args_get|env_get|sysstr' .tmp/facet-import-smoke.wat; then
  echo "Facet smoke module retained a legacy import" >&2
  exit 1
fi
echo "Facet bindings passed with all 261 canonical imports"
