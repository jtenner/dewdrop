# Self-host physical body-carrier plan

Date: 2026-08-26

## Baseline

Repository state at task start:

- branch: `review/self-host-fixed-point-2026-08-26`;
- commit: `e451f75adfd2e238dbe003e38a3a5a21bc12239e`;
- existing user changes were present in `AGENTS.md`, `README.md`, `docs/research/rust-style-iteration-and-for-2026-08-20.md`, `starshine-mb`, `tools/dew`, `src/starshine_guest/pkg.generated.mbti`, and `tools/dew-registry.mjs`.

The checked-in Starshine consumer fingerprint was stale for the existing provider tree. `tools/generate_starshine_ffi_consumer.py` refreshed only generated Starshine consumer files.

Baseline commands:

- `tools/test-native.sh`: all reported tests passed. The semantic lane took 158.259 seconds and the backend lane took 97.035 seconds. Both exceed the 30-second project limit.
- `DEW_SELF_HOST_FULL_VALIDATION=1 tools/check-self-host-smoke.sh`: the initial run stopped on the stale generated fingerprint. After refresh, the command exceeded 600 seconds before it reached the smoke build report.
- `tools/check-self-host-bootstrap.sh`: compiler A built and validated. Compiler A build took 105.424 seconds. Request generation took 1.304 seconds. A-to-B execution took 111.414 seconds and stopped because Starshine rejected compiler B.

The latest preserved diagnostic compiler-B artifact is `.tmp/correctness-call-initializer/a/compiler-b.wasm`:

```text
error: func 1759 failed to validate

Caused by:
    0: type mismatch: expected eqref, found i32 (at offset 0x42839)
```

At the failing instruction, call 1761 produces `i32` and `local.set 6` expects `eqref`. The stable source declaration, body ID, specialization key, expression ID, and source offset will be recorded after the carrier-plan diagnostic lane maps this old physical failure to semantic identities. Physical function 1759 is not used as a fix key.

The earlier branch record also identifies the i64-to-i32 `Some` payload class at physical function 1622 and offset `0x35d7f`. That number is historical only. The regression must use the selected `VariantId`, specialization, payload subtype, and physical payload field.

The current primary bootstrap failure is physical function 1837, `SelfHostBodyNameMergeBuilder::resolve_and_merge_lambda`, at offset `0x4dcb8`. `pending_captures[current]` has logical type `SelfHostLambdaCapture`, but the old physical body path retained only `eqref`. The local `source` then lost its exact owner, and same-named fields from unrelated records were selected. The resulting `SelfHostLambdaCapture` constructor received `eqref` for its `name` field, which requires `i32`.

## Current pipeline

The current native pipeline is:

1. parse source AST;
2. collect executable HIR;
3. resolve names and declaration types;
4. infer body-local logical types;
5. compute flow;
6. build backend-neutral lowering with `BodyTypeId`, nominal IDs, and `PlannedValueShape`;
7. specialize program calls;
8. build WasmGC fragments with physical fields and function signatures;
9. link final program type and function indexes;
10. allocate locals and recover carriers inside Starshine emission;
11. validate and encode.

The self-host compiler follows the same broad sequence, but `self_host/compiler/starshine_module.dew` performs a large amount of late recovery. It derives local and scratch types from initializers, uses, names, nearby expressions, generic shapes, and fallback whole-program scans.

## Missing contract

There is no one immutable plan that joins these facts for each materialized body:

- logical Dew type;
- specialization ABI key;
- exact linked Wasm parameter and result ABI;
- exact expression stack carrier;
- exact source-local carrier;
- exact pattern-binding carrier;
- exact control-state and control-result carrier;
- exact scratch-local carrier;
- selected physical field and variant payload field;
- explicit cast, storage conversion, box, or unbox operation.

This gap lets one producer be viewed as `i64` while a constructor expects `i32`, or lets an `i32` call result be stored in an `eqref` local. The emitter then tries to repair incomplete semantic facts. Each repair advances validation to a later failure without removing the cause.

## Planned phase

Add one physical body-carrier planning phase after specialization and physical program linking and before instruction emission.

The plan is keyed by the materialized physical function. Its key includes:

- linked function index;
- module index and module ID;
- body ID or lambda ID;
- declaration ID;
- specialization ABI key;
- initializer identity where applicable.

