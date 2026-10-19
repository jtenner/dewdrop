# Self-hosted imported value types

The Dew compiler rejected `@constants.factor` in a module value initializer.
The native compiler accepted the same program. The Dew compiler reported
`INV-002` with `UnsupportedExpressionInference`.

Two missing steps caused this fault:

- Dew selected qualified import members only for calls and constructors. A
  qualified module value did not get its imported declaration or type.
- Dew froze public `let` declarations with `resolved.declaration_type()`. That
  table contains signature types, so a value initializer exported an error
  type. Native code freezes the inferred initializer type instead.

The fix selects public values through the module import scope and records their
declaration identities. Lowering uses those identities for `PlannedModuleValueGet`.
The import alias is consumed only after both the declaration and type are found.
Public initializer types are inferred before the final module interface is
frozen, in the existing dependency order. Primitive types remain direct type
references. Compound types use the existing type interner. Modules with no public
values skip this extra inference step.

The new regressions check:

- An imported I32 constant in a module initializer and function body, including
  both declaration reads in the lowered plan.
- Imported product and callback values that become public module values. Their
  exported types must retain their field, parameter, and result types.

## Validation

The local test harness is `.tmp/imported-constant-regression/run.sh`. It runs the
release native `dew_test_gen` and `self_host_link_fixture` binaries, then runs
`node tools/dew-test/run.mjs` on the resulting Wasm module. The harness uses all
production Dew compiler sources, the Starshine FFI source, and the five test
files below:

```text
self_host/compiler/semantic_imported_semantics_test.dew
self_host/compiler/semantic_imported_selection_test.dew
self_host/compiler/semantic_module_interfaces_test.dew
self_host/compiler/semantic_module_value_inference_test.dew
self_host/compiler/semantic_variant_selection_test.dew
```

The first regression failed before the fix with
`constant initializer has a resolved type`. Test generation took 4.943 seconds,
linking took 1.103 seconds, and execution took 0.066 seconds.

After the fix, the focused regression passed. Test generation took 4.981 seconds,
linking took 1.105 seconds, and execution took 0.062 seconds. The full related
set then passed all 57 tests. Test generation took 5.096 seconds, linking took
1.117 seconds, and execution took 0.150 seconds. These single runs establish
correct behavior; they do not establish a performance gain or memory bound.

No Moon build command was needed, so these checks had no Moon lock delay. The
separate final bootstrap and real transform request checks cover the complete
self-hosted compiler build.

## Shared type graph follow-up

Independent review found repeated work in the first conversion code. A type such
as `Pair<T, T>` has two edges to the same child type. Recursion without a cache
converted that child twice at each level. The native converter had the same
fault for public values. The first Dew change also converted private values
when the module had an unrelated public scalar.

Both converters now use one body-type-ID to resolved-type-ID map for each freeze
pass. All recursive edges use that map. All public value roots in the pass share
it. The Dew converter runs inside the public, non-test declaration export check.
It no longer converts each private initializer type into the interface arena.
Inference still checks private initializers and their dependencies.

New native and Dew tests use tuple and record type graphs at depth 20. They check
the resulting compound type, cache size bounds tied to the graph depth, reuse
for a repeated type ID, and no extra resolved types for a second public root.
A private tuple graph plus a public scalar must add no resolved types or type
arguments during freezing.

The final related Dew set passed all 59 tests: generation 5.335 seconds, linking
1.236 seconds, execution 0.166 seconds. The command
`DEW_NATIVE_TEST_PACKAGES=semantic tools/test-native.sh --filter 'frozen *'`
passed all four selected native tests in 9.031 seconds. There was no Moon lock
delay. Logs are in `.tmp/imported-constant-regression/memo-final.log` and
`.tmp/imported-constant-regression/native-memo-final.log`.

The independent timing harness freezes a private graph plus a public scalar ten
times per test. It uses three fresh Node processes for each case. Median
whole-process elapsed times in seconds were:

| Graph | Depth | Before | After |
| --- | ---: | ---: | ---: |
| Tuple | 8 | 0.069798 | 0.064185 |
| Tuple | 12 | 0.088510 | 0.066485 |
| Tuple | 16 | 0.376074 | 0.066963 |
| Pair<a,b> | 8 | 0.072391 | 0.069489 |
| Pair<a,b> | 12 | 0.085899 | 0.071730 |
| Pair<a,b> | 16 | 0.240923 | 0.081132 |

All 18 before runs and all 18 after runs passed. The same native generator and
linker binaries built both Wasm artifacts. The baseline converter is pinned to
commit `45e7f30335`. The harness, raw samples, exact source and binary hashes,
and Linux x86_64 / Node v24.21.0 environment record are under
`.tmp/imported-value-review/`. The independent review report is
`.tmp/transforms-v3/imported-value-review.md`.

These times include Node startup, Wasm compilation, parsing, inference, freezing,
and checks. Startup is a large part of the shorter runs. These are native-host
Node/Wasm measurements, not native Dew converter timings. No heap or production
code-size gain was measured. The cache adds one map entry per visited body type;
the tests check graph-size bounds, not a measured heap bound. Recursion still
uses stack space tied to graph depth. Existing type interning and other compiler
work can still add costs outside the cached traversal.
