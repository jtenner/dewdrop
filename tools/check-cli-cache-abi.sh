#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

echo "== compiler CLI smoke =="
mkdir -p .tmp

clean_root="$PWD/.tmp/dew-clean-command"
clean_link_target="$PWD/.tmp/dew-clean-link-target"
rm -rf "$clean_root" "$clean_link_target"
mkdir -p "$clean_root"/{_build,target,.tmp,.dew-cache,.dew/cache}
for marker in \
  _build/marker target/marker .tmp/marker .dew-cache/marker .dew/cache/marker; do
  printf 'managed build artifact\n' > "$clean_root/$marker"
done
DEW_REPOSITORY_ROOT="$clean_root" DEW_WORKING_DIRECTORY="$clean_root" \
  moon run --target native --release src/dew_bootstrap -- clean --dry-run \
  > .tmp/dew-clean-dry-run.txt
for target in .dew/cache _build target .tmp .dew-cache; do
  grep -Fq "would remove Dew build artifact: $clean_root/$target" \
    .tmp/dew-clean-dry-run.txt
  test -e "$clean_root/$target"
done
DEW_REPOSITORY_ROOT="$clean_root" DEW_WORKING_DIRECTORY="$clean_root" \
  moon run --target native --release src/dew_bootstrap -- clean \
  > .tmp/dew-clean.txt
for target in .dew/cache _build target .tmp .dew-cache; do
  test ! -e "$clean_root/$target"
done
mkdir -p "$clean_link_target"
printf 'keep\n' > "$clean_link_target/marker"
ln -s "$clean_link_target" "$clean_root/.dew/cache"
DEW_REPOSITORY_ROOT="$clean_root" DEW_WORKING_DIRECTORY="$clean_root" \
  moon run --target native --release src/dew_bootstrap -- clean \
  > .tmp/dew-clean-symlink.txt
test ! -e "$clean_root/.dew/cache"
test -f "$clean_link_target/marker"
DEW_REPOSITORY_ROOT="$clean_root" DEW_WORKING_DIRECTORY="$clean_root" \
  moon run --target native --release src/dew_bootstrap -- clean \
  > .tmp/dew-clean-idempotent.txt
grep -q '^Dew build artifacts already clean$' .tmp/dew-clean-idempotent.txt

rm -rf .tmp/dew-unified-cache-pack
DEW_CACHE_DIR=.tmp/dew-unified-cache-pack DEW_CACHE_PACK=1 \
  DEW_PROGRAM_CACHE=1 tools/dew build --no-build-cache --body-cache \
  --plan-cache --cache-report tests/module-snapshots/numeric/scalar.dew \
  -o .tmp/dew-unified-pack-cold.wasm > .tmp/dew-unified-pack-cold.txt
DEW_CACHE_DIR=.tmp/dew-unified-cache-pack DEW_CACHE_PACK=1 \
  DEW_PROGRAM_CACHE=1 tools/dew build --no-build-cache --body-cache \
  --plan-cache --cache-report tests/module-snapshots/numeric/scalar.dew \
  -o .tmp/dew-unified-pack-warm.wasm > .tmp/dew-unified-pack-warm.txt
grep -q '^compilation cache pack: exact hit, reads 1, hits 1, misses 0$' \
  .tmp/dew-unified-pack-warm.txt
cmp .tmp/dew-unified-pack-cold.wasm .tmp/dew-unified-pack-warm.wasm
test "$(find .tmp/dew-unified-cache-pack/packs -name 'v1-*.dwp' | wc -l)" -eq 1
test ! -d .tmp/dew-unified-cache-pack/parse-events
test ! -d .tmp/dew-unified-cache-pack/interfaces
test ! -d .tmp/dew-unified-cache-pack/body-inference
test ! -d .tmp/dew-unified-cache-pack/type-layouts
test ! -d .tmp/dew-unified-cache-pack/wasmgc-fragments
rm -rf .tmp/dew-unified-exact-only-cache
DEW_CACHE_DIR=.tmp/dew-unified-exact-only-cache DEW_CACHE_PACK=1 \
  DEW_PROGRAM_CACHE=1 tools/dew build --no-build-cache \
  --no-parse-event-cache --no-interface-cache --no-body-cache --no-plan-cache \
  tests/module-snapshots/numeric/scalar.dew \
  -o .tmp/dew-unified-exact-only-cold.wasm > /dev/null
DEW_CACHE_DIR=.tmp/dew-unified-exact-only-cache DEW_CACHE_PACK=1 \
  DEW_PROGRAM_CACHE=1 tools/dew build --no-build-cache --cache-report \
  --no-parse-event-cache --no-interface-cache --no-body-cache --no-plan-cache \
  tests/module-snapshots/numeric/scalar.dew \
  -o .tmp/dew-unified-exact-only-warm.wasm \
  > .tmp/dew-unified-exact-only-warm.txt
grep -q '^compilation cache pack: exact hit, reads 1, hits 1, misses 0$' \
  .tmp/dew-unified-exact-only-warm.txt
cmp .tmp/dew-unified-exact-only-cold.wasm \
  .tmp/dew-unified-exact-only-warm.wasm
DEW_CACHE_DIR=.tmp/dew-unified-cache-pack DEW_CACHE_PACK=1 \
  DEW_PROGRAM_CACHE=0 tools/dew check --body-cache --plan-cache \
  --cache-report tests/module-snapshots/numeric/scalar.dew \
  > .tmp/dew-unified-pack-phase-warm.txt
grep -q '^parse event cache: hits [1-9][0-9]*, misses 0$' \
  .tmp/dew-unified-pack-phase-warm.txt
grep -q '^standard interface cache: hits [1-9][0-9]*, misses 0$' \
  .tmp/dew-unified-pack-phase-warm.txt
grep -q '^body inference cache: module hits [1-9][0-9]*, module misses 0, family disabled$' \
  .tmp/dew-unified-pack-phase-warm.txt
grep -q '^layout and fragment cache: layout hits [1-9][0-9]*, layout misses 0, fragment hits [1-9][0-9]*, fragment misses 0$' \
  .tmp/dew-unified-pack-phase-warm.txt
rm -rf .tmp/dew-unified-edit-cache .tmp/dew-unified-edit
mkdir -p .tmp/dew-unified-edit
cat > .tmp/dew-unified-edit/main.dew <<'EOF'
pub fn main() -> I32 {
  1
}
EOF
DEW_CACHE_DIR=.tmp/dew-unified-edit-cache DEW_CACHE_PACK=1 \
  DEW_PROGRAM_CACHE=1 tools/dew build --no-build-cache --cache-report \
  .tmp/dew-unified-edit/main.dew -o .tmp/dew-unified-edit/first.wasm \
  > .tmp/dew-unified-edit/first.txt
python3 - <<'PY'
from pathlib import Path
path = Path('.tmp/dew-unified-edit/main.dew')
path.write_text(path.read_text().replace('  1\n', '  2\n'))
PY
DEW_CACHE_DIR=.tmp/dew-unified-edit-cache DEW_CACHE_PACK=1 \
  DEW_PROGRAM_CACHE=1 tools/dew build --no-build-cache --cache-report \
  .tmp/dew-unified-edit/main.dew -o .tmp/dew-unified-edit/changed.wasm \
  > .tmp/dew-unified-edit/changed.txt
