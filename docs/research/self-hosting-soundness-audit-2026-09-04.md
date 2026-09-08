# Self-hosting soundness audit

## Scope

This note records the static audit of self-host compiler commit
`2f8d1488da73259dc49c584b50604a3d5af06f07`. The review covered type
inference, specialization, fragment and link planning, physical body planning,
trait evidence, and emission.

The common defect is loss of negative evidence. Missing or contradictory facts
can become `Unresolved`, `Ref`, zero, or a first candidate. Later recovery can
then make the invalid state look valid. The final Wasm check reports the effect
far from its source.

## Implemented hardening work

This work makes these changes:

- Compiler invariant failures write a stable numeric record before the trap.
  The host runner reads exported memory without calling the trapped guest.
  The trap path does not call `assert(false, message)`: that output path uses
  low-memory scratch and was overwriting the record. A compiled negative test
  reproduced the overwrite before this fix.
- `ConflictingBodyCarrier` is distinct from `UnresolvedBodyCarrier`.
- A carrier conflict is absorbing.
- Carrier `set` and `force` operations do not overwrite a different known
  carrier. They create a conflict.
- The body planner uses a deduplicated work queue and an exact reverse work
  graph. Expression nodes connect through syntax edges. Local and control hubs
  connect reads, writes, branch values, loop values, and body results.
- A changed fact schedules only its graph neighbors. There is no eight-pass or
  64-pass stop. A work-item-scaled change guard reports nonconvergence instead
  of freezing an unstable plan. A finite-height proof across all provenance
  and target updates is still required.
- A resolved negative logical type is no longer confused with the `-1` missing
  sentinel. This was the cause of the remaining `if` and `match` oscillation.
- Local, loop, pattern, return, call-target, call-result, and transfer-value
  changes are constraints before one freeze point. Verification and call-plan
  materialization do not change the carrier plan.
- New queue and call diagnostics include stable numeric codes.
- Each raw physical call has a source-order evaluation schedule and a separate
  physical operand recipe. `Unit` is evaluated without an operand. `Never`
  prevents the call and all later argument evaluation. Runtime receivers occur
  once. Namespace receivers occur zero times.
- Direct, namespace, and unresolved raw calls verify the physical target,
  operand count, operand presence, operand carrier, and result carrier in the
  planner and again at emission.
- Missing exact call-site mappings no longer select the first linked
  specialization. Link order is not ABI evidence.
- Function-name suffixes do not disable call-result checks.
- Generic fragment parameters and results use the resolved type and the
  matching generic parameter position. A generic method's nominal receiver
  keeps its reference representation; it does not take the payload's scalar
  representation.
- Linked result shapes come from the function fragment. A user method named
  `get_unchecked` returning `Box<I64>` previously became an `i64` result in
  the link helper. The new regression failed before this fix and now passes.
- The emitter's canonical-expression refinement helper cannot write to the
  body plan. A different carrier traps with `BOD-605`; an absent expression
  traps with `BOD-606`. A one-field carrier change in a valid source-derived
  plan reproduces the old mutation and now produces the exact failure record.
- Solver snapshots have monotonically increasing tokens, retained across
  reset. Equal arena lengths are not snapshot identity. Commit and rollback
  reject missing, stale, and out-of-order snapshots.
- Solver checks cover parallel variable and undo arrays, bounded parent walks,
  union-size overflow, valid undo kinds and indices, open snapshots at reset
  and zonk, and the signed resolved-type encoding limit. Undo restoration no
  longer substitutes zero for a missing array entry.
- Imported static methods use the declared owner and full logical signature.
  The old `FixedArray::make` rule based on the next module ID is gone. Method
  instantiation includes owner generic parameters. A same-signature factory
  on another type cannot win by link order.
- Imported static factories on primitive types also use logical owner identity.
  These types have no nominal declaration. An isolated builder fixture failed
  with unresolved types before this fix and now passes. It includes a factory
  on `BytesBuilder` with the same name and signature as the `StringBuilder`
  factory; a shared reference carrier is not sufficient owner evidence.
