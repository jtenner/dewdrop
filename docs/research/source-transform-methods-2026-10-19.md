# Source transform methods and source execution

Baseline: `a2a95cb4b5`. This pass follows the first source-transform interpreter.
The public status list is `docs/transform-features.md`; the usage guide is
`docs/compile-time-transforms.md`.

## Implementation

Calls and function values retain their checked source target and checked result
type. Source spelling cannot select a same-named fallback after an unsupported
checked dispatch. Constructor selections keep their own identity namespace;
variant IDs and declaration IDs must not be interchanged.

The interpreter executes instance/static methods, concrete trait bodies,
custom operators, indexed reads, closures, callbacks, and mutable records.
Record aliases share fields. Closures share captured cells and isolate return
flow. Named source function values can return further function values.

Standard Array methods execute their Dew source. The VM supplies a bounded set
of scalar Wasm operations and GC array operations. Raw arrays keep shared
storage and checked default element kinds. Array copies handle overlap and
check bounds before indexing. Array literal metadata comes from the checked
synthetic allocation block, after normal sugar lowering. It retains the actual
nominal type and field layout; it does not select a standard algorithm by a
module path or declaration number.

Some generic code carries a zero-initialized scalar inside a record or enum
before it reaches a concrete boundary. The VM retains a deferred default in
that case. Checked integer/Boolean literal patterns, fixed scalar syntax
builders, integer intrinsic inputs, and Boolean use preserve zero/false.
Prefix operations use a checked scalar result proof. An unknown or floating
prefix cannot infer an integer type from the default. Concrete numeric binary
operations can run their selected Dew primitive body when a deferred operand
has no direct scalar opcode proof. Generic trait evidence remains unsupported.

`FnNode.with_body`, `prepend`, `append`, `wrap`, and `returning` are ordinary Dew
methods. Expression methods and free builders cover calls, fields, indexes,
method calls, paths, wide integers, arrays, tuples, prefix operations, bindings,
assignments, blocks, and returns. Names, operators, paths, replacement shape,
and generated types remain checked. Append/wrap preserve ordinary early-return
behavior; they do not rewrite all returns in the old body.

The interpreter still has no host capability or second Wasm instance. Work,
depth, estimated allocation work, and output limits remain in force. The 4 MiB
limit is an accounting budget, not a hard process heap bound. Native and Dew
resource counts still differ. Typed AST reflection, signature/declaration
changes, quotation/hygiene, dynamic trait evidence, floats/SIMD, general text
execution, bytecode, and result caching remain open in the feature list.

## Regression evidence

Logs and the native example harness are in `.tmp/transforms-v2/`.

- `native-final.log`: 1,587 routine native tests passed before the final deferred
  default delta. `native-last.log` is the final focused transform/driver lane.
- `integration-final.log`: 272 integration tests passed.
- `hardening-final.log`: 1,035 Dew tests, emission corpora, and semantic probes
  passed, including the imported-static path regression.
- `defaults-red.log`: the new combined generic allocation/read/enum regression
  failed with the exact unsupported-equality diagnostic before its fix.
- `native-defaults.log`: that regression then passed with the other focused
  tests. `defaults.dew` covers matching, Bool use, negation, arithmetic, and
  scalar builders; the final lane also rejects floating default negation.
- `dew-last.log`: final focused Dew interpreter tests.
- `public-all.log`: all 17 earlier native public examples returned 42.
- `requests-final.log`: all 17 earlier Dew requests returned 42; six rejected
  requests retained diagnostics and wrote no output. Final request evidence adds
  the deferred-default example and floating-default rejection.
- `bootstrap-5.log`: clean self-build passed with identical B/C outputs.
  `bootstrap-6.log` covers the last deferred-default code.

The request tests run emitted Wasm and assert `main() == 42`. They cover
imported methods, receiver/argument order, mutable aliases, captured callbacks,
function factories, custom operators, record patterns, normal collections,
raw-array copy, inferred casts, defaults, and syntax builders. Rejection cases
cover bad signatures, sibling declarations, host calls despite a same-named
local function, out-of-bounds arrays, allocation limits, bad fields, an unsupported floating prefix, and a floating cast that could otherwise
retain an integer carrier.

## Measurements and limits