if grep -q '^compilation cache pack: exact hit' .tmp/dew-unified-edit/changed.txt; then
  echo "expected source edit to invalidate exact pack result" >&2
  exit 1
fi
if cmp -s .tmp/dew-unified-edit/first.wasm .tmp/dew-unified-edit/changed.wasm; then
  echo "expected source edit to change Wasm" >&2
  exit 1
fi
DEW_CACHE_DIR=.tmp/dew-unified-edit-cache DEW_CACHE_PACK=1 \
  DEW_PROGRAM_CACHE=1 tools/dew build --no-build-cache --cache-report \
  .tmp/dew-unified-edit/main.dew -o .tmp/dew-unified-edit/warm.wasm \
  > .tmp/dew-unified-edit/warm.txt
grep -q '^compilation cache pack: exact hit, reads 1, hits 1, misses 0$' \
  .tmp/dew-unified-edit/warm.txt
cmp .tmp/dew-unified-edit/changed.wasm .tmp/dew-unified-edit/warm.wasm
DEW_CACHE_DIR=.tmp/dew-unified-edit-cache DEW_CACHE_PACK=1 \
  DEW_PROGRAM_CACHE=1 tools/dew build --no-build-cache --emit hir \
  .tmp/dew-unified-edit/main.dew -o .tmp/dew-unified-edit/cold.hir > /dev/null
DEW_CACHE_DIR=.tmp/dew-unified-edit-cache DEW_CACHE_PACK=1 \
  DEW_PROGRAM_CACHE=1 tools/dew build --no-build-cache --emit hir --cache-report \
  .tmp/dew-unified-edit/main.dew -o .tmp/dew-unified-edit/warm.hir \
  > .tmp/dew-unified-edit/warm-hir.txt
grep -q '^compilation cache pack: exact hit, reads 1, hits 1, misses 0$' \
  .tmp/dew-unified-edit/warm-hir.txt
cmp .tmp/dew-unified-edit/cold.hir .tmp/dew-unified-edit/warm.hir
DEW_CACHE_DIR=.tmp/dew-unified-edit-cache DEW_CACHE_PACK=1 \
  DEW_PROGRAM_CACHE=1 tools/dew build --no-build-cache --emit lowering \
  .tmp/dew-unified-edit/main.dew -o .tmp/dew-unified-edit/cold.lowering > /dev/null
DEW_CACHE_DIR=.tmp/dew-unified-edit-cache DEW_CACHE_PACK=1 \
  DEW_PROGRAM_CACHE=1 tools/dew build --no-build-cache --emit lowering \
  --cache-report .tmp/dew-unified-edit/main.dew \
  -o .tmp/dew-unified-edit/warm.lowering \
  > .tmp/dew-unified-edit/warm-lowering.txt
grep -q '^compilation cache pack: exact hit, reads 1, hits 1, misses 0$' \
  .tmp/dew-unified-edit/warm-lowering.txt
cmp .tmp/dew-unified-edit/cold.lowering .tmp/dew-unified-edit/warm.lowering
pack_file=$(find .tmp/dew-unified-cache-pack/packs -name 'v1-*.dwp' -print -quit)
printf 'corrupt' > "$pack_file"
if DEW_CACHE_DIR=.tmp/dew-unified-cache-pack DEW_CACHE_PACK=1 \
  DEW_PROGRAM_CACHE=1 tools/dew check \
  tests/module-snapshots/numeric/scalar.dew \
  > .tmp/dew-unified-pack-corrupt.txt 2>&1; then
  echo "expected corrupt unified cache pack to fail visibly" >&2
  exit 1
fi
grep -q 'corrupt compilation cache pack' .tmp/dew-unified-pack-corrupt.txt

export DEW_CACHE_PACK=0
export DEW_PROGRAM_CACHE=0
export DEW_CACHE_DIR=.tmp/dew-check-interface-cache
rm -rf "$DEW_CACHE_DIR"
tools/dew check tests/module-snapshots/numeric/scalar.dew
tools/dew check --package-root . tests/module-snapshots/numeric/scalar.dew
rm -rf .tmp/incomplete-package-root
mkdir -p .tmp/incomplete-package-root/dew.std/std/preamble
cp std/preamble/00-builtins.dew \
  .tmp/incomplete-package-root/dew.std/std/preamble/00-builtins.dew
if tools/dew check --package-root .tmp/incomplete-package-root \
  tests/module-snapshots/numeric/scalar.dew \
  > .tmp/incomplete-package-error.txt 2>&1; then
  echo "expected incomplete dew.std package to fail closed" >&2
  exit 1
fi
grep -q 'cannot read standard source' .tmp/incomplete-package-error.txt
tools/dew check tests/module-snapshots/modules/std-wildcard-runtime.dew
tools/dew check --no-default-preamble \
  tests/module-snapshots/modules/std-wildcard-runtime.dew
tools/dew build tests/module-snapshots/numeric/scalar.dew -o .tmp/dew-std-disk.wasm
tools/dew build --bootstrap-std tests/module-snapshots/numeric/scalar.dew \
  -o .tmp/dew-std-bootstrap.wasm
cmp .tmp/dew-std-disk.wasm .tmp/dew-std-bootstrap.wasm
tools/dew build tests/module-snapshots/modules/std-wildcard-runtime.dew \
  -o .tmp/dew-std-wildcard-disk.wasm
tools/dew build --bootstrap-std \
  tests/module-snapshots/modules/std-wildcard-runtime.dew \
  -o .tmp/dew-std-wildcard-bootstrap.wasm
cmp .tmp/dew-std-wildcard-disk.wasm .tmp/dew-std-wildcard-bootstrap.wasm
rm -rf .tmp/dew-body-default-cache
DEW_CACHE_DIR=.tmp/dew-body-default-cache tools/dew check --cache-report \
  tests/module-snapshots/numeric/scalar.dew \
  > .tmp/dew-body-default.txt
grep -q '^body inference cache: disabled$' .tmp/dew-body-default.txt
grep -q '^layout and fragment cache: disabled$' .tmp/dew-body-default.txt
test ! -d .tmp/dew-body-default-cache/body-inference
test ! -d .tmp/dew-body-default-cache/type-layouts
test ! -d .tmp/dew-body-default-cache/wasmgc-fragments
rm -rf .tmp/dew-planning-cache
DEW_CACHE_DIR=.tmp/dew-planning-cache tools/dew build \
  --no-build-cache --plan-cache --cache-report \
  tests/module-snapshots/numeric/scalar.dew \
  -o .tmp/dew-planning-cache-cold.wasm \
  > .tmp/dew-planning-cache-cold.txt
DEW_CACHE_DIR=.tmp/dew-planning-cache tools/dew build \
  --no-build-cache --plan-cache --cache-report \
  tests/module-snapshots/numeric/scalar.dew \
  -o .tmp/dew-planning-cache-warm.wasm \
  > .tmp/dew-planning-cache-warm.txt