- A method body's direct `Self` parameter and result use the implementation's
  complete target type, including generic arguments. This is not yet a general
  substitution pass for nested `Self` types.
- Pending fields that precede each method call are checked before that call.
  The queues are in expression order, so this interleaving is linear. The final
  field pass retains fields not ready yet. Other inference dependencies still
  need a general work queue.
- Imported method candidates constrain the receiver to the implementation
  target, not only to the substituted `Self` parameter. This preserves logical
  distinctions such as `U32` versus `I32`, which share a physical carrier.
- Inherent methods on primitive types work in the current module and across
  imports. Owner checks use the logical primitive type; candidates still need
  a declared receiver and a compatible full signature. Tests cover `U32` and
  `I32` methods with identical physical signatures, and a string-view builtin
  result used by a method call.
- Concrete imported trait methods require one compatible receiver, argument,
  and result signature. Multiple candidates remain ambiguous. An applicable
  generic candidate produces an explicit unsupported-inference diagnostic;
  it cannot disappear so that a ground competitor wins. Full generic trait
  evidence is still required.
- The native Dew test generator now exits normally after reporting semantic
  errors. Its old abort could lose buffered diagnostics. One native rebuild
  after this entry-point change took 109.117 seconds, a performance fault.

The first stable codes are:

| Code | Meaning |
| --- | --- |
| SOL-201 | Variable arrays have different lengths. |
| SOL-202 | A parent walk left the arena or exceeded the variable count. |
| SOL-203 | A union size would overflow. |
| SOL-204 | A snapshot operation violates transaction order or identity. |
| SOL-205 | An undo record or parallel undo array is invalid. |
| SOL-206 | Reset or zonk was called with an open snapshot. |
| SOL-207 | A resolved type cannot fit the negative signed encoding. |
| BOD-601 | Conflicting known carriers reached body verification. |
| BOD-604 | Body carrier analysis did not converge. |
| BOD-605 | Emission attempted to change a frozen carrier. |
| BOD-606 | Emission requested an expression absent from the frozen plan. |
| BOD-607 | A call has no physical target. |
| BOD-612 | A value-returning body has no concrete root carrier. |
| ABI-701 | The planned target differs from the emitted target. |
| ABI-702 | A call evaluation is outside its arena. |
| ABI-703 | Logical arguments cannot map to the physical parameter count. |
| ABI-704 | A physical operand source has no body value plan. |
| ABI-705 | An operand carrier differs from its physical parameter carrier. |
| ABI-707 | Receiver count differs from the declaration ABI. |
| ABI-708 | An erased value reached the physical operand list. |
| ABI-709 | A call result differs from its linked result carrier. |

## Verification

Run the focused lane with `tools/test-self-host-hardening.sh`. It builds the
compiler sources as a Dew test module, links the pinned runtime providers,
runs the compiler-written test manifest, and independently checks the numeric
records from each negative invariant probe. No test passes only because an
arbitrary trap occurred.

The focused lane has 53 passing tests, including the existing local unification
tests. The previously failing cross-module ABI regression now passes. Source
fixtures also check inference diagnostics before they check the physical plan;
a valid-looking plan cannot hide an earlier inference failure.
Fifteen trap probes check all nine numeric fields after the trap. Two host
decoder tests check unsigned IDs, complete context, and rejection of absent or
unknown-version records. Generation takes about 2.5 seconds, linking 4.8 seconds,
and test execution 0.1 seconds. The queue tests cover a ten-cell scheduling
chain and exact dependent scheduling; they do not yet prove every production
transfer rule is at a post-fixed point.

The routine native lane passes all 752 tests in 19.229 seconds. The complete
native compiler/backend integration lane passes all 264 tests in about 36
seconds. The integration lane is over the 30-second project limit and remains a
performance fault.

The first pinned Starshine run stopped in the MoonBit linker with a stack
overflow. A retry with an unlimited process stack passed that point, reported
an existing validator case with an empty body for an `i32` result, and then made
no progress for more than three minutes. The run was stopped. This lane did not
produce a final test count and is also over the project time limit.

