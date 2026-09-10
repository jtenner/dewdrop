# Starshine local lifetimes, 2026-09-10

This follows the [loop-counter repair](starshine-loop-counter-2026-09-10.md).
The pass that first exposed the four remaining source failures was
`simplify-locals-nostructure`. The affected shapes were reduced before repair.

## Shapes and repairs

| Shape | Wrong behavior | Repair |
| --- | --- | --- |
| A result local receives different copies on two branch paths | The last textual path's value replaces the joined result: 10 becomes 20 | Clear equivalent-local facts at branch-bearing block exits |
| A local read remains on the Wasm stack while a later match overwrites that local | A sum changes from 3 to 4 | Preserve the pending read before the write during HOT lowering |
| An array allocation remains on the stack while its argument locals change | Length 1 becomes 9; an invalid write no longer traps | Preserve allocation inputs and local write order during HOT lowering |
| Tuple expansion inserts definitions and replaces old nodes with new reads | A new temporary is read before its definition | Keep replacement-value order separate from node slots; honor inserted region roots |

The branch-join repair is in Starshine `src/passes/simplify_locals.mbt`.
The lifetime repair is in `src/ir/hot_lower.mbt`. It covers both dependency
directions and writes within live control regions. Dead region tails do not
create false dependencies. `HotNode.order` adds one integer per node and follows
copied values into replacement slots without moving their order before the
replaced position. Lowering also caches the latest input order for each value;
a rewritten expression cannot move ahead of a new input definition. Cached
suffix bounds remain in use. A pending read must precede the write and belong
to a later consumer before it is treated as an old stack value. This preserves
new tuple temporaries and flattened arithmetic.
The existing tuple instruction-order tests were not relaxed.

Permanent fixtures and execution checks live in Starshine:

```sh
bun starshine-mb/scripts/test/simplify-locals-loop-runtime.ts \
  "$PWD/_build/native/release/build/jtenner/starshine/cmd/cmd.exe"
bun starshine-mb/scripts/test/simplify-locals-state-runtime.ts \
  "$PWD/_build/native/release/build/jtenner/starshine/cmd/cmd.exe"
```

The direct IR/pass tests failed before their respective fixes. Runtime tests
check actual values, the required bounds trap, and loop completion. Each child
has a timeout; failed artifacts remain available. The shared lowering fix also
repairs `code-folding` on `collections/fixed-array-runtime`.

## Separate Wago fault

`remove-unused-brs` was the first failing prefix for
`modules/imported-generic-callback-adapter-runtime` in Wago. Node passed.
A smaller input removes the compiler and optimizer entirely:
`tools/starshine-experiments/testdata/wago-typed-select.wat`. It creates one
struct, selects that same reference for either condition, then checks `ref.eq`.
Node completes; Wago reaches `unreachable`. This is a Wago typed-select runtime
fault, not evidence that the Starshine transform changes the Wasm meaning.
The Wago fault is now fixed in [PR #600](https://github.com/wago-org/wago/pull/600),
commit `9b961e298`. Both native backends had read only the first byte of the
result type, leaving the heap-type index in the opcode stream. The shared
immediate reader now consumes the whole type. All 24 new execution checks pass.
The rebuilt Wago CLI and snapshot runner pass the reduced input and original
Dewdrop prefixes 5, 6, and 12. Runtime/backend/Wasm tests and benchmark-package
tests pass; the ARM64 test binary cross-compiles. Full repository testing still
has two TinyGo duplicate-symbol link failures, reproduced on the unchanged
checkout. This is recorded in the PR. Dewdrop's default Wago checkout remains
unchanged while that PR is pending, so this candidate stays out of the profile.

## Scope

The four additional SLNS source failures were
`collections/fixed-array-set-oob-trap`,
`control-flow/float-literal-match-runtime`,
`types/derive-eq-generic-runtime`, and `types/derive-hash-runtime`.
An intermediate fixed-binary run passed all 410 executable source fixtures plus
51 expected source errors under six schedules, in both Node and Wago. Final
validation and measurements are recorded below after the tuple interaction fix.

Older full-SimplifyLocals short-circuit, OptimizeCasts, and Heap2Local defects
remain separately recorded in Starshine `agent-todo.md`. This change does not
claim to close the complete pass-family audit or all Binaryen output gaps.

## Final validation

Starshine commit `48d6337ce` contains the repair. The final native release build has SHA-256
`c12666b64811f3ed5548b28735d46d9eda85c098d81b12f3a83f57250bfcaf5f`.
It passes all 10,995 native tests and all 461 source fixtures under all six
candidate schedules, in both engines: 410 runtime cases and 51 expected source
errors. The 112 loop checks and four state fixtures pass with actual execution.
No existing tuple or flatten instruction-order expectation was weakened.

Fresh GenValid lanes use seed `0x5eed`, explicit prebuilt binaries, pinned
Binaryen 131, `--jobs auto --max-subprocesses 8`, and an artifact cap of 20.
Regular generation gives 10,000 canonical matches. Dedicated generation gives
10,000 output differences: 8,338 smaller and 1,662 larger canonical outputs,
2,194,316 versus 2,318,603 bytes. All 20 retained examples match the previous
loop-only binary byte for byte. These are older parity gaps; validation alone
cannot prove their runtime meaning. Neither lane has validation, generator,
property, or command failures. Both use 10,000 Binaryen cache hits and zero
misses. GenValid runtime execution is off; source execution is a separate gate.

| Activity | Seconds | Result |
| --- | ---: | --- |
| Scoped native public interfaces | 3.631 | Pass; only `HotNode.order` added |
| Full Starshine native suite | 307.876 | 10,995 pass |
| Native release optimizer build | 213.002 | Pass |
| Loop and state runtime checks | 0.693 | Pass |
| Six-schedule full source corpus | 134.814 | All expected checks pass |
| Regular GenValid, 10,000 cases | 72.222 | All canonical matches |
| Dedicated GenValid, 10,000 cases | 58.330 | Older output gaps remain |

The longest individual corpus command takes 9.230 seconds. Activities above
30 seconds remain recorded performance bugs. The compact
corpus, fuzz counts, tool identities, and prior-output replay are checked in at
`docs/research/data/starshine-lifetimes-2026-09-10/`. Binary artifacts and full
local logs remain in `.tmp/cli-optimization-logs/`.