grep -q '^layout and fragment cache: layout hits 0, layout misses [1-9][0-9]*, fragment hits 0, fragment misses [1-9][0-9]*$' \
  .tmp/dew-planning-cache-cold.txt
grep -q '^layout and fragment cache: layout hits [1-9][0-9]*, layout misses 0, fragment hits [1-9][0-9]*, fragment misses 0$' \
  .tmp/dew-planning-cache-warm.txt
cmp .tmp/dew-planning-cache-cold.wasm .tmp/dew-planning-cache-warm.wasm
rm -rf .tmp/dew-planning-incremental
mkdir -p .tmp/dew-planning-incremental
cat > .tmp/dew-planning-incremental/library.dew <<'EOF'
struct Item {
  value: I32
}
fn hidden() -> I32 {
  1
}
pub fn answer() -> I32 {
  42
}
EOF
cat > .tmp/dew-planning-incremental/main.dew <<'EOF'
open fixture.library
pub fn main() -> I32 {
  answer()
}
EOF
DEW_CACHE_DIR=.tmp/dew-planning-incremental/cache tools/dew build \
  --no-build-cache --plan-cache \
  --module fixture.library .tmp/dew-planning-incremental/library.dew \
  --module fixture.main .tmp/dew-planning-incremental/main.dew \
  --root fixture.main -o .tmp/dew-planning-incremental/cold.wasm > /dev/null
python3 - <<'PY'
from pathlib import Path
path = Path('.tmp/dew-planning-incremental/library.dew')
path.write_text(path.read_text().replace('  1\n', '  2\n', 1))
PY
DEW_CACHE_DIR=.tmp/dew-planning-incremental/cache tools/dew build \
  --no-build-cache --plan-cache --cache-report \
  --module fixture.library .tmp/dew-planning-incremental/library.dew \
  --module fixture.main .tmp/dew-planning-incremental/main.dew \
  --root fixture.main -o .tmp/dew-planning-incremental/cached.wasm \
  > .tmp/dew-planning-incremental/cached.txt
DEW_CACHE_DIR=.tmp/dew-planning-incremental/fresh-cache tools/dew build \
  --no-build-cache --no-plan-cache \
  --module fixture.library .tmp/dew-planning-incremental/library.dew \
  --module fixture.main .tmp/dew-planning-incremental/main.dew \
  --root fixture.main -o .tmp/dew-planning-incremental/fresh.wasm > /dev/null
cmp .tmp/dew-planning-incremental/cached.wasm \
  .tmp/dew-planning-incremental/fresh.wasm
grep -q '^layout and fragment cache: layout hits [1-9][0-9]*, layout misses 1, fragment hits 0, fragment misses [1-9][0-9]*$' \
  .tmp/dew-planning-incremental/cached.txt
layout_cache_file=$(find .tmp/dew-planning-cache/type-layouts -type f | head -n 1)
printf 'corrupt' > "$layout_cache_file"
if DEW_CACHE_DIR=.tmp/dew-planning-cache tools/dew check --plan-cache \
  tests/module-snapshots/numeric/scalar.dew \
  > .tmp/dew-planning-layout-corrupt.txt 2>&1; then
  echo "expected corrupt type-layout cache to fail visibly" >&2
  exit 1
fi
grep -q 'corrupt type-layout cache' .tmp/dew-planning-layout-corrupt.txt
rm -rf .tmp/dew-planning-cache
DEW_CACHE_DIR=.tmp/dew-planning-cache tools/dew check --plan-cache \
  tests/module-snapshots/numeric/scalar.dew > /dev/null
fragment_cache_file=$(find .tmp/dew-planning-cache/wasmgc-fragments -type f | head -n 1)
printf 'corrupt' > "$fragment_cache_file"
if DEW_CACHE_DIR=.tmp/dew-planning-cache tools/dew check --plan-cache \
  tests/module-snapshots/numeric/scalar.dew \
  > .tmp/dew-planning-fragment-corrupt.txt 2>&1; then
  echo "expected corrupt WasmGC fragment cache to fail visibly" >&2
  exit 1
fi
grep -q 'corrupt WasmGC fragment cache' \
  .tmp/dew-planning-fragment-corrupt.txt
rm -rf .tmp/dew-interface-cache
DEW_CACHE_DIR=.tmp/dew-interface-cache tools/dew check --body-cache \
  --cache-report tests/module-snapshots/numeric/scalar.dew \
  > .tmp/dew-interface-cache-miss.txt
DEW_CACHE_DIR=.tmp/dew-interface-cache tools/dew check --body-cache \
  --cache-report tests/module-snapshots/numeric/scalar.dew \
  > .tmp/dew-interface-cache-hit.txt
grep -q '^standard interface cache: hits 0, misses [1-9][0-9]*$' \
  .tmp/dew-interface-cache-miss.txt
grep -q '^standard interface cache: hits [1-9][0-9]*, misses 0$' \
  .tmp/dew-interface-cache-hit.txt
grep -q '^parse event cache: hits 0, misses ' .tmp/dew-interface-cache-miss.txt
grep -q '^parse event cache: hits [1-9][0-9]*, misses 0$' \
  .tmp/dew-interface-cache-hit.txt
grep -q '^body inference cache: module hits 0, module misses [1-9][0-9]*, family disabled$' \
  .tmp/dew-interface-cache-miss.txt
grep -q '^body inference cache: module hits [1-9][0-9]*, module misses 0, family disabled$' \
  .tmp/dew-interface-cache-hit.txt
DEW_CACHE_DIR=.tmp/dew-interface-cache tools/dew build \
  tests/module-snapshots/numeric/scalar.dew -o .tmp/dew-cache-hit.wasm
cmp .tmp/dew-std-disk.wasm .tmp/dew-cache-hit.wasm
rm -rf .tmp/dew-body-family-cache .tmp/dew-body-family
mkdir -p .tmp/dew-body-family
cat > .tmp/dew-body-family/main.dew <<'DEW'
fn first() -> I32 {
  1
}
fn changed() -> I32 {
  2
}
fn later() -> I32 {
  first() + 3
}
fn main() -> I32 {
  later() + changed()
}
DEW
DEW_CACHE_DIR=.tmp/dew-body-family-cache tools/dew build \
  --body-family-cache --cache-report .tmp/dew-body-family/main.dew \
  -o .tmp/dew-body-family-cold.wasm \
  > .tmp/dew-body-family-cold.txt
cat > .tmp/dew-body-family/main.dew <<'DEW'
fn first() -> I32 {
  1
}
fn changed() -> I32 {
  if true {
    20
  } else {
    2
  }
}
fn later() -> I32 {
  first() + 3
}
fn main() -> I32 {
  later() + changed()
}
DEW
DEW_CACHE_DIR=.tmp/dew-body-family-cache tools/dew build \
  --body-family-cache --cache-report .tmp/dew-body-family/main.dew \
  -o .tmp/dew-body-family-incremental.wasm \
  > .tmp/dew-body-family-incremental.txt