The latest self-host compiler-A build, including the solver checks, took
31.020 seconds. It passes raw and linked Wasm validation. Compiler A executes
the body planner in 10.530 seconds. The A build exceeds the 30-second limit
and remains a performance defect.

Compiler A stops in body planning with 6,744 numeric diagnostics instead
of emitting compiler B and reaching a late Wasm validation failure. The records
identify the module, declaration, body, specialization, expression, expected
carrier, and actual carrier. The corrected negative-type transfer removes
`BOD-604` from the current run. No `BOD-607` missing target appears either.
The remaining records are source-linked carrier, operand, and result failures.
Fourteen older diagnostic contexts still
have code zero and need stable IDs. The full bootstrap does not pass yet.

The first remaining record is `ABI-705` in `std/string.dew`, `slice`, expression
69, source offset 1467. The `view` operand has no known carrier; the linked
parameter requires a reference. The preceding initializer calls `string_view`.
The isolated string-view builtin/method fixture passes and does not yet
reproduce this full-program fault. The `StringBuilder::with_capacity` errors in
`std/path.dew` are gone. Counts fell from 10,027 to 9,293, then 6,750 after the
primitive factory fix, and 6,744 after primitive inherent-method support.
The full bootstrap still does not emit compiler B. Current counts by code are:
14 code-zero contexts, 4,485 `BOD-601`, 23 `BOD-612`, 2,105 `ABI-705`, and
117 `ABI-709`.

## Small cross-module regression

`imported fixed array permutation keeps its scalar operands` in
`self_host/compiler/semantic_physical_specialization_test.dew` reduces the
source pattern to two modules, three array builtins, an alias, and a permutation
loop. It originally reported four errors: two missing call targets (`BOD-607`),
one `i32`/reference conflict (`BOD-601`), and one operand mismatch (`ABI-705`).
The conflict was at the `0u32` argument to an imported static `make` call.
It now has no inference or physical-plan errors.

The nested-array-read test and the field/method dependency test also pass,
including clean inference. A separate static factory test verifies the selected
owner identity, not just its physical signature. Trait tests cover one valid
concrete selection, ambiguity, and a generic candidate that requires evidence.

The focused script runs trap-record and decoder checks even when a source
regression fails, and returns a failing exit status if any check fails.

The complete native compiler/backend lane first reproduced the Unit ABI defect
in `generic Unit specialization omits carrier parameters consistently`. The
emitter evaluated the Unit expression to an empty instruction fragment, then
emitted a nominal `ref.cast` for that erased logical argument. The cast saw an
empty stack. The emitter now calculates physical width before adapter emission
and emits no cast when the logical argument has zero physical width. The full
integration lane then passed 264 tests.

The first queue reduced compiler-A body planning from about 53 seconds to about
19 seconds. Exact reverse edges reduced it again to about 10.4 seconds.

The diagnostic-only semantic test command took about 80 seconds before it
reported its existing source-order/dependency errors. This is over the
30-second compiler budget and is not a usable regression lane in its current
form.

## Work still required

### Zero-error follow-up

The failure report now includes lowering and frozen facts for the first four
failing bodies. The first full trace showed poisoned direct builtin names in
`std/string.dew`, before body propagation, and 14,040 inference diagnostics in
the compiler module. Small same-module and imported-runtime slice fixtures
were clean, which isolated the difference to the full program's import setup.

Two source defects are fixed in this follow-up:

- Frozen standard interfaces now match the native publication rule. Internal
  helpers in `dew.std.text_runtime` and the preamble are published; private
  helpers in ordinary user modules and the four excluded string/byte modules
  remain private. The standard-runtime regression failed before the fix.
  The [September 8 update](module-source-visibility-2026-09-08.md) replaces that
  path-based exception with explicit library `pub` declarations and the same
  source-visibility rule for every module.
- The compiler entry point now applies the request's `default_preamble` flag.
  Its implicit import is a separate appended file, preserving existing file IDs
  and source offsets. Preparation does not mutate the supplied manifest. The
  disabled flag leaves it unchanged.

Those two fixes removed the string/byte slice and conversion failures. That
full run reported 6,720 planning diagnostics (A build 33.469 seconds, execution
11.353 seconds). It still did not emit compiler B.

