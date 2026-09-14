# Imported types and short constructor names

Date: 2026-09-10

## Scope

This note records the initial source review and the subsequent implementation.
The initial findings below describe the source before the changes.

The aim is to remove redundant type prefixes from compiler Dew source in both
expressions and patterns. Inference must use ordinary local and imported type
identities. It must not have special rules for `Result`, `Option`, or standard
module paths.

## Initial source findings

1. Short local enum names already have tests for values, calls, patterns, and
   return types in
   `self_host/compiler/semantic_variant_selection_test.dew:184` and `:261`.
   Named-field variants also have selection code. Many existing prefixes can
   therefore be redundant, but this review did not validate each use.
2. The self-host name resolver restricts imported short variant names in
   `self_host/compiler/semantic_body_name_resolution.dew:2052`.
   `self_host_body_variant_names` calls `scope.lookup_type(declaration.name)`
   and requires that lookup to select the variant's exact owner. Exact imports
   register declarations but do not populate this short type-name table.
   Opened types with equal names can also lose their variants at this step.
3. Declaration registration and name exposure are already separate in
   `self_host/compiler/semantic_module_interfaces.dew:1420`.
   `import_interface` registers declarations for both forms and calls
   `expose_declaration` only when `open_names` is true. The inference data does
   not need to depend on opening a name.
4. The MoonBit name resolver already adds variants from all imported interfaces
   in `src/semantic/resolve_body_names.mbt:1520`. This differs from the self-host
   resolver. Its expected-owner selection path in
   `src/semantic/infer_patterns.mbt:537` also searches by exact owner identity.
5. Self-host expression selection counts local and imported variants, then
   requires a known owner or one matching name. See
   `self_host/compiler/semantic_basic_body_inference.dew:1826` and `:5314`.
   This does not compare several same-name candidates against payload types
   before selecting one. Some failure paths mark the expression unsupported.
6. Self-host pattern selection has separate local and imported searches at
   `semantic_basic_body_inference.dew:2652` and `:2721`. Callers try the local
   result first. Without an expected owner, this does not use the same combined
   candidate count as expression selection.
7. In `semantic_basic_body_inference.dew:7777`, a plain `ObjectExpr` is marked
   unsupported. Explicit `ConstructExpr` nodes go to constructor selection.
   The MoonBit compiler already tests expected-type struct literals in
   `src/semantic/object_field_inference_wbtest.mbt:86`.
8. `constrain_body` at `semantic_basic_body_inference.dew:8041` selects pending
   variants and constructions before variant patterns and pending methods.
   Variant call/value queues are cleared after that pass. Later type facts
   therefore need an explicit retry route to help earlier short constructors.
9. Struct patterns currently retain a target. The parsers do not provide a
   plain `{ field: pattern }` pattern root. See
   `self_host/compiler/parser_pattern.dew:77` and
   `src/parser/patterns.mbt:18`. Omitting the struct name in a pattern needs a
   syntax/AST extension as well as inference work.

## Implemented design (initial proposals)

### 1. Admit imported constructors without opening their type names

Build constructor candidates from public imported declaration identities.
Do not require `lookup_type` to find an unqualified owner first. A signature
such as `-> @reply.Result<I32, String>` should supply enough information for
`Ok(value)` and `Err(message)` in that body.

Keep module aliases, ordinary value names, and constructor candidates separate.
This preserves exact imports while allowing short constructor use. Deduplicate
the same declaration reached by an import, an open, or a transparent alias.
Normalize transparent type aliases before owner selection.

### 2. Carry expected types through every useful context

Use parameter types, return types, typed lets, assignments, struct fields,
array elements, branch results, loop state, and callback signatures. For
patterns, use the subject type and then each selected payload or field type.
Apply this to `match`, `is`, destructuring, and functional-loop patterns.

This extends existing constraint support. It is not a new inference system.
Nested forms such as `Some(Ok(value))` must receive inner generic arguments
from the selected outer constructor.

### 3. Defer selection until the required type facts are ready

Keep unresolved constructor choices in a dependency work queue. Retry them
when a field, method result, overload, pattern binding, or generic argument
adds a useful constraint. Stop when no relevant constraint changes.

Do not report ambiguity just because the current traversal has not yet reached
the code that determines the type. Do report it when solving is complete.

### 4. Filter candidates with payload and field constraints