Runtime functions, imports, signature-only functions, and inline-only builtins do not receive source-body plans.

Each planned entity keeps separate data for:

1. logical Dew type and nominal identity;
2. exact Wasm value carrier;
3. exact Wasm storage type when storage is involved;
4. value cardinality: Unit, one value, Never, or an explicitly supported multi-value ABI;
5. explicit edge conversion.

Products retain the existing one-reference runtime ABI in all contexts.

## Invariants

- Every materialized source body has one carrier plan.
- A generic body is planned per physical specialization.
- Normal specialized bodies have no surviving generic carrier.
- Every source local and scratch local has one exact Wasm local type before emission.
- Local reuse is keyed by exact carrier.
- Packed i8 and i16 storage loads and stores use an explicit i32 value carrier.
- Numeric widths are never exchanged implicitly.
- Unit has no arbitrary value carrier.
- Never produces no stack value.
- Exact references can widen only through planned compatible edges.
- An erased reference cannot narrow to a nominal reference without a planned checked cast.
- Function references and `call_ref` use the selected physical signature.
- Field and variant lookup starts from semantic owner IDs and linked indexes, not names.
- Any box, unbox, cast, null check, or storage conversion is explicit plan data.
- The emitter does not infer a local type or choose a field, variant, or signature.

## Verifier

A pre-emission verifier walks all producer-to-consumer edges and collects all independent errors in deterministic source order. A diagnostic includes:

- module;
- source declaration;
- body or lambda;
- physical function index;
- specialization ABI key;
- expression ID;
- related local, field, pattern, or call ID;
- source offset;
- operation context;
- logical type and logical shape;
- selected nominal owner;
- expected carrier;
- actual carrier.

The verifier runs before Starshine instruction construction. A direct full-compiler lane will build the self-host plan and print all carrier errors in one run.

## Known failure classes

The initial matrix includes:

- scalar divergent values entering reference closure locals;
- flattened product signatures versus runtime product references;
- mixed product field order and projection;
- product match results and pattern bindings;
- functional-loop state and payload bindings;
- Option and Result physical payload selection;
- i64 payload values entering i32 `Some` subtypes;
- nested field and index provenance;
- array iterator Option results;
- Map key/value recovery and `Map::get` Option payloads;
- same-named receiver fields;
- same-named `new` constructors;
- exact closure and `call_ref` signatures;
- packed i8/i16 field loads and stores;
- exact-carrier scratch-local reuse;
- module global and initializer carriers.

## Return and enum inference work

`return` will become one AST, HIR, lowering, and emission expression with logical type `Never`. The old independent block-item return semantics will be removed.

Unqualified enum selection will use propagated expected types, scrutinee owners in patterns, visible-candidate filtering, payload constraints, and delayed choice when the expected type remains an inference variable. Qualified variants remain legal only for explicit disambiguation.

A semantic style gate will report redundant qualified enum variants under `self_host/compiler/**/*.dew` with path, offset, owner, and variant.

## Exact nominal provenance update

The canonical body plan now records `SelfHostPlannedPhysicalValueInfo` for expressions, parameters, user locals, pattern bindings, control-state values, control results, and scratches. The value record keeps the logical body type, broad Wasm carrier, exact nominal owner, and linked physical heap type as separate facts.

Array and index planning recovers the specialized element owner from the indexed expression type and from the container type argument. Local initialization and `local.get` copy the complete value record. Pattern payload bindings and loop-carried values use the same record.

Field plans now retain the receiver expression, receiver logical type, receiver nominal owner, receiver linked heap type, exact `FieldId`, exact linked owner type, physical field index, storage type, and result value record. Unresolved field syntax can only be completed by an exact receiver owner plus field name during physical planning. The old whole-program first-name fallback was removed. Starshine field emission consumes only the canonical selected field.

Constructor emission now uses the canonical linked destination type when present and maps source fields to destination fields by exact `FieldId`. Name and ordinal fallback were removed. The pre-emission verifier checks each constructor argument carrier and nominal reference provenance against the exact destination field. It also rejects field receivers whose nominal owner or linked heap type does not match the selected physical field owner.

The reduced runtime fixture is `tests/module-snapshots/collections/nominal-container-provenance-runtime.dew`. It covers `Array<I32>`, `Array<I64>`, `Array<String>`, `Array<Capture>`, `Option<Capture>`, `Result<Capture, OtherStruct>`, and `Map<I32, Capture>`. Three unrelated records reuse `name`, `source`, `mutable_`, and `offset` with different field orders and carriers.