DEW_CACHE_DIR=.tmp/dew-body-family-fresh-cache tools/dew build \
  --no-body-cache .tmp/dew-body-family/main.dew \
  -o .tmp/dew-body-family-fresh.wasm > /dev/null
cmp .tmp/dew-body-family-incremental.wasm .tmp/dew-body-family-fresh.wasm
grep -q '^body inference cache: module hits [1-9][0-9]*, module misses 1, family hits 3, family misses 1$' \
  .tmp/dew-body-family-incremental.txt
test "$(find .tmp/dew-body-family-cache/body-inference-families -name 'v2-*.dbf' | wc -l)" -eq 1
rm -rf .tmp/dew-body-family-cache/body-inference
family_cache_file=$(find \
  .tmp/dew-body-family-cache/body-inference-families \
  -type f -print -quit)
printf 'corrupt' > "$family_cache_file"
if DEW_CACHE_DIR=.tmp/dew-body-family-cache tools/dew check \
  --body-family-cache .tmp/dew-body-family/main.dew \
  > .tmp/dew-body-family-corrupt.txt 2>&1; then
  echo "expected corrupt body-family cache to fail visibly" >&2
  exit 1
fi
grep -q 'corrupt body-family cache' .tmp/dew-body-family-corrupt.txt
DEW_CACHE_DIR=.tmp/dew-interface-cache tools/dew check \
  --no-interface-cache --cache-report \
  tests/module-snapshots/numeric/scalar.dew \
  > .tmp/dew-interface-cache-disabled.txt
grep -q '^standard interface cache: disabled$' \
  .tmp/dew-interface-cache-disabled.txt
DEW_CACHE_DIR=.tmp/dew-interface-cache tools/dew check \
  --no-body-cache --cache-report \
  tests/module-snapshots/numeric/scalar.dew \
  > .tmp/dew-body-cache-disabled.txt
grep -q '^body inference cache: disabled$' \
  .tmp/dew-body-cache-disabled.txt
DEW_CACHE_DIR=.tmp/dew-interface-cache tools/dew check \
  --no-parse-event-cache --no-interface-cache --cache-report \
  tests/module-snapshots/numeric/scalar.dew \
  > .tmp/dew-parse-event-cache-disabled.txt
grep -q '^parse event cache: disabled (parsed [1-9][0-9]*)$' \
  .tmp/dew-parse-event-cache-disabled.txt
parse_cache_file=$(find .tmp/dew-interface-cache/parse-events -type f | head -n 1)
printf 'corrupt' > "$parse_cache_file"
if DEW_CACHE_DIR=.tmp/dew-interface-cache tools/dew check \
  tests/module-snapshots/numeric/scalar.dew \
  > .tmp/dew-parse-event-cache-corrupt.txt 2>&1; then
  echo "expected corrupt parse-event cache to fail visibly" >&2
  exit 1
fi
grep -q 'corrupt parse-event cache' \
  .tmp/dew-parse-event-cache-corrupt.txt
rm -rf .tmp/dew-interface-cache/parse-events
DEW_CACHE_DIR=.tmp/dew-interface-cache tools/dew check \
  tests/module-snapshots/numeric/scalar.dew > /dev/null
cache_file=$(find .tmp/dew-interface-cache/interfaces -type f | head -n 1)
printf 'corrupt' > "$cache_file"
if DEW_CACHE_DIR=.tmp/dew-interface-cache tools/dew check \
  tests/module-snapshots/numeric/scalar.dew \
  > .tmp/dew-interface-cache-corrupt.txt 2>&1; then
  echo "expected corrupt frozen-interface cache to fail visibly" >&2
  exit 1
fi
grep -q 'corrupt frozen-interface cache' \
  .tmp/dew-interface-cache-corrupt.txt
rm -rf .tmp/dew-interface-cache/interfaces
DEW_CACHE_DIR=.tmp/dew-interface-cache tools/dew check --body-cache \
  tests/module-snapshots/numeric/scalar.dew > /dev/null
body_cache_file=$(find .tmp/dew-interface-cache/body-inference -type f | head -n 1)
printf 'corrupt' > "$body_cache_file"
if DEW_CACHE_DIR=.tmp/dew-interface-cache tools/dew check --body-cache \
  tests/module-snapshots/numeric/scalar.dew \
  > .tmp/dew-body-cache-corrupt.txt 2>&1; then
  echo "expected corrupt body-inference cache to fail visibly" >&2
  exit 1
fi
grep -q 'corrupt body-inference cache' \
  .tmp/dew-body-cache-corrupt.txt
rm -rf .tmp/dew-workspace-interface-cache
DEW_CACHE_DIR=.tmp/dew-workspace-interface-cache tools/dew build \
  --no-build-cache --body-cache --cache-report \
  --module fixture.library tests/cli/multi-module/library.dew \
  --module fixture.main tests/cli/multi-module/main.dew \
  --root fixture.main -o .tmp/dew-workspace-interface-cold.wasm \
  > .tmp/dew-workspace-interface-cold.txt
DEW_CACHE_DIR=.tmp/dew-workspace-interface-cache tools/dew build \
  --no-build-cache --body-cache --cache-report \
  --module fixture.library tests/cli/multi-module/library.dew \
  --module fixture.main tests/cli/multi-module/main.dew \
  --root fixture.main -o .tmp/dew-workspace-interface-warm.wasm \
  > .tmp/dew-workspace-interface-warm.txt
grep -q '^standard interface cache: hits 0, misses [1-9][0-9]*$' \
  .tmp/dew-workspace-interface-cold.txt
grep -q '^standard interface cache: hits [1-9][0-9]*, misses 0$' \
  .tmp/dew-workspace-interface-warm.txt
grep -q '^body inference cache: module hits 0, module misses [1-9][0-9]*, family disabled$' \
  .tmp/dew-workspace-interface-cold.txt
grep -q '^body inference cache: module hits [1-9][0-9]*, module misses 0, family disabled$' \
  .tmp/dew-workspace-interface-warm.txt
cmp .tmp/dew-workspace-interface-cold.wasm \
  .tmp/dew-workspace-interface-warm.wasm
workspace_cache_file=$(find \
  .tmp/dew-workspace-interface-cache/workspace-interfaces \
  -type f | head -n 1)
printf 'corrupt' > "$workspace_cache_file"
if DEW_CACHE_DIR=.tmp/dew-workspace-interface-cache tools/dew check \
  --module fixture.library tests/cli/multi-module/library.dew \
  --module fixture.main tests/cli/multi-module/main.dew \
  --root fixture.main \
  > .tmp/dew-workspace-interface-corrupt.txt 2>&1; then
  echo "expected corrupt workspace interface cache to fail visibly" >&2
  exit 1
fi
grep -q 'corrupt workspace frozen-interface cache' \
  .tmp/dew-workspace-interface-corrupt.txt
