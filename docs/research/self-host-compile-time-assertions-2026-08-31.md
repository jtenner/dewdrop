# Self-host compile-time assertions

Date: 2026-08-31

## Rule

A self-host runtime failure must become a compile-time check when the compiler can prove the required condition.

Comments for these checks use ASD-STE100 Simplified Technical English.

## Added checks

### Stable Starshine FFI carriers

`tools/generate_starshine_ffi_consumer.py` now gives stable names to compiler-visible Starshine reference carriers.

The generator checks related provider signatures before it writes the Dew bindings. Generation stops if related exports do not use one physical carrier.

The self-host compiler now uses names such as `StarshineInstructions`, `StarshineModule`, and `StarshineLocals`. It does not use provider type index numbers.

### Integer sign mode

The self-host emitter recovers the source integer shape before it selects signed or unsigned Wasm instructions.

Compilation stops if one integer operation has conflicting signed and unsigned proof.

This check found a U32 sentinel comparison that used `i32.lt_s`. The wrong instruction admitted `4294967295u32` as a valid array index.

### Array pop carrier

Starshine now exposes one high-level `instructions_push_array_pop` bridge. The bridge emits a pop operation for a proved carrier.

The self-host compiler rejects an unknown or out-of-range pop carrier before it emits Wasm.

A typed `self_host_array_pop` source helper keeps the generic type argument visible. The body planner also reserves the complete pop scratch-local group.

### Source field and index carriers

Array element proof now checks the source field type before physical fallback data.

When source proof gives a scalar carrier, the compiler refines the canonical expression plan before index emission. This prevents an `Array<U32>` field from using an `eqref` backing array.

### Exact work-array types

Compiler work arrays now use typed constructors in body-shape, value-shape, specialization, derive, and evidence code.

Some tree checks now use bounded recursion instead of mixed-carrier work arrays. Each recursive check has a 1,024-level compile-time guard.

### Post-link type compaction

The post-link RUME pass rebuilt the compacted type section from the original types after it had calculated rewritten type indices. A retained subtype could keep its old supertype index after an earlier unused type was removed.

Starshine validation now reports the bad type index and the available type count. The RUME pass now rebuilds the type section from rewritten types only.

A regression test checks three separate obligations:

- the dense remap changes old type `2` to new type `1`;
- the shared type-index rewrite helper applies that map;
- the rebuilt type section stores the rewritten supertype index.

The formal proof lane also proves that dense compaction keeps a retained type inside the new arena and keeps a retained supertype before its retained subtype.

### Portable provider artifacts

MoonBit 0.10.11 can emit a debug `name` section whose subsections are not in canonical order. The section is not semantic, but Starshine correctly rejects the order when it decodes a provider module.

The Starshine FFI build now removes only the `name` custom section. It keeps `dew.abi` and all other semantic custom sections. A Bun test checks that the filter removes only the selected section.

### Facet self-host runtime

The self-host smoke source list now includes `self_host/compiler/facet_runtime.dew`. The compiler build links both the Starshine and Facet providers, and the smoke runner uses the Facet host.

The smoke request now includes only the bootstrap modules that the smoke program needs. Facet, path, file-system, process, and Blake3 sources have separate checks and do not hide core compiler failures in this lane.

### Program link and representation gates

The compile request now validates the complete program link before body emission. A missing specialization or physical call target reports the target declaration, specialization, caller body, caller specialization, and expression.

Inline builtins such as `dew_debug_dispatch` do not need physical functions. The link validator classifies them separately instead of reporting false missing-target errors.

The representation validator checks each retained struct field and tuple variant payload against its declared source type. It rejects a storage carrier mismatch before Starshine type emission.

Array and Map module identities now come from their runtime builtin declarations. They no longer depend on fixed module numbers such as `7204` and `7205`.

Field lookup no longer searches every type when the nominal owner is missing. A field name alone is not physical proof. Type declarations and variant declarations are also kept separate during nominal field lookup, even when their arena-local numbers are equal.

## Current result