Environment: Linux x86_64, Node v24.21.0, wasm-tools 1.262.0. This is functional
validation, not a controlled speed or memory benchmark. Some lanes overlapped
and MoonBit file locks delayed host builds. Raw timings and the harness are
saved; lock waits must not be interpreted as Dew compiler execution time.

The earlier clean source build took 21.519 seconds; compiler A compiled B in
16.728 seconds, and B compiled C in 17.677 seconds (`bootstrap-5.log`). The
linked B/C SHA-256 was
`c551e9957dde34e041f08e681cddde3153f500afbd9f7d84e3e9774d3a59817e`.
That identity predates the last deferred-default delta; use bootstrap-6 for the
final identity.

The old debug transform test generation took 53.171 seconds. The routine script
now builds its native generator as a separate measured activity and uses the
release profile. The warm release generation took 5.110 seconds, linking took
1.158 seconds, and 11 tests ran in 0.071 seconds (`dew-final.log`). This is a
harness change; it is not a measured runtime gain in generated user code.
The final focused run includes one additional default test.

The broad hardening generation took 34.042 seconds, and one integration test
file took 35.627 seconds with overlapping work. Both exceed the project activity
limit and remain recorded performance issues. The native driver lane now runs
one owning file at a time; its final focused files stay below 30 seconds.
No hard heap bound, compiler allocation reduction, or generated-code speed gain
is claimed. No Wago execution result is claimed; real requests use the existing
Node facet host and require no new host API.

## Reviews

Independent GPT source audits found inferred result-type loss, missed lowered
array literals, explicit-return flow, nested function result projection, generic
name shadowing, and deferred defaults inside generic payloads. Each led to a fix
and a regression. A Dew audit also traced constructor/declaration identity and
imported static namespace paths. Reports and follow-up assessments are saved
beside the logs.

Claude was launched from the repository root with normal authentication and
read-only `Read,Glob,Grep` tools. It returned session-limit status 1, with reset
at 09:00 UTC. It did not review this delta. Its stdout, stderr, status, scope,
and neutral review request are in `.tmp/transforms-v2/review/`. No credential
or authentication setting was changed.


## Final validation

The final sequential run is `.tmp/transforms-v2/final-validation.sh`.

- `native-verified.log`: 61 focused native tests passed. The earlier full native
  lane passed 1,587 tests and the integration lane passed 272 tests.
- `dew-verified.log`: 12 focused Dew interpreter tests passed. The earlier broad
  Dew lane passed 1,035 tests and its emission/semantic probes.
- `requests-verified.log`: all 18 real compiler requests produced validated
  output with `main() = 42`. All eight invalid requests kept their required
  diagnostic and wrote no output file.
- `public-all.log` plus `defaults-verified.log`: all 18 native public examples
  produced `main() = 42`.
- `bootstrap-verified.log`: clean A/B/C self-build passed. Final linked and raw
  B/C SHA-256 is
  `fc6104a484866f0245aecf7bd223b16341c3da67bfef73111054f2bbd2fb22a6`.
  A's source build took 18.936 seconds. A compiled B in 16.155 seconds, and B
  compiled C in 16.239 seconds. The final sequential run avoids the MoonBit
  file-lock delay seen in the earlier 51.421-second bootstrap-6 source build.
- Final release test generation took 5.067 seconds, linking 1.135 seconds, and
  execution 0.071 seconds. Generated-source and public-API checks passed.

The final deferred-default case explicitly adds two defaults. The Dew primitive
path needed the scalar zero rules for that case; both VMs now preserve zero for
integer arithmetic and retain zero-divisor errors. The source regression covers
that path in both real compiler implementations.

A further safety check reproduced float bits entering integer execution through
an unsafe cast. The saved pre-fix Dew compiler produced -1065353216, whereas
negating the encoded F32 value would require -1082130432. `float-red.log` records
that output. Checked F32/F64 result kinds now cause an explicit unsupported
scalar diagnostic before integer execution. Both deferred-float negation and
ordinary float-cast execution have native and real Dew rejection regressions.
The first old-compiler attempt hit a cached missing-tool failure; the successful
red run used the pinned tool and the direct Node facet runner.

`native-default-closure-review.md` closes the generic default finding for checked
integer/Bool uses. Its scope predates the final float-cast check and does not
claim a full audit of floating or null-reference execution. No final Claude
assessment is claimed; its session-limit failure remains as recorded above.