If the expected enum is unknown, use payload kind, argument count, named
fields, and known argument types to reject candidates. Instantiate generics
under solver snapshots and commit only one viable candidate.

A known expected owner takes priority and limits the search to that owner.
Do not select an unrelated type because its fields happen to look similar.
Do not use default numeric literal types as an arbitrary tie breaker.

### 5. Complete struct literal inference in the self-host compiler

Allow `Span::{ start: 0u32 length: 1u32 }` to become
`{ start: 0u32 length: 1u32 }` when context supplies the exact struct type.
Reuse ordinary field validation, generic substitution, field identities, and
constructor planning for local and imported structs.

Resolve nominal identity from context or a bounded overload candidate set.
Field names alone do not prove which of several nominal structs was intended.

### 6. Add struct patterns with an inferred owner

Allow `{ start: first length: count }` when the subject type identifies the
struct. This is proposed syntax, not a currently supported example. Keep
named enum cases in patterns: `Entry { value: item }` can omit the enum owner
while still stating which case to match.

The parser, AST/HIR artifacts, collection, name resolution, inference, and
lowering must all carry this form. Preserve field identities and rest-pattern
rules through emission.

### 7. Infer constructor function values

Where a function type is known, permit a constructor name such as `Ok` to be
used as a callback. Use its expected parameter and result types to choose the
owner and generic arguments. Constructor-as-function support needs a callable
representation or a generated ordinary wrapper; a unit-variant value path is
not sufficient.

### 8. Infer owners for static factory calls

Permit `new()` or `empty()` when the expected result identifies the owner of
`Array::new()` or `Map::empty()`. Search that owner's ordinary implementation
members and use normal signature checks. The same rule can apply inside an
implementation where `Self` supplies the owner.

This is separate from enum constructor inference and has more name collisions.
Implement it after enum and struct context support. Existing lexical functions
and locals retain clear priority; unresolved choices must be diagnostic.

### 9. Use one ambiguity and binding policy

Expressions and patterns must consider the same eligible owners. Do not pick
the first local or imported declaration. An expected type can resolve equal
short names, including equal type names in different exact imports.

Define how a bare pattern name is distinguished from a new local binding.
An import must not silently convert an existing binding into a catch-all or
select a different enum case. Preserve explicit qualification as a way to
resolve cases with too little type information.

Diagnostics should state the short name, expected type, and remaining qualified
candidates. Distinguish no match, multiple matches, and missing type context.

### 10. Keep lookup cheap and preserve exact emitted identities

Build shared per-module indexes by short constructor name and by
`(owner declaration, member name)`. Use the owner index first when context is
known. Avoid the current full variant scans for each short-name use and avoid
copying large candidate arrays into every body.

Freeze exact declaration, variant, field, and type-argument selections before
physical planning. Assert these identities where the compiler depends on them.
The backend should emit the same instructions for explicit and inferred forms.
These changes should add no runtime name lookup or runtime type checks.

## Verification and source cleanup order

First align imported enum lookup in both compilers. Then add delayed context,
struct expressions and patterns, and finally callable constructor/factory forms.
Remove proven redundant prefixes in small source groups after each feature.

Tests should cover exact imports with `@alias.Type` annotations and no `open`,
opens, local declarations, transparent aliases, equal names across modules,
nested generic values, payload and named-field patterns, lexical shadowing,
delayed field/method context, and visible ambiguity errors. Check collection,
type-resolution, name-resolution, inference, and emission diagnostics, plus
the selected owner/variant/field identities.

The existing native test named "imports and opens expose enum constructors
without a type prefix" uses an unqualified `Payload` annotation even in its
exact-import case. It checks collection/import/name/body diagnostics, but does
not assert the resolved type diagnostics. It is not sufficient evidence for
the proposed exact-import contract. New tests should use `@library.Payload`
and check all relevant phases.

Use `tools/test-native.sh` for the routine native lane,
`tools/test-integration-native.sh` for full integration cases, and the existing
self-host hardening/bootstrap lanes to verify compiler agreement and emitted
behavior. Update artifact provenance if cached semantic results change; keep
format versions at 1. Measure each compiler activity. More than 30 seconds is
a performance bug.

## Review measurements