A nested error-pattern fixture then reproduced nine carrier diagnostics.
Variant patterns were checked after their field uses, and nominal pattern
instantiation rejected an unknown subject even when the constructor declaration
was known. Variant binding now runs before member selection, and a selected
constructor constrains the subject using a fresh instance of its declared
nominal type. The same fixture is now clean in inference and body planning.
A different nominal subject still produces a type-constraint diagnostic.

The pattern fixes reduced the full-run diagnostics from 6,720 to 1,913
(A build 32.704 seconds; execution 10.984 seconds). The next first conflict was
an `Option<U32>` payload seeded from the generic reference field instead of its
payload-specialized runtime representation.

The link now has an explicit runtime-variant adapter table keyed by declaration
ID. Pattern selection and constructor verification use that table; ordinary
variants use their exact selected linked type. Runtime Option/Result payload
seeding no longer reads the erased generic reference field. The test for a user
`None` constructor reproduced a wrong runtime type, then exposed the same
source-name choice in constructor verification; both paths are fixed.

The runtime-adapter fixes reduced the full-run diagnostics from 1,913 to 40
(A build 32.392 seconds; execution 10.739 seconds). The build exceeds the
30-second performance limit. The compiler module still has 12,065 inference
diagnostics; fewer physical-plan errors do not establish clean inference.

Most of the remaining 40 errors involve `push` on empty array literals. Array
initialization looked up only a local `Array` declaration and otherwise used
a fresh base variable, losing the imported nominal identity before method
selection. A minimal imported-array regression failed with four inference
diagnostics. Looking up `Array` through the import scope fixes that regression.
The focused lane now passes 65 tests, 15 numeric failure-record probes, and
two host-reader tests. That fix reduced the full-run physical diagnostics to
25 (A build 33.940 seconds; execution 11.794 seconds). The compiler module
still had 11,698 inference diagnostics.

The next minimal case exposed missing imported `IndexedGet` selection.
Index operators now resolve the in-scope trait identity and compare local and
imported candidates together. Imported generic metadata records whether actual
prerequisite bounds exist, rather than confusing the number of generic
parameters with the number of proofs required. Unproved candidates stay
diagnostic. A second regression exposed index-to-method ordering; the field,
method, and operator queues now merge in arena order without another allocated
list. All 67 focused tests pass, along with the 15 numeric probes and two host
tests. The full run now reports three physical diagnostics at one call in
`SelfHostTypeResolver::new_with_imports` (A build 31.643 seconds; execution
11.096 seconds), with 8,750 compiler-module inference diagnostics. The
remaining call uses a local static factory that was classified as a variant
constructor, leaving its result poisoned. A regression reproduces that loss
before the subsequent instance-method call.

Two more index tests pass: duplicate imported methods remain ambiguous, and
a candidate with a trait prerequisite remains explicitly unsupported until
that proof is implemented. These tests brought the focused passing count to
69 before the new local-factory regression.

Local and imported static methods now share owner/signature selection; local
static generic methods instantiate both the implementation and method
parameters and bind `Self` to the implementation target. The local-factory
regression passes, bringing the focused count to 70. The full run reached zero
physical-plan diagnostics (A build 32.964 seconds; execution 14.395 seconds),
then stopped at emission because an unqualified imported `Some` pattern had
no selected constructor. Name resolution now includes variants of visible
opened imported types. The new identity regression passes.

While adding the local-method lookup, a nested `Some(Method(value))` pattern
exposed a native emitter defect: it placed a non-null reference binding in a
condition block, then read it from a later block where Wasm cannot prove it
initialized (`uninitialized local: 2`). The compiler lookup uses two explicit
matches for now. The native nested-pattern emission defect still needs its
own regression and fix; this source change is not a proof of that emitter.
That native regression now reproduces the error with an ordinary nested enum
pattern. Pattern-reference locals use defaultable nullable slots and narrow
on reads; the regression now passes (9.035 seconds including rebuild).