rm -rf .tmp/dew-workspace-invalidation
mkdir -p .tmp/dew-workspace-invalidation
cat > .tmp/dew-workspace-invalidation/base.dew <<'EOF'
pub fn base() -> I32 {
  40
}
EOF
cat > .tmp/dew-workspace-invalidation/library.dew <<'EOF'
open fixture.base
pub fn answer() -> I32 {
  base() + 2
}
EOF
cat > .tmp/dew-workspace-invalidation/main.dew <<'EOF'
open fixture.library
pub fn main() -> I32 {
  answer()
}
EOF
workspace_build() {
  output=$1
  report=$2
  shift 2
  DEW_CACHE_DIR=.tmp/dew-workspace-invalidation/cache tools/dew build \
    --no-build-cache --cache-report "$@" \
    --module fixture.base .tmp/dew-workspace-invalidation/base.dew \
    --module fixture.library .tmp/dew-workspace-invalidation/library.dew \
    --module fixture.main .tmp/dew-workspace-invalidation/main.dew \
    --root fixture.main -o "$output" > "$report"
}
workspace_build .tmp/dew-workspace-invalidation/cold.wasm \
  .tmp/dew-workspace-invalidation/cold.txt
workspace_build .tmp/dew-workspace-invalidation/warm.wasm \
  .tmp/dew-workspace-invalidation/warm.txt
grep -q '^standard interface cache: hits 0, misses [1-9][0-9]*$' \
  .tmp/dew-workspace-invalidation/cold.txt
grep -q '^standard interface cache: hits [1-9][0-9]*, misses 0$' \
  .tmp/dew-workspace-invalidation/warm.txt
cmp .tmp/dew-workspace-invalidation/cold.wasm \
  .tmp/dew-workspace-invalidation/warm.wasm
cat > .tmp/dew-workspace-invalidation/base.dew <<'EOF'
fn hidden() -> I32 {
  1
}
pub fn base() -> I32 {
  40
}
EOF
workspace_build .tmp/dew-workspace-invalidation/private.wasm \
  .tmp/dew-workspace-invalidation/private.txt
grep -q '^standard interface cache: hits [1-9][0-9]*, misses 1$' \
  .tmp/dew-workspace-invalidation/private.txt
DEW_CACHE_DIR=.tmp/dew-workspace-invalidation/uncached tools/dew build \
  --no-build-cache --no-interface-cache \
  --module fixture.base .tmp/dew-workspace-invalidation/base.dew \
  --module fixture.library .tmp/dew-workspace-invalidation/library.dew \
  --module fixture.main .tmp/dew-workspace-invalidation/main.dew \
  --root fixture.main -o .tmp/dew-workspace-invalidation/private-uncached.wasm
cmp .tmp/dew-workspace-invalidation/private.wasm \
  .tmp/dew-workspace-invalidation/private-uncached.wasm
cat > .tmp/dew-workspace-invalidation/base.dew <<'EOF'
pub fn base() -> I32 {
  40
}
pub fn visible() -> I32 {
  1
}
EOF
workspace_build .tmp/dew-workspace-invalidation/public.wasm \
  .tmp/dew-workspace-invalidation/public.txt
grep -q '^standard interface cache: hits [1-9][0-9]*, misses 2$' \
  .tmp/dew-workspace-invalidation/public.txt
DEW_CACHE_DIR=.tmp/dew-workspace-invalidation/uncached-public tools/dew build \
  --no-build-cache --no-interface-cache \
  --module fixture.base .tmp/dew-workspace-invalidation/base.dew \
  --module fixture.library .tmp/dew-workspace-invalidation/library.dew \
  --module fixture.main .tmp/dew-workspace-invalidation/main.dew \
  --root fixture.main -o .tmp/dew-workspace-invalidation/public-uncached.wasm
cmp .tmp/dew-workspace-invalidation/public.wasm \
  .tmp/dew-workspace-invalidation/public-uncached.wasm
rm -rf .tmp/dew-workspace-scc-cache
mkdir -p .tmp/dew-workspace-scc-cache
cat > .tmp/dew-workspace-scc-cache/a.dew <<'EOF'
open cycle.b
pub struct A {
  b: B
}
pub fn keep_a(value: A) -> A {
  value
}
EOF
cat > .tmp/dew-workspace-scc-cache/b.dew <<'EOF'
open cycle.a
pub struct B {
  a: A
}
pub fn keep_b(value: B) -> B {
  value
}
EOF
cat > .tmp/dew-workspace-scc-cache/main.dew <<'EOF'
open cycle.a
pub fn main() -> I32 {
  42
}
EOF
workspace_scc_build() {
  output=$1
  report=$2
  DEW_CACHE_DIR=.tmp/dew-workspace-scc-cache/cache tools/dew build \
    --no-build-cache --cache-report \
    --module cycle.a .tmp/dew-workspace-scc-cache/a.dew \
    --module cycle.b .tmp/dew-workspace-scc-cache/b.dew \
    --module cycle.main .tmp/dew-workspace-scc-cache/main.dew \
    --root cycle.main -o "$output" > "$report"
}
workspace_scc_build .tmp/dew-workspace-scc-cache/cold.wasm \
  .tmp/dew-workspace-scc-cache/cold.txt
workspace_scc_build .tmp/dew-workspace-scc-cache/warm.wasm \
  .tmp/dew-workspace-scc-cache/warm.txt
grep -q '^standard interface cache: hits 0, misses [1-9][0-9]*$' \
  .tmp/dew-workspace-scc-cache/cold.txt
grep -q '^standard interface cache: hits [1-9][0-9]*, misses 0$' \
  .tmp/dew-workspace-scc-cache/warm.txt
cmp .tmp/dew-workspace-scc-cache/cold.wasm \
  .tmp/dew-workspace-scc-cache/warm.wasm
scc_cache_file=$(find \
  .tmp/dew-workspace-scc-cache/cache/workspace-interfaces \
  -type f | head -n 1)
printf 'corrupt' > "$scc_cache_file"
if workspace_scc_build .tmp/dew-workspace-scc-cache/corrupt.wasm \
  .tmp/dew-workspace-scc-cache/corrupt.txt 2>&1; then
  echo "expected corrupt workspace SCC interface cache to fail visibly" >&2
  exit 1
fi
grep -q 'corrupt workspace frozen-interface SCC cache' \
  .tmp/dew-workspace-scc-cache/corrupt.txt
rm -rf .tmp/dew-workspace-interface-cache \
  .tmp/dew-workspace-interface-cold.wasm \
  .tmp/dew-workspace-interface-warm.wasm \
  .tmp/dew-workspace-invalidation \
  .tmp/dew-workspace-scc-cache
rm -rf .tmp/dew-build-output-cache
DEW_CACHE_DIR=.tmp/dew-build-output-cache tools/dew build --cache-report \
  tests/compile-pass/basic.dew -o .tmp/dew-build-output-first.wasm \
  > .tmp/dew-build-output-first.txt
DEW_CACHE_DIR=.tmp/dew-build-output-cache tools/dew build --cache-report \
  tests/compile-pass/basic.dew -o .tmp/dew-build-output-second.wasm \
  > .tmp/dew-build-output-second.txt
grep -q '^build output cache: miss ' .tmp/dew-build-output-first.txt
grep -q '^build output cache: hit ' .tmp/dew-build-output-second.txt
cmp .tmp/dew-build-output-first.wasm .tmp/dew-build-output-second.wasm
DEW_CACHE_DIR=.tmp/dew-build-output-cache tools/dew build --no-build-cache \
  tests/compile-pass/basic.dew -o .tmp/dew-build-output-disabled.wasm