Compiler A builds and validates. It also reaches final Starshine validation while it builds compiler B.

The fixed-point compiler lane is still blocked by an Array carrier mismatch in self-host compiler traversal code. Starshine rejects that output before compiler B can run.

The shorter self-host smoke lane now passes. Compiler A compiles the source request, writes a valid Wasm output, and gives deterministic compiler and output hashes. The lane also uses the Facet runner for negative checks and confirms that a bad compiler fingerprint and an unbounded module count are rejected.

The smoke lane moved past these failures:

- missing Facet host types and providers;
- invalid provider `name` sections;
- local callback calls treated as qualified calls;
- missing `Array::with_capacity` physical functions;
- inline debug builtins treated as physical functions;
- variant constructors treated as function calls;
- raw FixedArray stores without a nominal cast;
- fixed Array and Map module-number assumptions;
- an incorrect smoke output path;
- negative tests that failed only because they used the wrong WASI runner.

The complete fixed-point lane now builds compiler A and its full source request. With the Node Facet runtime, compiler A reaches final Starshine validation after about four minutes. The next exact carrier failure is in `self_host_build_physical_body_indexes`: a `local.set` expects `eqref`, but receives `i64`.

The Wago runtime stops earlier because one `array.new_fixed` contains 63 values while its amd64 helper has 62 slots. This is a Wago execution limit, not a Dewdrop semantic diagnostic.

Compiler B is therefore still blocked. The new link and representation gates run before this final carrier failure.

This is progress from the prior runtime failures:

- the U32 sentinel no longer reaches an out-of-bounds name lookup;
- generic Array pop no longer reaches the former bad runtime cast;
- several wrong push and index carriers now fail during compiler output validation.

The fast lane is slow on the current host. Compiler A execution has taken several minutes while two unrelated Node test processes use full CPU cores. This remains above the 30-second compiler activity limit.

## Later phase canaries

The compile request now validates `SelfHostPlannedProgramLowering` before specialization. The gate checks body expression spans and rejects these invalid states:

- a local or capture that lowers to poison;
- a runtime method whose receiver lowers to poison;
- a typed poison expression with a retained nominal owner;
- a field receiver outside the expression arena.

The diagnostic includes the module, declaration, body, expression, logical type, nominal owner, name reference class, source name, and source offset. This gate found the lost `values` binding in `blake3_iv` before physical method certification.

The lost binding came from String-keyed compiler maps. The current Wasm Map runtime compares reference keys with `ref.eq`. That operation tests object identity. It does not test String content. The compiler name interner and `find_name` now use the `dew_string_equals` builtin directly. Repeated source names therefore keep one name ID during self-host execution.

Body name resolution now keeps active local IDs in a dense U32 array. It also resolves a let initializer completely, binds the new local, and only then schedules the next block item. A local binding write is checked immediately.

Array push selection now accepts an exact reference carrier. A broad reference from a pattern local cannot replace an exact scalar Array slot. Parameter declarations, canonical local carriers, source container arguments, and emitted scalar carriers are used as separate proof sources.

Indexed Map writes now prefer declared source key and value carriers over broad canonical reference fallbacks. The module-value type import cache was also changed from `Map<U32, I32>` to dense `Array<I32>` and `Array<Bool>` storage. The key range is already the source type arena, so dense storage removes an unnecessary generic Map carrier boundary.

## Current boundary

Compiler A now produces a Starshine-valid compiler B again. Compiler B starts and reaches semantic inference. The earlier poison receiver and invalid compiler-B Wasm failures are gone.

The first remaining failure is a runtime nominal cast in a Map lookup. The failing generated lookup reads an I32 key from Map field `60`, but its stored key backing has a different nominal Array type. The next canary must certify one key and value carrier pair for every retained Map object before any `get`, `contains_key`, `set`, or indexed write is emitted.

Latest logs:

- `.tmp/runtime-first-builtin-content-name-interner.log`
- `.tmp/runtime-first-dense-module-value-import-cache.log`
- `.tmp/runtime-first-indexed-map-inferred-carrier.log`