A text scan of 305 compiler `.dew` files took 0.0612 seconds. It found 18,085
`Name::` occurrences, with 15,120 in files not named `*_test.dew`. The latter
include 5,446 `Option::`, 851 `Result::`, and 204 `SelfHostHirSpan::` occurrences.
These are text counts and include any comments and embedded source strings.
They do not measure how many prefixes can already be removed safely.

A second text scan took 0.0375 seconds. Non-test files contain 290 `Result::Ok`,
561 `Result::Err`, 93 `StringBuilder::new`, 49 `Map::empty`, and 25 `Array::new`
occurrences under the same counting limits.

## Implementation status

Both compilers now register exact-import enum candidates, retry constructor
constraints with member constraints, prune same-name enum candidates by payload
and fields, infer struct values and anonymous struct patterns, and select tuple
constructor callbacks and static factory owners. The self-host compiler uses
ordinary generated callback functions with frozen variant metadata. Neither
compiler has special cases for `Result`, `Option`, or standard module paths.

The final source-token audit found 17,799 prefixes in HEAD and 287 in the
working source: a net reduction of 17,512. Strings and comments were excluded.
No `Result::` or `Option::` prefixes remain in compiler code. The remaining
prefixes are static factories and unconstrained struct values.
The mechanical passes removed 16,294 enum prefixes, 1,348 struct prefixes,
and 68 factory prefixes; eighteen struct owners were retained where needed.
Object-valued arms use parentheses to preserve the parser's one-token rule.
The final audit took 0.752 seconds.

The cleanup exposed a native backend defect: a bare unit case nested in a
payload had binding-shaped HIR and was accepted by catch-all optimizations and
the simple matcher. Those paths now consult frozen constructor identity.
Self-host anonymous objects now use the normal constructor field recipes,
carrier checks, scratch plans, and emission path.

Invalid source previously reached physical specialization and could cause an
assertion before its source diagnostic was shown. The compiler driver now
reports frontend errors before that boundary. Ambiguous enum diagnostics retain
candidate identities and show qualified candidate names.

Dew does not currently have typed local lets. The initial proposal's reference
to them was not a statement about supported grammar. Unconstrained nominal
struct values still require an owner; field names alone are insufficient.

## Implementation measurements

These entries record the initial inference implementation. The subsequent
[failure-fix work](self-host-failure-fixes-2026-09-10.md) fixes all 15 failures
and the measured compiler bottlenecks. The complete suite now passes 1,264
tests; generation takes 8.496 seconds.

- Initial focused native regression tests: 8 cases; all passed after callback
  support (semantic lane 10.747 seconds, including the native test build).
- After source cleanup and the nested-unit-pattern fix: 19 self-host cases
  passed in 0.068 seconds. Emitted imported callbacks and anonymous struct
  patterns returned the expected result; emission check 0.194 seconds.
- Warm self-host test generation: 22.521–23.874 seconds. Link: 8.388–10.337
  seconds. Native rebuilds included in generation exceeded 30 seconds on some
  runs (30.163–42.300 seconds); those are recorded as performance bugs.
- Native tokenizer: 36/36, 0.022 seconds. Parser: 297/297, 1.707 seconds.
- Native semantic suite: 840/840, 203.397 seconds. This repeats the pre-cleanup
  combined-runner problem (197.686 seconds). The routine tool now isolates
  semantic test files so each compiler activity has its own time and diagnostic.
- One initial release native build took 134 seconds; one build blocked by an
  already running native lane took 158 seconds. Both exceeded the activity
  limit. Warm independent debug lanes are used for iteration.

## Verification before the failure fixes

- Routine native lane: 1,348 passed. This comprises tokenizer 36, parser 297,
  semantic 842, backend 151, loader 19, and driver 3. The semantic files each
  took at most 22.742 seconds. The backend group took 115.192 seconds including
  its native rebuild, which was recorded as a performance bug.
- Full native integration lane passed. After the final cache admission change,
  all 6 frozen-interface tests and all 26 module-system tests passed again,
  including skipped integration cases (2.951 and 22.635 seconds).
- Focused self-host inference: 21 cases passed, plus executed emission checks
  for imported constructor callbacks, anonymous struct values/patterns, and
  nested short unit patterns. The test run took 0.075 seconds; emission took
  0.113 seconds excluding process setup.