With imported variant names fixed, compiler A emitted compiler B, and both
core and linked B passed Wasm validation. Timings: A build 32.998 seconds,
A execution 75.440 seconds, B link 6.880 seconds. Both A build and execution
are performance bugs under the 30-second limit. B then trapped after 1.209
seconds in `blake3_iv`: its FixedArray factory returned a raw Wasm array, but
the caller tried to read an Array wrapper based on the `FixedArray::make`
spelling. That unproved result adapter has been removed. The next full run
must verify B can execute, not just validate.

A separate generic Box factory regression now has clean inference but exposes
five physical-plan errors: generic fields use erased reference storage while
the specialized constructor/read use I64. This remains an open representation
boundary, not a passing test. The focused lane currently reports 71 passing
tests and this one failure; all 15 numeric probes and two host tests pass.

After removing the factory unwrap, B again validated and progressed to a
second cast in `blake3_compress` (A build 36.130 seconds; A execution 76.662
seconds; B execution 1.206 seconds). The receiver recovery helper walked
through all field accesses, turning `output.input_chaining_value` into
`output`. Lowered expressions now retain the exact `member_base` even when
a method target is consumed. The planner and direct array emitter use that
identity instead of scanning backward or stripping the receiver's fields.
The new field-receiver regression passes. Current focused result: 72 passed,
one generic-Box representation failure. The full run still hit the same cast
(A build 31.702 seconds; A execution 75.458 seconds): an earlier specialized
array emission path contained its own field-stripping receiver logic. That
second copy now also uses `member_base` and the selected declaration's receiver
contract.

`tools/check-self-host-emission.mjs` now runs inside the hardening lane. It
asks the compiler to emit a small module, copies the returned opaque Bytes
through typed accessors, validates the Wasm, and runs `main`. The first probe
combines a FixedArray factory, a struct field, and an indexed method read. It
returns 7 in 0.210 seconds. Unexpected host calls throw; compiler assertion
output is printed, not discarded. This checks runtime heap identity, which
the existing scalar carrier checks cannot prove.

The next full run uses `SELF_HOST_CPU_PROFILE_DIR` to collect Node CPU profiles
in `.tmp/self-host-cpu-profile`. This optional setting does not change compiler
semantics and participates in the failure-cache key. The emission-time
performance issue needs measured hot paths, not another guessed scan limit.

Routine native verification passes all 753 tests. The slow native release
rebuild used by the hardening generator also exceeded 30 seconds after the
backend change; it is a separate build performance issue, not test execution
time. Native nested-pattern validation is now covered in the routine lane.

The scalar Array iterator runtime probe exposed another boundary: unbounded
generic trait implementations were rejected as if they required evidence.
Selection now uses the imported `requires_evidence` metadata and unifies the
generic signature. Actual bounds still require evidence. The positive scalar
iterator probe returns 6; competing unbounded implementations remain ambiguous.

CPU profiling attributed about 19 seconds to repeated global specialized-call
scans and 6 seconds to parameter lookups with an already known function index.
The link now builds one exact `(body, specialization, expression)` call index.
The body planner reuses it. Duplicate identical entries are idempotent; conflicting
entries trap with numeric SPC-303 context. Parameter lookup uses the checked
physical function table. A execution fell from 78.710 to 51.193 seconds; this is
still over budget. A build took 33.136 seconds and B link took 9.109 seconds.

That run produced valid B core and linked Wasm. B no longer trapped: it reached
physical planning after 14.062 seconds and reported 6,455 errors while compiling
C. A reported no physical errors for the same compiler source. This is a newly
reached stage, not a zero-error bootstrap. The first failing expressions include
qualified Option constructors. Name-resolution diagnostics now survive lowering
and appear in failure traces, to locate the earlier difference.

Generic declared fields now have explicit scalar boxing/unboxing adapters.
The erasure index accepts only a declared generic type, never Error or missing
evidence. Five immutable scalar box types give the erased reference storage a
defined representation. Field-read planning tracks the unboxed value separately
from field storage; constructor and field-write emission box scalar values.
Reference fields remain direct. The runtime regression uses I32 and I64 Box
instances together and returns 42. This trades an allocation at an erased scalar
field boundary for correctness; specialized aggregate layouts remain a performance
improvement, not permission to omit the conversion.