cmp .tmp/dew-build-output-first.wasm .tmp/dew-build-output-disabled.wasm
build_cache_file=$(find .tmp/dew-build-output-cache/builds -type f | head -n 1)
printf 'corrupt' > "$build_cache_file"
if DEW_CACHE_DIR=.tmp/dew-build-output-cache tools/dew build \
  tests/compile-pass/basic.dew -o .tmp/dew-build-output-corrupt.wasm \
  > .tmp/dew-build-output-corrupt.txt 2>&1; then
  echo "expected corrupt build-output cache to fail visibly" >&2
  exit 1
fi
grep -q 'corrupt build cache artifact' .tmp/dew-build-output-corrupt.txt
rm -rf .tmp/dew-build-output-cache
rm -rf .tmp/dew-interface-cache .tmp/dew-cache-package-root \
  .tmp/dew-cache-invalidation
mkdir -p .tmp/dew-cache-package-root/dew.std
cp -R std .tmp/dew-cache-package-root/dew.std/std
DEW_CACHE_DIR=.tmp/dew-cache-invalidation tools/dew check --cache-report \
  --package-root .tmp/dew-cache-package-root \
  tests/module-snapshots/numeric/scalar.dew \
  > .tmp/dew-cache-content-first.txt
printf '\n' >> .tmp/dew-cache-package-root/dew.std/std/option.dew
DEW_CACHE_DIR=.tmp/dew-cache-invalidation tools/dew check --cache-report \
  --package-root .tmp/dew-cache-package-root \
  tests/module-snapshots/numeric/scalar.dew \
  > .tmp/dew-cache-content-changed.txt
grep -q '^standard interface cache: hits 0, misses [1-9][0-9]*$' \
  .tmp/dew-cache-content-first.txt
grep -q '^standard interface cache: hits 0, misses [1-9][0-9]*$' \
  .tmp/dew-cache-content-changed.txt
grep -q '^parse event cache: hits 0, misses ' \
  .tmp/dew-cache-content-first.txt
grep -q '^parse event cache: hits [1-9][0-9]*, misses 1$' \
  .tmp/dew-cache-content-changed.txt
test "$(find .tmp/dew-cache-invalidation/interfaces -type f | wc -l)" -eq 2
rm -rf .tmp/dew-interface-cache .tmp/dew-cache-package-root \
  .tmp/dew-cache-invalidation
tools/dew check --manifest tests/cli/multi-module/dew.modules.json
tools/dew build \
  --manifest tests/cli/multi-module/dew.modules.json \
  -o .tmp/dew-cli-smoke.wasm
tools/dew build --emit hir -o .tmp/dew-cli-smoke.hir \
  tests/module-snapshots/numeric/scalar.dew
tools/dew build --emit lowering -o .tmp/dew-cli-smoke.lowering \
  tests/module-snapshots/numeric/scalar.dew
tools/dew build --emit wat -o .tmp/dew-cli-smoke.wat \
  tests/module-snapshots/numeric/scalar.dew
test -s .tmp/dew-cli-smoke.hir
test -s .tmp/dew-cli-smoke.lowering
test -s .tmp/dew-cli-smoke.wat
grep -Fq '(@custom "dew.abi"' .tmp/dew-cli-smoke.wat
grep -Fq '(@custom "dew.metrics"' .tmp/dew-cli-smoke.wat
tools/dew run tests/module-snapshots/control-flow/short-circuit-runtime.dew \
  > .tmp/dew-cli-run.txt
grep -q '^control:short-circuit$' .tmp/dew-cli-run.txt
tools/dew build \
  tests/module-snapshots/generics/generic-erased-scalar-adapter-runtime.dew \
  -o .tmp/dew-abi-smoke.wasm
node tools/dew-abi.mjs .tmp/dew-abi-smoke.wasm list \
  > .tmp/dew-abi-list.json
grep -q '"export":"identity[$]dew[$]i32"' .tmp/dew-abi-list.json
node tools/dew-abi.mjs .tmp/dew-abi-smoke.wasm \
  call identity i32 i32 i32 '[42]' > .tmp/dew-abi-call.json
grep -q '"value":42' .tmp/dew-abi-call.json
wasm-tools parse \
  tests/abi-consumers/generic-v128-identity.wat \
  -o .tmp/dew-v128-consumer.wasm
node tools/dew-wasm-consumer.mjs \
  .tmp/dew-abi-smoke.wasm \
  .tmp/dew-v128-consumer.wasm \
  run i32 > .tmp/dew-v128-consumer.json
grep -q '"type":"i32","value":42' .tmp/dew-v128-consumer.json
tools/dew build \
  tests/module-snapshots/functions/generic-structural-callback-runtime.dew \
  -o .tmp/dew-callback-wrapper-budget.wasm
tools/dew build \
  tests/module-snapshots/functions/generic-aggregate-callback-adapter-runtime.dew \
  -o .tmp/dew-aggregate-callback-budget.wasm
wasm-tools parse \
  tests/abi-consumers/generic-aggregate-callback-i32.wat \
  -o .tmp/dew-aggregate-callback-consumer.wasm
node tools/dew-wasm-consumer.mjs \
  .tmp/dew-aggregate-callback-budget.wasm \
  .tmp/dew-aggregate-callback-consumer.wasm \
  run i32 > .tmp/dew-aggregate-callback-consumer.json
grep -q '"type":"i32","value":42' \
  .tmp/dew-aggregate-callback-consumer.json
wasm-tools parse \
  tests/abi-consumers/generic-enum-callback-i32.wat \
  -o .tmp/dew-enum-callback-consumer.wasm
node tools/dew-wasm-consumer.mjs \
  .tmp/dew-aggregate-callback-budget.wasm \
  .tmp/dew-enum-callback-consumer.wasm \
  run i32 > .tmp/dew-enum-callback-consumer.json
grep -q '"type":"i32","value":42' \
  .tmp/dew-enum-callback-consumer.json
tools/dew build \
  tests/module-snapshots/generics/generic-erased-fallback-runtime.dew \
  -o .tmp/dew-eqref-provider.wasm
wasm-tools parse \
  tests/abi-consumers/generic-eqref-identity.wat \
  -o .tmp/dew-eqref-consumer.wasm
node tools/dew-wasm-consumer.mjs \
  .tmp/dew-eqref-provider.wasm \
  .tmp/dew-eqref-consumer.wasm \
  run i32 > .tmp/dew-eqref-consumer.json
grep -q '"type":"i32","value":42' .tmp/dew-eqref-consumer.json
tools/dew build --root app.main \
  --module app.main tests/abi-consumers/runtime-trait-evidence-provider.dew \
  --module fixture.runtime_evidence \
    tests/abi-consumers/runtime-trait-evidence-provider.modules/fixture.runtime_evidence/support.dew \
  -o .tmp/dew-runtime-trait-evidence-provider.wasm