## Map and field proof updates

Every retained Map `get`, `contains_key`, `set`, `insert`, and indexed write now selects its key and value carriers from one shared declared-container rule. A compile-time assertion compares the selected runtime carrier with the receiver's declared Map arguments. The diagnostic includes the module, declaration, body, specialization, expression, receiver, operation, argument number, expected shape, and actual shape.

The collected module value-binding table now uses dense `Array<Option<SelfHostValueBinding>>` storage. Name IDs are dense arena indices, so this removes another generic `Map<U32, value>` carrier boundary. Collection checks that every interned name has one parallel value-binding slot.

Field inference now stores the exact receiver nominal owner with each selected field. Wasm body validation checks all three identities:

- the inferred field declaration;
- the inferred receiver owner;
- the selected physical field type.

The checks stop field-name fallback from selecting a same-carrier field on another nominal type.

A regression test covers two fields read from an Array loop item. It proves that `declaration` and `builtin_name` keep their exact field and receiver identities.

## Cleared runtime cast

Compiler B previously trapped in the generated `self_host_lowering_builtin_name` loop. The emitted loop reached incompatible nominal field casts while it searched `Array<SelfHostLoweringBuiltinRecipe>`.

The lookup now uses an indexed loop. This keeps the Array element's nominal result attached to the indexed read. Compiler B no longer traps in this function.

The bootstrap now returns to the earlier and more useful lowering canary in `std/blake3.dew`:

```text
program lowering has a poison runtime method receiver module=7208 declaration=30958124269573 body=30958124269573 expression=10 type=5 nominal=0 reference=error source_name=values offset=334 locals=
```

The empty `locals=` suffix proves that the problem is earlier than method selection. The failing body reaches lowering without any merged local records. The next check must validate body-name job output before merge and require each source let item to produce one local record.

The lowering validator now also checks every retained planned let item for a valid local ID. That check does not fire for this body. This result narrows the bug to the source body or block-item span, or to name-job merge data that omits the let item before lowering.

Latest logs:

- `.tmp/runtime-first-map-carrier-contract-all-branches.log`
- `.tmp/runtime-first-indexed-builtin-recipe-lookup.log`
- `.tmp/runtime-first-name-local-diagnostic.log`
- `.tmp/runtime-first-let-local-gate.log`

## Wildcard binding identity bug

The `std/blake3.dew` lost-local failure was a parser bug. The parser used this String pattern:

```text
SelfHostTokenKind::Identifier("_", _)
```

The self-hosted compiler treated ordinary identifier payloads as this wildcard case. For example, `values` was lowered as a discarded wildcard initializer. Its body contained only expression items and no local record.

The parser now extracts the identifier and compares its content with `dew_string_equals`. The same fix applies to nested product bindings. A name such as `dependencies` is no longer accepted as `_`.

The executable gates now include:

- collected body, block, block-item, and expression arena bounds;
- one explicit physical kind for each source and HIR block item;
- a retained source name for discarded let items;
- proof that only the exact `_` spelling can produce a discarded let;
- one valid local for each planned let item;
- declaration-location arena length and owner mapping checks.

This cleared both earlier poison receivers:

- `values` in `std/blake3.dew`;
- `dependencies` in `self_host_plan_program_module_graph`.

Compiler B now runs for about 34 seconds before the next failure:

```text
RuntimeError: array element access out of bounds
    at wasm-function[1153]
    at wasm-function[1181]
```

Function `1153` is the generated declaration-reference lookup. It checks the semantic declaration ID against the logical declaration-location length, then traps while reading the physical backing array. The new collected declaration-location validator passes. This narrows the next proof boundary to the physical Array contract:

```text
logical length <= backing array length
```

The contract must also prove that every push, growth, and retained field uses the same backing nominal Array type.

Latest logs:

- `.tmp/runtime-first-content-wildcard-binding.log`
- `.tmp/runtime-first-content-product-wildcard.log`
- `.tmp/runtime-first-declaration-arena-gate.log`
