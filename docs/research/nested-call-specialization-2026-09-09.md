# Nested generic call specialization

Ordinary generic calls with tuple-valued type arguments could fail SPC-301.
Both compilers substituted a direct generic parameter, but left generic
parameters inside a tuple unchanged. A source-only regression reproduces this
without Array literals, so the correction is separate from the literal trial.

Native program call planning now uses the existing body-value substitution
helper. This covers both inferred and resolved product types, and applies to
function references as well as direct calls.

The self-host compiler uses a type work queue with one caller substitution
environment. A completed-result cache preserves shared subgraphs. Active
nodes remain separate, so a cycle is not treated as a completed result.
The walk handles inferred/resolved products, resolved aliases, and applied
type bases. It checks visited arenas, product spans, shape argument spans,
and resolved-type encoding before indexing or arithmetic. It retains Error
and Generic evidence instead of inventing a reference type.

This is physical shape substitution, not a full logical type/evidence-graph
validator: nominal arguments and callable signatures retain their separate
checks. The native shared shape helper still has recursive traversal; this
change does not close the complete graph-validation audit.

Tests include nested call requests, recursive generic calls at runtime,
Unit fields, 128 levels of shared product nodes, a one-edge product cycle,
and an invalid caller argument span. Runtime cases test six I64 values,
including both signed limits. Failure-record checks require all nine fields.

Measured checks so far:

- Native ordinary-call regression: fails in 12.333 seconds; passes after the
  fix in 10.753 seconds.
- Native product/Array backend corpus: six pass in 2.609 seconds during the
  literal trial. Array shared execution: 30 pass after a 6.505-second build.
- Self-host baseline: 878 pass, one expected positive-case failure in 102.862
  seconds. The existing SPC-301 record identifies the nested call.
- First self-host implementation build: 36.961 seconds, rejected assignment
  expressions in match arms. Corrected arms use blocks.
- Self-host implementation: 879 tests, 459 exact records, and all existing
  shared checks pass in 104.548 seconds.
- Added shared runtime cases: all 276 native callback checks pass after a
  2.108-second build.
- Added graph test fixtures initially fail parsing in 43.365 seconds because
  object fields need line breaks. Fixtures are corrected without weakening
  the assertions.

Final checks run with the Array literal trial removed from production source,
so this fix can be committed and verified independently.

- Isolated native ordinary-call regression: one pass in 11.190 seconds.
- The expanded self-host run exposed two test-fixture defects: a cycle record
  expected the wrong node ID, and the standalone callback source used an
  undeclared `unreachable`. The fixture now asserts its node IDs before mutation
  and declares the one-to-one Wasm intrinsic. No compiler guard was removed.
- With those corrected, 884 tests and 463 exact records passed in 93.278
  seconds, but the shared Unit callback exposed a real emission defect:
  `nested_tuple_forward<Unit>` emitted a product without its Unit storage
  marker. The emitter read the unspecialized source shape (`Generic`) instead
  of the frozen specialized child shape (`Unit`). It now reads the checked
  frozen plan. Unit remains absent from logical call operands; only product
  storage gets its required null marker.
- The corrected full hardening run passes in 86.975 seconds: 884 tests,
  463 exact records, 276 shared specialization callback checks, and all other
  shared emission, library, and semantic probes. The callback corpus exercises
  both nested I64 and Unit products through recursive ordinary generic calls.

Clean bootstrap passes in 207.441 seconds. Compiler B/C core and linked bytes
match; their raw and linked SHA-256 is
`312f78fbea5f7033a6d5f76adf377acfea6e3361d85e750dc9284ca55e818151`.
No provider bindings changed. The full native and integration suites have not
been rerun for this isolated fix; the focused native regression, shared native
callback corpus, full self-host hardening lane, and clean bootstrap are the
verified scope.
All compiler runs above 30 seconds remain timing defects; speed work is deferred.