wasm-tools print .tmp/dew-runtime-trait-evidence-provider.wasm \
  > .tmp/dew-runtime-trait-evidence-provider.wat
# `choose` needs one trait object; `read` forwards the supplied vtable through
# an imported recursive chain. `boxed_read` allocates its source Box, while
# `nested_read` allocates its source Box and Wrap; both forward the same evidence
# through exact recursively nested concrete implementation prerequisites. The
# exported `reader` additionally allocates an evidence-capturing closure. The
# erased exports wrap receivers with one or two source-ordered caller dictionaries;
# `erased_nested` then dispatches through two concrete prerequisite layers.
test "$(grep -c 'call_ref' .tmp/dew-runtime-trait-evidence-provider.wat)" -eq 4
test "$(grep -c 'struct.new' .tmp/dew-runtime-trait-evidence-provider.wat)" -eq 15
test "$(grep -c 'struct (field eqref) (field eqref))' .tmp/dew-runtime-trait-evidence-provider.wat)" -eq 1
test "$(grep -c 'struct (field eqref) (field eqref) (field eqref))' .tmp/dew-runtime-trait-evidence-provider.wat)" -eq 1
test "$(grep -c 'global (;.*mut (ref null' .tmp/dew-runtime-trait-evidence-provider.wat)" -eq 2
wasm-tools parse \
  tests/abi-consumers/runtime-trait-evidence-i32.wat \
  -o .tmp/dew-runtime-trait-evidence-consumer.wasm
node tools/dew-wasm-consumer.mjs \
  .tmp/dew-runtime-trait-evidence-provider.wasm \
  .tmp/dew-runtime-trait-evidence-consumer.wasm \
  run i32 > .tmp/dew-runtime-trait-evidence-consumer.json
grep -q '"type":"i32","value":673' \
  .tmp/dew-runtime-trait-evidence-consumer.json
(
  cd tests/abi-consumers/imported-package
  ../../../tools/dew check
)
rm -rf .tmp/dew-external-package-cache \
  .tmp/dew-versioned-package-changed \
  .tmp/dew-versioned-package-invalid \
  .tmp/dew-versioned-interface-invalid
DEW_CACHE_DIR=.tmp/dew-external-package-cache tools/dew check \
  --cache-report \
  --manifest tests/abi-consumers/imported-package/dew.json \
  > .tmp/dew-external-package-cache-miss.txt
DEW_CACHE_DIR=.tmp/dew-external-package-cache tools/dew check \
  --cache-report \
  --manifest tests/abi-consumers/imported-package/dew.json \
  > .tmp/dew-external-package-cache-hit.txt
grep -q '^standard interface cache: hits 0, misses [1-9][0-9]*$' \
  .tmp/dew-external-package-cache-miss.txt
grep -q '^standard interface cache: hits [1-9][0-9]*, misses 0$' \
  .tmp/dew-external-package-cache-hit.txt
test "$(find .tmp/dew-external-package-cache/interfaces -name 'v13-*.dwi' | wc -l)" -eq 1
rm -rf .tmp/dew-artifact-only .tmp/dew-artifact-cache
cp -R tests/abi-consumers/imported-package .tmp/dew-artifact-only
DEW_CACHE_DIR=.tmp/dew-artifact-cache tools/dew build \
  --manifest .tmp/dew-artifact-only/dew.json \
  -o .tmp/dew-artifact-before.wasm
artifact_file=$(find .tmp/dew-artifact-cache/packages -name 'v1-*.dpa')
test -f "$artifact_file"
rm -rf .tmp/dew-artifact-only/dependency
DEW_CACHE_DIR=.tmp/dew-artifact-cache tools/dew build \
  --manifest .tmp/dew-artifact-only/dew.json \
  -o .tmp/dew-artifact-after.wasm
cmp .tmp/dew-artifact-before.wasm .tmp/dew-artifact-after.wasm
test -f .tmp/dew-artifact-only/dependency/callback.dew
cp -R tests/abi-consumers/imported-package \
  .tmp/dew-versioned-package-invalid
printf '\n' >> \
  .tmp/dew-versioned-package-invalid/dependency/callback.dew
if tools/dew check \
  --manifest .tmp/dew-versioned-package-invalid/dew.json \
  > .tmp/dew-versioned-package-invalid.txt 2>&1; then
  echo "expected external package integrity mismatch to fail visibly" >&2
  exit 1
fi
grep -q 'dependency integrity mismatch for @fixture/package-callback@1.0.0' \
  .tmp/dew-versioned-package-invalid.txt
cp -R tests/abi-consumers/imported-package \
  .tmp/dew-versioned-interface-invalid
node --input-type=module -e '
  import { readFile, writeFile } from "node:fs/promises";
  const path = ".tmp/dew-versioned-interface-invalid/dew.lock";
  const lockfile = JSON.parse(await readFile(path, "utf8"));
  lockfile.packages[0].interface = "0".repeat(64);
  await writeFile(path, `${JSON.stringify(lockfile, null, 2)}\n`);
'
if tools/dew check \
  --manifest .tmp/dew-versioned-interface-invalid/dew.json \
  > .tmp/dew-versioned-interface-invalid.txt 2>&1; then
  echo "expected external package interface mismatch to fail visibly" >&2
  exit 1
fi
grep -q 'dependency interface mismatch for fixture.package_callback' \
  .tmp/dew-versioned-interface-invalid.txt
cp -R tests/abi-consumers/imported-package \
  .tmp/dew-versioned-package-changed
printf '\n' >> \
  .tmp/dew-versioned-package-changed/dependency/callback.dew
changed_integrity=$(tools/dew package-integrity \
  .tmp/dew-versioned-package-changed/dependency/dew.json)
node --input-type=module -e '
  import { readFile, writeFile } from "node:fs/promises";
  const path = ".tmp/dew-versioned-package-changed/dew.lock";
  const lockfile = JSON.parse(await readFile(path, "utf8"));
  lockfile.packages[0].integrity = process.argv[1];
  await writeFile(path, `${JSON.stringify(lockfile, null, 2)}\n`);
' "$changed_integrity"
DEW_CACHE_DIR=.tmp/dew-external-package-cache tools/dew check \
  --cache-report \
  --manifest .tmp/dew-versioned-package-changed/dew.json \
  > .tmp/dew-external-package-cache-changed.txt
grep -q '^standard interface cache: hits 0, misses [1-9][0-9]*$' \
  .tmp/dew-external-package-cache-changed.txt
test "$(find .tmp/dew-external-package-cache/interfaces -name 'v13-*.dwi' | wc -l)" -eq 2
tools/dew build \
  --manifest tests/abi-consumers/imported-package/dew.json \
  -o .tmp/dew-imported-package-provider.wasm
(
  cd tests/abi-consumers/imported-package
  ../../../tools/dew build -o ../../../.tmp/dew-convention-provider.wasm
)
cmp .tmp/dew-imported-package-provider.wasm \
  .tmp/dew-convention-provider.wasm
node tools/dew-abi.mjs \
  .tmp/dew-imported-package-provider.wasm interface \
  > .tmp/dew-imported-package-abi.json