- All 113 self-host test files compiled. The wider run passed 1,244 of 1,259
  tests in 1.199 seconds. The same 15 failure identities occur in a HEAD-source
  control run: 1,223 passed of 1,238. The control uses the same native harness,
  small fixture syntax/API repairs required to compile those older files, and
  the graph performance fix below. It excludes the new inference features.
  The 21 additional tests passed. The follow-up fixes the 15 control failures.
- Final hardening: 969 tests passed in 0.496 seconds. All invariant, semantic,
  and emission probes passed. Generation took 56.028 seconds including a
  native rebuild, linking took 10.752 seconds, and the emission-probe group
  took 59.725 seconds. The two groups over 30 seconds were recorded as performance bugs.
- The final self-build passed after the graph performance fix and source
  cleanup. B and C have identical SHA-256:
  `a0abfad02d4243703e6cabf9876bea2fc7d33ed0e4acf2f849fc395500e019ce`.
  Building A took 57.698 seconds; A emitted B in 64.159 seconds; B emitted C in
  71.709 seconds. These are performance bugs under the 30-second limit.
  Validation, linking, and B semantic probes all passed.
- Public MoonBit interfaces were regenerated (5.758 seconds). Changed MoonBit
  files were formatted directly, and shell/JavaScript syntax checks and
  `git diff --check` passed.

Reproduce focused checks with `tools/test-short-inference-self-host.sh`.
Use `tools/test-short-inference-self-host.sh --all` for the wider suite;
all failures remain visible and produce a nonzero exit status.
The wider runner permits unlinked host function imports only as throwing
stubs. Any test that calls one fails with the exact host import name.
Use `tools/test-native.sh`, `tools/test-integration-native.sh`,
`tools/test-self-host-hardening.sh`, and
`tools/check-self-host-bootstrap.sh --fast` for the other lanes.

## Additional defects exposed by the cleanup

The first member of an alternative pattern list did not receive its subject
type in self-host inference. Explicit owners hid this defect. All alternatives
now receive the same subject type. Index and binary operator choices now wait
for constructor and pattern payload constraints before a failure is reported.

The wider tests exposed repeated reachability scans in module-value SCC
analysis. A 1,024-value chain was still running after 135 seconds when stopped.
That path now maps exact declaration IDs to indices once and uses the existing
iterative program graph walk. The entire 1,259-test run then took 1.199 seconds,
including the 1,024-value chain and dependency tests. The old unused traversal
helpers were removed.

The wider fixtures also needed small repairs to compile: imports before
items, newline-separated record fields, no local-let type annotation, current
pattern arities and inference call signatures, explicit treatment of the new
factory name reference, and owners for two unconstrained test records.
These repairs do not hide runtime failures.

## Wider-suite failures fixed in the follow-up

These exact test identities failed in both the changed-source and HEAD control
runs. The [follow-up](self-host-failure-fixes-2026-09-10.md) fixes all 15.
Failure checks remain diagnostic; no test was skipped or changed to accept failure.

- `semantic_basic_body_inference_test.dew`: loop item fields keep their exact declaration identity.
- `semantic_body_name_resolution_test.dew`: for iterable retains its parameter binding.
- `semantic_collection_test.dew`: semantic collection keeps builtin overloads in source order.
- `semantic_lowering_plan_test.dew`: lowering plans patterns and functional loops.
- `semantic_program_link_plan_test.dew`: emitted local validation rejects a field carrier change.
- `semantic_program_link_plan_test.dew`: physical body plan keeps a String result from a checked record array accessor.
- `semantic_program_specialization_test.dew`: program specialization canonicalizes and deduplicates scalar carriers.
- `semantic_program_specialization_test.dew`: program specialization indexes requests by declaration.
- `semantic_program_specialization_test.dew`: program specialization retains canonical product shape trees.
- `semantic_wasmgc_fragment_plan_test.dew`: WasmGC fragments plan lambda closure types and entry functions.
- `semantic_wasmgc_fragment_plan_test.dew`: WasmGC fragments retain exact nominal multi-field tuple payloads.
- `tokenizer_parity_test.dew`: self-host tokenizer enforces every integer boundary.
- `tokenizer_parity_test.dew`: self-host tokenizer rejects malformed integer suffixes.
- `tokenizer_test.dew`: self-host tokenizer handles Unicode identifiers and comments.
- `tokenizer_test.dew`: self-host tokenizer validates integer separators and range.