## Pre-emission carrier assertions

The physical-body verifier now checks local initialization and assignment boundaries. A value cannot enter a materialized local when its planned carrier differs from the local carrier. `Never` and genuinely unresolved values remain exempt so the diagnostic does not hide the original unresolved source.

This moves failures before Wasm instruction emission and reports the semantic module, declaration, body, specialization, expression, local ID, source offset, logical type, selected nominal owner, expected carrier, and actual carrier.

The first assertion-enabled bootstrap stopped after compiler A executed, before compiler B validation, with three root mismatches:

- `self_host_program_specialization_receiver_type_argument_shape`: local 4 expected `i32`, but a match result was planned as `eqref`;
- `self_host_body_seed_expression`: local 8 expected `i64`, but the assigned declaration value was planned as `eqref`;
- `self_host_linked_function_returns_array_element`: local 14 expected `i32`, but a match result was planned as `eqref`.

These three mismatches are fixed. Local initialization and assignment now propagate an already-known local ABI carrier back into the source expression. Match planning propagates an externally required result carrier into each falling-through arm before arm values are merged. Exact call-result, field-storage, and constructor-field checks remain responsible for rejecting an incorrect external constraint.

The Starshine emitter and physical-body verifier now check these high-traffic boundaries:

- every allocated Wasm local must use the canonical local carrier;
- local initialization and assignment must agree with the destination local;
- exact physical variant payloads must agree with pattern-bound local carriers and nominal owners;
- direct binding arms must agree with the match result carrier;
- an index operation's selected runtime carrier must equal its canonical expression carrier;
- normal call arguments must agree with physical parameter carriers;
- a normal call's physical result ABI must equal the canonical expression carrier;
- exact physical field storage must agree with the field expression carrier;
- match-arm and match-result carriers must agree before branch instructions are emitted.

Calls that the emitter intentionally replaces with a physical operation, such as `get_unchecked`, `indexed_get`, and `into`, are checked by their lowering-specific path instead of the normal-call ABI assertion.

## Pattern and call propagation update

The original `offset` failure is fixed. Pattern planning now:

- prefers the tuple pattern's own selected constructor;
- maps every tuple child by its physical field index;
- propagates physical field carriers and reference owners recursively through nested variants;
- treats the incoming physical payload as authoritative over broad pattern shapes;
- uses exact generic `Some`, `Ok`, and `Err` payload information when available;
- permits name/arity recovery only when the candidate physical variant is unique;
- rejects ambiguous whole-program variant recovery instead of selecting the first candidate.

Normal method calls now reuse the specialization-aware emitter call lookup when the body call map has no entry. Exact physical call parameters propagate into argument expressions and source locals. Exact call results propagate into result expressions and initialized locals. Array-push item carriers and direct binding results also propagate back into pattern locals.

Canonical local and match-result carriers now take precedence over late emitter inference. This fixed the earlier bootstrap failures in physical functions 1510 and 1586, including scalar enum payloads and scalar array-push scratch values.

## Current results

Compiler A builds and validates. The physical-body verifier reports zero errors. Compiler A executes and produces compiler B.

The `module_value_visible` failure in physical function 1809 is fixed. Loop-state planning now propagates the exact initial loop carrier back through `continue` values and pattern-bound locals. `Some` payload planning prefers exact binding-use evidence when it proves a reference, then the receiver's value shape, and does not let a broad call result silently replace a concrete loop carrier.

The unresolved `Map<I64, V>::get` receiver defect in physical function 1812 is fixed. Field result type-argument provenance now recovers nominal payload owners through exact physical field layouts. Method lookup uses receiver identity and explicit arity before name-only fallback. The duplicate `intern_simple` method in imported semantics was renamed to `intern_imported_simple`, removing an ambiguous receiver/name pair.

Further bootstrap fixes now cover:

- exact Map pattern-local value carriers;
- Map index writes lowered as Map writes instead of fixed-array writes;
- direct, unresolved, and builtin Map get/contains/write scratch allocation;
- array index lowering through physical array-module identity;
- dead local initializers emitted as drops instead of invalid stores;
- String literal match conditions lowered through `dew_string_equals`;
- exact physical field storage for array-push items;
- loop initial carriers and `continue` boundaries;
- product-free field and pattern helper control flow where tuple carrier recovery was unnecessary.