Current focused result: all 77 tests, 16 exact numeric failure probes, two host
record tests, and three emitted-code runtime probes pass. The runtime probes
take about 0.22, 0.01, and 0.002 seconds. The full next-stage run is still required.

The next B trace reports zero name-resolution diagnostics in the first failed
modules. A string-key Map runtime probe passes, so the initial map-lookup
hypothesis was not supported. A separate String parameter/field equality probe
returned 0 instead of 1: binary emission selected text equality only when an
operand could be traced to a literal. Two equal dynamically built strings were
compared by reference identity. Binary String equality and inequality now use
resolved primitive type identity. The regression now returns 1 and covers
parameter and field operands. This is directly relevant to imported-variant
selection, whose `self_host_basic_string_equal` wrapper compares two parameters.
Full B/C verification is pending; do not infer bootstrap success from the probe.

String equality reduced B's physical errors from 6,476 to 265 (A execution
52.405 seconds, B execution 10.232 seconds). A nested variant regression then
returned 22 instead of 12: match emission tested only the outer constructor.
Nested predicates now short-circuit behind each parent tag before loading child
fields. That fixes incorrect Bool seeding for numeric negative expressions in B.
The next full run reported 219 errors (A 52.793 seconds, B 9.869 seconds).

A second nested-pattern runtime probe exposed dropped bindings: a nested I64
payload read returned zero instead of 42. Nested binding emission now follows
the proven field path and checks each stored value against its frozen local.
Both nested runtime probes pass. Scalar/Bool and String nested literals have
explicit comparison recipes; unsupported literal forms report an emission error
instead of matching merely by the outer tag. The next full run includes the
binding fix. The remaining first failures are primitive `into` selections.

The binding fix did not reduce those 219 errors. The expanded inference trace
shows 100 allegedly viable `into` candidates, not a missing physical target.
Signature instantiation now asserts that its completed result stack has exactly
one entry (SOL-206); that invariant passes in B, so a missing stack result is not
the explanation. A small Array<Task>/Array<I32> stack probe also returns the
expected -507 after executing push, pop, truncate, and scalar result reads.

That probe exposed a separate inference defect: when both `if` branches diverge,
assignability skipped both Never inputs and left the result unconstrained. The
join now records Never explicitly. Runtime fixture construction also checks each
module's parse/collection diagnostics, not merely manifest diagnostics. Malformed
fixture source can no longer turn into a later missing-call report.

INV-002 now stops the main compilation path if name, signature, or body inference
diagnostics remain before specialization. The prior zero-physical-error A result
was not proof of zero semantic errors. That boundary initially found 7,362 errors.
Selected imported namespace calls retained provisional unsupported flags on both
selectors; clearing those only after selection reduced the count to 5,984.
Diagnostic reports now group errors by kind and include exact source file paths
and expression IDs where available.

Two more source defects were reproduced with small failing tests: struct checks
indexed the top-level declaration arena by a semantic ID that also counts methods,
and monomorphic Never call results reached branch joins too late. Struct lookup
now uses the declaration-location table and checks stored identity. Proven Never
results are seeded before joins, without spelling-based classification or an
overloaded imported target guess. The full count fell to 5,082, with no remaining
math, testing, or blake3 diagnostics.

Field assignment validation now runs after field selection and checks the selected
field's mutability. Local/captured values retain their own write checks. Positive
mutable-field and exact immutable-field negative tests pass. This reduced the full
count to 4,870. An all-Never match join now records Never instead of leaving an
unused fresh result, reducing the count to 4,745.

Foreign namespace calls were incorrectly queued as receiver methods. They now
resolve by foreign-library identity and member name, then apply their complete
signature without a receiver. Tests distinguish two libraries with equal member
names and require an exact argument-count error. The last completed focused lane
has 86 passing tests, 16 numeric probes, two host tests, and nine passing emitted-code
probes. Full bootstrap is still not complete. Native compiler A builds take
32–35 seconds and remain a measured performance defect.

