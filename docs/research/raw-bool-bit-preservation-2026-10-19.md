# Raw Bool bit preservation in compile-time execution

The Native and Dew transform VMs now keep the full checked Wasm i32 bits of a
Bool value. Ordinary 0 and 1 values still use `Boolean`. Other values use the
existing `Number(bits, "Bool")` variant, with bits masked to 32 bits. No model
variant, host API, normal emitter instruction, or serialized format changed.

Previously, a checked Bool result was reduced to `bits != 0`. A source builtin
that used `i32.add` to return Bool could produce 42 at runtime and 1 during a
transform. The same fault affected equal-carrier unsafe casts and `i32.load`.
The add control uses no unsafe instruction. The checked physical signatures
permit these i32 results; the implementation must preserve their bits.

## Value and control rules

Truth tests use nonzero, and logical not returns canonical 0 or 1. A Boolean AST
node also emits a canonical source literal. These operations accept checked Bool
values, not arbitrary integer kinds.

The result of `left && right` is the right operand unchanged when left is true,
or canonical false when left is false. The result of `left || right` is canonical
true when left is true, or the right operand unchanged when left is false. Both
VMs preserve short circuit, side effects, flow, and work accounting. Bytecode
still normalizes the skipped left result, but does not normalize an evaluated
right result.

Literal Bool patterns compare exact i32 bits against 0 or 1. Thus raw 42 is true
as a condition but does not match a literal `true` pattern. Mixed canonical and
raw Bool pattern comparisons work in either operand order.

Selected source Eq and Ne methods remain authoritative. A canonical Bool truth
table does not prove an i32 comparison for raw operands. Both execution paths
use the already checked Source target when a raw Bool operand reaches such a
shortcut. Canonical values keep their scalar fast path. The AST path performs
no extra target lookup for canonical values. No source name, module path, or
host implementation of a source algorithm selects this behavior.

For example, the current standard source Eq body returns its right operand
unchanged when its receiver is true. Explicit checked `.eq` on raw 42 and raw 17
therefore returns raw 17. Direct `i32.eq` on those values returns 0. The tests keep
these two behaviors separate.

## Validation

The baseline was `2203a33065`. Before the fix, the same checked sources gave:

| Probe | Ordinary Native runtime | Native transform |
| --- | ---: | ---: |
| I32 -> Bool -> I32 equal-carrier cast | 42 | 1 |
| i32.add declared Bool, then reveal bits | 42 | 1 |
| i32.load declared Bool, then reveal bits | 42 | 1 |
| Canonical 0/1 controls | 42 | 42 |
| Eleven source operator control bits | 2047 | 314 |

After the fix all ten original source forms match. Each Wasm module validates,
instantiates without imports, and runs after `__dew_init` when exported. Every
public operator helper is checked. All ten output sizes are unchanged, including
the canonical controls. This is an output-size check, not a runtime speed claim.

The committed pair in `tools/dew-test/raw-bool-bits` checks 23 public results in
each source form. It covers explicit selected Eq/Ne methods, two raw operands,
direct raw equality, truth/not, exact literal patterns, short-circuit side
effects, parameters/results, records, ordinary arrays, raw arrays, and memory.
Run it with `tools/test-runtime-raw-bool.sh`. The script builds the current Native
JS compiler unless a compiler path is supplied, validates the Wasm, initializes
each instance, and checks every expected result.

Final measured checks:

- Native VM: 103/103, 2.780s. Checked source: 2/2, 11.670s.
- Current Native JS compiler build: 2.057s.
- Paired ordinary/transform compilation, validation, and execution: 3.663s.
- Focused Dew tests: 7/7, 2.247s; generation 7.265s and link 1.579s.
- Existing Dew bytecode tests: 13/13, 0.110s. Memory source tests: 5/5, 4.192s.

The tree and bytecode unit controls check equal work and allocation ledgers and
restored call depth. Canonical values keep their current representation; raw
values reuse an existing payload shape. Peak host memory was not measured.

Exact commands, times, source/output hashes, before/after values, and compiler
identities are in `.tmp/transforms-v4/raw-bool-bits`. The final Native CLI SHA256
is `aa52e0e57208f71643bf89157fbfa65e3bd31b813a3afe2266821cc5b053a5a0`.
`after-original-ten.json`, `before-after.json`, `final-artifacts.json`,
`native-final.log`, `dew-final.log`, and `runtime-final.log` hold the final checks.
Earlier failed fixture checks remain visible in their logs. An unfiltered Dew
run took 37.762s and found the source-test assumption below; it is recorded as a
performance bug, not a passing full-suite result. The final tests use owning
filters.

## Separate Dew operator parity check

The ordinary Dew compiler has an existing primitive scalar fallback in
`semantic_imported_binary_operators.dew`: `constrain_imported_binary_operator`
returns before imported method selection when the receiver has a primitive
scalar type, including Bool. The transform trace for imported Bool `==` had no
checked Source target. The VM must retain its checked primitive behavior; this
fix does not invent a method target or change normal inference.

The shared source regression therefore uses explicit checked `.eq` and `.ne`
calls. Separate VM tests supply an exact checked Source operator target and
verify that both interpreter paths retain that body for raw Bool operands.
Native's original ordinary-versus-transform operator controls also pass.

Actual ordinary Dew `==`/`!=` execution against a fresh compiler is still pending.
An older compiler artifact rejected the new request fingerprint. No fresh
bootstrap was run for this bounded fix. The trace is evidence for a separate
parity investigation, not proof of the ordinary Dew runtime result or full
operator equivalence between compilers.