New pre-emission assertions cover normal call argument count and carriers, unresolved call arguments, escaped index lowering, literal match carriers, local allocation, Map payload/local boundaries, pattern payload extraction and stores, call results, index results, field storage, and constructor fields.

The physical function 2467 control-result defect is fixed. Before an `if` is emitted, the emitter now computes exact live-branch carriers from canonical locals, blocks, index reads, constructors, constants, and physical call ABIs. If both branches are exact and disagree, emission stops with module, declaration, body, specialization, expression, branch expressions, selected carrier, and exact branch carriers. If both exact branches agree, that physical carrier controls the Wasm block result instead of stale scalar inference.

The fix exposed two related specialization defects and corrected them:

- generic array element shapes map through the physical fixed-array carrier, so `Generic` reference elements do not become unresolved;
- fixed-array index use can propagate through local aliases, `if` results, and match arms, while Map key indexing remains a separate specialization path.

Bare `Option::None` values in `self_host_linked_i32_main_expression` were also replaced with explicit scalar sentinels. This prevents `Option<U32>` and `Option<U64>` payload subtypes from sharing an unresolved generic carrier. Small helpers that returned `Result<Unit, String>` now return `Option<String>` where only success or an error message is needed; this prevents a unit payload from being assigned a reference field by unresolved Result specialization.

The `wasm_ref_null` builtin now emits the actual Wasm `ref.null eq` instruction. It no longer falls through name-only lookup to the unrelated Starshine `Instruction::ref_null` export.

Strict Starshine validation has been restored in `self_host_encode_linked_i32_module`; the temporary `&& false` bypass is gone.

Current bootstrap result:

- compiler A builds and validates;
- compiler A executes and emits compiler B;
- Starshine validates the emitted compiler B before encoding;
- `wasm-tools validate --features all` validates compiler B;
- the original Map receiver bug and the control-result carrier failure are no longer validation blockers.

Compiler B execution now stops before its `main` function because the self-host output is still a Core Wasm consumer with dynamic `starshine` imports:

```text
dew WASI run failed: TypeError: WebAssembly.instantiate():
Import #2 "starshine": module is not an object or function
```

This is now a provider-linking boundary, not a body-carrier or Wasm-validation failure. Compiler C and B/C byte identity still require the self-host request path to apply the Core Wasm provider linker, or an equivalent exact ABI-preserving link step, to compiler B before execution.

Final checks for this pass:

- `tools/test-native.sh`: pass, including 36 tokenizer, 284 parser, 350 semantic, 46 backend, 16 standard-loader, and 2 compiler-driver tests;
- `collections/nominal-container-provenance-runtime`: pass under Node and Wago;
- no temporary trace strings remain;
- `git diff --check`: pass.

## Provider link continuation

The self-host output now uses `link:starshine` imports and exports `main` plus memory 0. The bootstrap script post-links compiler B and compiler C with the native Core Wasm linker before execution.

The Core Wasm linker now:

- inserts checked `eqref`-to-concrete-reference adapters instead of rejecting erased provider parameters;
- does not treat an empty nominal base that has declared subtypes as a replaceable foreign marker;
- does not compare unrelated cross-module defined references by raw local type index;
- composes provider and Dew start functions, with provider initialization first;
- uses the flattened type count when it appends the combined start signature;
- runs cleanup after linking, which removes unused provider host imports.

The full Starshine provider now links and validates. Compiler B is reduced from the full provider merge to about 1.1 MiB after cleanup. Compiler B exports `main` and `memory`, and `wasm-tools validate --features all` passes.

The self-host emitter now emits the full WASI subset used by the included process and filesystem modules. Function indices keep separate logical and final emitted views, so the larger WASI import prefix does not corrupt canonical body-plan lookups.

Imported calls through aliases, such as `@wasi.args_sizes_get`, now resolve through the exact imported module scope during basic inference. This prevents them from being misclassified as function-value calls with poison qualified roots.

The remaining execution blocker is an unresolved type-qualified static call in `wasi_memory_string`, currently `BytesBuilder::with_capacity`. Compiler B validates and starts, but traps in that function before it can read the request path. The next fix is to port exact type-qualified imported method resolution from the native inferencer, rather than rely on emitter name recovery.