node --input-type=module -e '
  import { readFile } from "node:fs/promises";
  const [actual, expected] = await Promise.all([
    readFile(".tmp/dew-imported-package-abi.json", "utf8").then(JSON.parse),
    readFile("tests/abi-consumers/imported-package/expected-abi.json", "utf8").then(JSON.parse),
  ]);
  if (JSON.stringify(actual) !== JSON.stringify(expected)) {
    throw new Error("imported package ABI metadata changed");
  }
'
node tools/dew-wasm-consumer.mjs \
  .tmp/dew-imported-package-provider.wasm \
  .tmp/dew-aggregate-callback-consumer.wasm \
  run i32 \
  fixture.application \
  76ac0d3c571b64871213749dcc9029f7a44646524de117d87175787c8fbdc6f3 \
  > .tmp/dew-imported-package-consumer.json
if node tools/dew-wasm-consumer.mjs \
  .tmp/dew-imported-package-provider.wasm \
  .tmp/dew-aggregate-callback-consumer.wasm \
  run i32 \
  fixture.application \
  0000000000000000000000000000000000000000000000000000000000000000 \
  > .tmp/dew-incompatible-package-consumer.txt 2>&1; then
  echo "expected incompatible package interface to fail visibly" >&2
  exit 1
fi
grep -q 'interface fingerprint mismatch for fixture.application' \
  .tmp/dew-incompatible-package-consumer.txt
grep -q '"type":"i32","value":42' \
  .tmp/dew-imported-package-consumer.json
tools/dew build \
  tests/module-snapshots/generics/generic-enum-adapter-runtime.dew \
  -o .tmp/dew-enum-adapter-budget.wasm
tools/dew build \
  tests/module-snapshots/generics/generic-cyclic-aggregate-adapter-runtime.dew \
  -o .tmp/dew-cyclic-adapter-budget.wasm
tools/dew build \
  tests/module-snapshots/generics/generic-nested-aggregate-adapter-runtime.dew \
  -o .tmp/dew-nested-aggregate-budget.wasm
tools/dew build \
  tests/module-snapshots/functions/mutable-local-runtime.dew \
  -o .tmp/dew-mutable-cell-budget.wasm
tools/dew build \
  tests/module-snapshots/functions/generic-function-specialization-runtime.dew \
  -o .tmp/dew-materialized-specialization-budget.wasm
tools/dew build \
  tests/module-snapshots/functions/closure-directization-runtime.dew \
  -o .tmp/dew-closure-directization-budget.wasm
node --input-type=module -e '
  import { readFile } from "node:fs/promises";
  const bytes = await readFile(".tmp/dew-cli-smoke.wasm");
  const module = await WebAssembly.compile(bytes);
  const abiSections = WebAssembly.Module.customSections(module, "dew.abi");
  if (abiSections.length !== 1) {
    throw new Error("production binary lacks one dew.abi section");
  }
  const testSections = WebAssembly.Module.customSections(module, "dew.tests");
  if (testSections.length !== 0) {
    throw new Error("production binary contains dew.tests");
  }
  const metricSections = WebAssembly.Module.customSections(module, "dew.metrics");
  if (metricSections.length !== 1) {
    throw new Error("production binary lacks one dew.metrics section");
  }
  const metrics = new Uint8Array(metricSections[0]);
  if (
    metrics.length !== 8 ||
    metrics[0] !== 0x44 ||
    metrics[1] !== 0x57 ||
    metrics[2] !== 0x4d ||
    metrics[3] !== 0x31 ||
    metrics.slice(4).some((value) => value !== 0)
  ) {
    throw new Error("production binary contains invalid static metrics");
  }
'
wasm-tools parse \
  tests/module-snapshots/functions/generic-function-specialization-runtime.wat \
  -o .tmp/dew-missing-metrics.wasm
if node tools/wasm-metrics.mjs \
  tests/module-snapshots/functions/generic-function-specialization-runtime.wat \
  .tmp/dew-missing-metrics.wasm \
  > .tmp/dew-missing-metrics.txt 2>&1; then
  echo "expected missing dew.metrics metadata to fail visibly" >&2
  exit 1
fi
grep -q 'expected exactly one dew.metrics custom section, got 0' \
  .tmp/dew-missing-metrics.txt
cat > .tmp/dew-malformed-metrics.wat <<'EOF'
(module
  (@custom "dew.metrics" "bad")
)
EOF
wasm-tools parse .tmp/dew-malformed-metrics.wat \
  -o .tmp/dew-malformed-metrics.wasm
if node tools/wasm-metrics.mjs \
  .tmp/dew-malformed-metrics.wat \
  .tmp/dew-malformed-metrics.wasm \
  > .tmp/dew-malformed-metrics.txt 2>&1; then
  echo "expected malformed dew.metrics metadata to fail visibly" >&2
  exit 1
fi
grep -q 'unsupported or malformed dew.metrics custom section' \
  .tmp/dew-malformed-metrics.txt
if tools/dew check --no-default-preamble \
  tests/cli/no-default-preamble.dew > .tmp/dew-no-preamble-error.txt; then
  echo "expected no-default-preamble source to lose implicit assert" >&2
  exit 1
fi
grep -q 'UnknownValueName' .tmp/dew-no-preamble-error.txt
tools/dew check --no-default-preamble \
  tests/cli/no-default-explicit-preamble.dew
if tools/dew check tests/module-snapshots/names/unknown-value.dew > .tmp/dew-cli-error.txt; then
  echo "expected dew check to reject an invalid source" >&2
  exit 1
fi
grep -q '^tests/module-snapshots/names/unknown-value.dew:2:3: error: UnknownValueName' \
  .tmp/dew-cli-error.txt
grep -q '^2 |   missing_value$' .tmp/dew-cli-error.txt
grep -q '^  |   \^$' .tmp/dew-cli-error.txt
tools/dew test --module dew.std std/tests/core_test.dew
tools/dew test --manifest tests/cli/test-package/dew.modules.json
tools/dew test \
  --manifest tests/cli/test-package/dew.modules.json \
  --list \
  > .tmp/dew-manifest-tests.txt
tail -n 2 .tmp/dew-manifest-tests.txt > .tmp/dew-manifest-test-identities.txt
cat > .tmp/dew-manifest-test-identities.expected <<'EOF'
fixture.library::tests/cli/test-package/library_test.dew::library answer
fixture.main::tests/cli/test-package/main_test.dew::linked answer
EOF
cmp .tmp/dew-manifest-test-identities.expected .tmp/dew-manifest-test-identities.txt
if tools/dew test \
  --module cli.message \
  tests/cli/assertion-message_test.dew \
  > .tmp/dew-assertion-message.txt 2>&1; then
  echo "expected failing assertion fixture to fail" >&2
  exit 1
fi
grep -Fq 'assertion failed: visible assertion λ' .tmp/dew-assertion-message.txt
if grep -q 'Traceback' .tmp/dew-assertion-message.txt; then
  echo "dew test leaked a Python traceback" >&2
  exit 1
fi

echo "== declarative ABI and performance cases =="
python3 tools/check-architecture-cases.py --performance
