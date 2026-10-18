#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source tools/self-host-common.sh
work=.tmp/self-host-index-lookups
mkdir -p "$work"
if [[ ${DEW_SELF_HOST_REUSE_TOOLS:-0} != 1 ]]; then
  self_host_ensure_starshine_ffi
  self_host_measure 'index test generator build' \
    moon run --target native --release --build-only src/dew_test_gen
  self_host_measure 'index test linker build' \
    moon run --target native --release --build-only src/self_host_link_fixture
fi
mapfile -t sources < <(rg --files self_host/compiler -g '*.dew' -g '!main.dew' -g '!*_test.dew' | sort)
sources+=(self_host/compiler/semantic_index_lookups_test.dew)
sources+=(self_host/compiler/semantic_metadata_index_lookups_test.dew)
python3 - "$work" "${sources[@]}" <<'PY'
import hashlib, json, shutil, subprocess, sys
from pathlib import Path
work = Path(sys.argv[1])
snapshot = work / "source"
shutil.rmtree(snapshot, ignore_errors=True)
sources = [Path(path) for path in sys.argv[2:]]
sources += [Path("self_host/starshine/ffi.dew"), *sorted(Path("std").rglob("*.dew"))]
hashes = {}
for source in sources:
    target = snapshot / source
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(source, target)
    hashes[str(source)] = hashlib.sha256(target.read_bytes()).hexdigest()
tools = ["_build/native/release/build/jtenner/dewdrop/dew_test_gen/dew_test_gen.exe",
         "_build/native/release/build/jtenner/dewdrop/self_host_link_fixture/self_host_link_fixture.exe",
         "starshine-mb/dist/ffi/starshine-ffi.wasm", "fixtures/facet/facet-adapter.wasm",
         "tools/moonbit-time-provider.wat"]
record = {"checkout_commit": subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip(),
          "source_sha256": hashes, "tool_sha256": {
              path: hashlib.sha256(Path(path).read_bytes()).hexdigest() for path in tools}}
(work / "build-identity.json").write_text(json.dumps(record, indent=2) + "\n")
PY
args=("$work/tests-core.wasm" self_host.compiler self_host.compiler ffi.dew "$work/source/self_host/starshine/ffi.dew")
for source in "${sources[@]}"; do
  args+=(self_host.compiler "${source##*/}" "$work/source/$source")
done
self_host_measure 'index test generation' env DEW_STD_ROOT="$PWD/$work/source" \
  _build/native/release/build/jtenner/dewdrop/dew_test_gen/dew_test_gen.exe "${args[@]}"
self_host_measure 'index test time provider' \
  wasm-tools parse tools/moonbit-time-provider.wat -o "$work/time.wasm"
self_host_measure 'index test link' \
  _build/native/release/build/jtenner/dewdrop/self_host_link_fixture/self_host_link_fixture.exe \
    "$work/tests-core.wasm" starshine-mb/dist/ffi/starshine-ffi.wasm \
    fixtures/facet/facet-adapter.wasm "$work/time.wasm" "$work/tests.wasm" --single-validation
self_host_measure 'index test execution' \
  node tools/dew-test/run.mjs --wasm "$work/tests.wasm" --allow-unused-host-imports --filter 'index lookup' "$@"