Foreign-call selection reduced the semantic count from 4,745 to 30. Local trait
implementations were also omitted from candidate selection. They now share the
candidate count with imported implementations; a local/imported ambiguity test
requires both candidates. This reduced the count to 14.

Declared local generic bounds now retain a `BoundTraitBasicCallTarget` record
with requirement ID, receiver generic ID, bound type, and type arguments. This
is deliberately distinct from an implementation selection. Additional method
prerequisites remain explicit unsupported evidence. Undeclared and competing
bounds have negative tests. The semantic count fell to four.

Block initialization replaced expression type slots after parent blocks had
already copied their old cells. It now unifies those cells instead. The initial
bare-brace regression fixture was invalid Dew syntax; the single-module fixture
helper now rejects parse/collection errors, and the corrected nested Unit/I32
case verifies that a result mismatch cannot disappear. The full semantic gate
now reports **zero** errors.

The next physical boundary initially found 21 errors. An all-Never match started
its branch join at Unknown, erasing Never. Its parent restored Never, creating a
real worklist cycle. The branch join now starts at Never. Proven non-fallthrough
expressions retain their flow fact across ABI seeding and physical setters. A
Never call is accepted only with both declared divergence and an empty physical
result signature, or when a diverging argument prevents call emission. The
physical count fell to three missing bound-method implementation targets.

Specialization requests now include receiver identities for trait-bound generic
slots. Scalar physical equality does not merge I32 and U32 evidence, and eqref
does not merge distinct nominal receivers. Keys compare evidence structurally and
copy it on insertion. Bound dispatch uses the recorded receiver identity, exact
trait identity, and exactly one concrete implementation. Unknown identities,
applied bounds, and generic implementation prerequisites cannot select a target
through this path. The existing exact call map records the resulting target, and
emission checks the bound-to-implementation relation. A runtime probe with two
eqref receiver types calls different methods and returns the expected sum 10.
Full applied-type evidence and generic-implementation dispatch remain work items.

This new source exposed a native backend error: an early array return emitted a
broad nullable local directly into a precise non-null function result. Early
returns now use the same checked reference narrowing as body tails, with the
exact linked specialization in the emission context. The isolated native
regression failed Wasm validation before the fix and passes after it. All 754
routine native tests pass. The release rebuild took about 110 seconds; a parallel
test lane also recorded lock-wait time. Those are build/performance defects, not
slow execution of the small regression. Ten emitted-code runtime probes pass.
The host probe runner reports every probe failure and exits unsuccessfully after
the full list, rather than losing later failures after the first exception.

The smoke compiler build now discovers its non-test source modules, as the full
bootstrap and hardening lanes do. Its old manual list omitted newly split modules.

Continue tracing `BOD-601`, `ABI-705`, and `ABI-709` records. Contradictory facts
must not become unresolved again. Other emitter name-based adapter paths
still require review.

The call recipe has source variants for trait evidence, closure environments,
and runtime context values. The planner does not create those hidden operands
yet. A call that needs one fails `ABI-703` or `ABI-704` instead of guessing.
Specialized builtin adapters still need the same explicit stack-effect records
as raw physical calls.

The remaining audit items are concrete full Wasm reference types, lambda-span
checks, checked relative indices, SCC partition checks, explicit trait-cycle/
limit results, shadow-stack emission checks, and native/self-host phase
snapshots. Solver rollback still needs an exact state-equivalence test across
all scratch arenas and generation marks; the checks added here are not that
proof. Solver failure records currently have module context but no owning
declaration/body context; that context must be threaded into solver jobs.
Specialization still needs rejection of Generic and Error at its
physical boundary. All remaining name-based representation choices need
identity-based replacements.

### Bootstrap semantic differential checks

The next full run completed A-to-B with zero semantic and physical planning
diagnostics. B core and linked B both passed Wasm validation. B-to-C stopped at
INV-002 with 1,512 semantic diagnostics, including hundreds of conversion calls
that each incorrectly accepted 100 method candidates. This is not a successful
bootstrap: structurally valid B still disagrees with A.

The phase report now includes signature diagnostic ranks and source offsets.
The 35 signature errors in that run are type arity errors, not parse errors.
A separate emitted-code probe checks negative resolved-type integers, method
early returns from a loop, mutation before return, and String literal matching.
It passes. The hardening lane now has 11 emitted-code probes, plus direct pure
primitive-interner and transactional-solver checks. A test-only host runner
checks each result; the compiler also accepts `--check-semantic-probes` so the
same checks can run inside B, whose ordinary Wasm export is only `main`.

Bound-call specialization now checks the saved call kind before searching the
program callable table. Ordinary calls do not need a bound-evidence search.
Full builds still exceed 30 seconds and remain performance defects.

The B preflight reproduces one ambiguity in a two-module, two-conversion fixture.
Its receiver is the correct resolved U32 type (`-6`). Primitive interning,
primitive import, imported implementation receiver types, imported callable
result round trips, primitive signature instantiation, basic return mismatch
detection, and solver rollback pass separate checks. The small fixture still
fails in B, so these passing checks do not discharge call selection.
`SOL-208` records a primitive signature instantiation that changes type, with
the owning body and the exact expected/actual encoded types.

Emitted modules now carry standard Wasm function-name metadata with declaration
and specialization IDs. This is debug data, not semantic evidence. Each emitted
runtime probe checks that the name table identifies the actual `main` export
index and has no duplicate function indices. The String map probe now uses two
distinct keys plus a missing key, rather than one successful lookup. Eleven
emitted-code probes and four direct semantic probes pass in A; B's import/call
selection probe remains a visible failure.

### Pattern guards were omitted by emission

The named B core made the defect directly visible: the compiled
`constrain_imported_ground_trait_method_call` tested `trait_type is Some(_)`,
then incremented the candidate count without calling
`imported_method_candidate_viable`. The rest of the source condition after
`&&` was an HIR pattern guard. The emitter evaluated guards for catch-all arms
but silently omitted them for variant arms.

The emitted-code regression returned 52 instead of 461 before the fix. It
covers true and false guards, guards that read pattern bindings, failed patterns
that must not evaluate the guard, ordinary guarded match arms, and `is ... &&`
conditions. Each guard has an observable counter increment.

Variant and literal patterns now combine their complete match predicate with a
guard in a Boolean `if`: bind locals and evaluate the guard only on the true
branch, produce false otherwise, then select the arm body or the shared next-arm
path. Guard chains do not duplicate subsequent arms. The regression now returns
461, and all 12 emitted-code probes passed at that checkpoint. The full bootstrap
had not yet run; the focused test alone was not a zero-error bootstrap claim.

### Full bootstrap reaches zero compiler errors

`tools/check-self-host-bootstrap.sh --fast` now passes the complete A → B → C
run. Both generations have zero semantic and physical planning diagnostics.
B and C pass Wasm validation. The bootstrap script's three byte comparisons
(core, raw linked compiler, and prepared compiler) all pass.

The linked B and C SHA-256 is identical:
`5e0dfc06ff4900e361597eac3cbf2f243a51f133bac7e5cba51e69afea5f12a6`.
No error gate or verifier was disabled to obtain this result.

The focused lane passes 92 tests, 16 numeric invariant trap checks, two host
record-decoder tests, 13 emitted-code execution probes, and four direct semantic
probes. The thirteenth execution probe covers literal guards and verifies that
nonmatching literals do not run guard side effects. B also passes all four
semantic preflight checks inside its own compiled code.
The same four checks pass in C (0.066 seconds). The final routine native lane
also passes all 754 tests with zero failures. Its slowest package is semantic
(9.820 seconds), followed by backend (7.488 seconds); no native test package
exceeds 30 seconds in this final run. `git diff --check` is clean.

Performance is still not at the required threshold: native A build took 32.522
seconds, A-to-B execution 62.600 seconds, and B-to-C execution 63.097 seconds.
Linking took approximately 6.5 seconds per stage. These are recorded performance
defects, not compiler correctness failures. The remaining audit obligations
listed above are still open; a bootstrap fixed point is not a proof of every
compiler invariant or ABI case.
