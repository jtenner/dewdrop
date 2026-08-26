# Self-host fixed-point harness

Date: 2026-08-22

`tools/check-self-host-bootstrap.sh` now owns the complete fixed-point sequence:

1. MoonBit Dewdrop builds compiler A with the pinned Starshine provider.
2. The bootstrap fixture writes the full source request in stage A's physical directory.
3. A builds compiler B.
4. The same logical inputs are written in stage B's physical directory.
5. B builds compiler C.
6. A, B, and C are validated.
7. B and C are compared byte-for-byte.
8. Separate B and C SHA-256 digests are printed.

Each stage uses a separate directory. The normal command reuses Dew's content-addressed compiler A build cache. This only copies an exact artifact for the same source and provider inputs. `tools/check-self-host-bootstrap.sh --clean` disables that cache for a cold fixed-point check.

The harness skips the Starshine provider rebuild when its source files are not newer than the existing provider module. Long Wasm compiler stages use Node with `--no-liftoff`, which compiles Wasm with the optimizing compiler instead of the slower baseline execution path. On the current full-source failing stage, this reduced the run from about 894 seconds to about 361 seconds.

`tools/check-self-host-smoke.sh` now stays a focused backend smoke lane. It does not repeat the full parser, semantic, and corpus lanes that `tools/test-native.sh` already owns. It builds and runs one compiler copy. `--clean` disables the build cache and retains the cold duplicate-build and duplicate-run checks. The old duplicated validation can be requested only for diagnosis with `DEW_SELF_HOST_FULL_VALIDATION=1`.

Unqualified enum variants remain supported. `Some(...)` and `None` are selected from the expected nominal type when context identifies `Option`; the `Option::` prefix is not required. This applies to constructor values, constructor calls, and match patterns. The backend also recovers the unqualified pattern name when it selects the runtime Option subtype.

The harness is complete, but the fixed point does not pass yet.

The self-host backend now emits closure bases, lambda subtypes, lambda functions, named function references, declarative function elements, direct and environment-first `call_ref` dispatch, memory load/store builtins, mutable module globals and startup initializers, index reads, generic object-field recovery by name, tuple construction and projection, array literals, iterator operations, array mutation, map operations, synthetic WASI imports, and enough runtime support for compiler A to emit compiler B. The focused smoke fixture covers both lambda and named function values.

## 2026-08-24 validation progress

Compiler B is now emitted. External validation advanced from function 1114 through function 1211 after these fixes:

- divergent `if`, `match`, and `while` expressions use a unit result shape;
- function-value signatures recover physical struct-field carrier types;
- function-value arguments recover scratch-local carrier types from initializers, assignments, match bindings, and loop bindings;
- unresolved receiver calls used by the WASI path helpers now receive their missing receiver value.

The current external validator failure is in physical function 1211 at offset `0x1c22f`:

```text
type mismatch: expected eqref, found i32
```

The emitted sequence applies `i32.eqz` to a divergent expression, stores that scalar in an `eqref` closure local, and then dispatches it with `call_ref`. The next fix must recover the correct expression/local relationship before closure dispatch. The normal Starshine validation gate is enabled; validation is bypassed only during temporary external-diagnostic runs.

## 2026-08-24 focused product regression loop

Repeated full A-to-B runs took about 440 seconds, so product-carrier work now uses the smoke fixture first. A cached native rebuild of compiler A takes about 9.3 seconds, and A compiles the focused fixture in about 0.2 seconds. The complete smoke gate takes about 13.6 seconds.

The focused fixture covers both direct `(I32, Ref)` parameters and products returned by a `match` arm, then destructured into scalar and reference fields. This exposed an inconsistent ABI: function signatures flattened products into multiple Wasm values while expression emission allocated two-field runtime structs.

Product signatures now use one nullable `eqref`, matching product construction, match results, locals, and field projection. Pair projection groups separate `PlannedLocalGet` expressions by logical local identity, so both field carriers select the same runtime pair type. The focused fixture and `tools/check-self-host-smoke.sh` validate successfully with the normal Starshine validation gate enabled.

The last full bootstrap run before this focused fix reached physical function 1378.

## 2026-08-24 latest Starshine retry

The detached `starshine-mb` work now includes upstream `origin/HEAD` commit `d4cf5d56d` through local merge commit `5441bcb1f`. The provider was rebuilt in 19.058 seconds and the generated Dew FFI consumer was refreshed. Changed WasmGC reference indices were remapped in the self-host backend.

A measured fixed-point retry did not reach comparison. Compiler A took 425.707 seconds to attempt compiler B, then the normal Starshine validation gate rejected B. This is both a remaining Wasm correctness failure and a compiler performance bug. A 30-second V8 profile attributed 81.6% of samples to one generated Wasm function, `wasm-function[1029]`.

Cold compiler builds with the latest Starshine source also exceeded 30 seconds. `tools/self-host-common.sh` now reports elapsed time for compiler activities and marks any activity over 30 seconds as a performance bug. The bootstrap and smoke scripts use this timing wrapper for builds, request generation, compiler execution, and validation.

## 2026-08-25 specialization performance correction

The dominant generated function maps to program specialization planning. The planner repeatedly scanned the complete reachable-declaration array while processing each expression, then repeatedly scanned the complete declaration work queue after each body. That made compiler-sized requests quadratic.

The planner now keeps deterministic arrays for output order and uses `Map<U64, Bool>` indexes for reachable declarations, queued declarations, and scanned bodies. Reachable declarations enter the work queue through one monotonic cursor. Callable lookup also uses the module's existing declaration-index table, and specialized calls are appended once from their uniquely scanned call sites instead of searching all earlier calls.

With the experimental precomputed-fingerprint change still present, the same full compiler A-to-B request first fell from 425.707 seconds to 12.190 seconds. Earlier profiling showed that precomputing the fingerprint did not change the dominant hotspot, so that experiment was reverted and BLAKE3 provider identity was restored.

A direct final debug compiler A build takes 8.225 seconds. With the original BLAKE3 provider identity restored, direct request generation takes 2.397 seconds and compiler A reaches the existing compiler-B Starshine validation failure in 13.428 seconds. The final harness run measured compiler A build at 10.843 seconds, validation at 0.015 seconds, cached request generation at 0.100 seconds, and A-to-B execution at 13.706 seconds. The specialization performance correction therefore keeps every measured A-to-B activity below half a minute without changing fingerprint semantics.

Starshine module optimization is not supported in the current Dew assembly path. The backend no longer imports or runs `heap2local`; self-host measurements and diagnostics use validated, unoptimized debug modules. The former optimization-only iterator test now verifies that debug binary encoding preserves the expected Option allocations.

`tools/test-native.sh` now measures each Dewdrop package lane separately. All 730 routine tests pass. The slowest measured package lanes are semantic at 20.019 seconds and backend at 11.129 seconds; every package lane is below half a minute.

## 2026-08-25 compiler-B correctness triage

The normal Starshine validation gate was bypassed only long enough to encode diagnostic compiler-B artifacts. Starshine rejected the in-memory module and `wasm-tools validate --features all` rejected the encoded bytes at the same physical functions. This rules out a Starshine-only false rejection in the cases examined. The complete Starshine validator lane also passes all 1,751 tests in 13.346 seconds. A Starshine builder or encoder defect is still possible in principle, but the current failures match Dew carrier, local, and constructor-selection mistakes.

The first diagnostic artifact failed in function 1382 at offset `0x26089`: an `eqref` pair field was stored in an `i32` local. The function was mapped to `self_host_parse_optional_type_parameters`. Product projection recovery now uses binding context, match payload type arguments, and the synthetic pair runtime's carrier matrix. Product-field locals and scratch locals use the selected physical pair field carrier.

Constructor context now recovers expected field shapes through exact selected physical types and source-visible field names. Selected struct and variant constructors both use the shared object-constructor scheduler. The scheduler consumes each source field at most once, preventing one unresolved field from being reused for every physical field. The smoke fixture now includes direct and match-returned `(Bytes, I32)` and reference-first products.

External validation advanced through functions 1336, 1382, 1389, 1392, 1414, 1416, 1423, 1484, and 1509. Function 1414 was fixed by typing functional-loop scratch storage from the loop's initial value and treating unresolved iterator `next` values as references when normal inference is absent. Function 1416 exposed two more carrier gaps: generic and product block results now use `eqref`, and functional-loop payload bindings use the selected physical variant field instead of the Option container shape. Function 1423 was fixed by treating constructors and other runtime-backed value producers as references during backend shape recovery. Function 1484 was fixed by selecting `Some` and `Ok` carrier families from statically recovered argument shapes, including physical struct fields.

The function-1509 investigation found one bug in the local Starshine FFI bridge. `instructions_push_array_iter_next` returned a raw array element and performed an unchecked read. Dew uses that bridge operation for `Iter::next`, whose result is `Option<T>`. The bridge now checks the iterator length and constructs the carrier-specific `Some` or `None` subtype. This was a Starshine bridge bug, not a validator bug. The raw `dew_array_iter_next` runtime function remains separate.

Dew now recovers Array element and owner information from physical field declarations and resolved field layout types. It follows nested field and `.iter()` provenance, selects carrier-specific loop patterns and locals, emits carrier-specific Option values, handles Array push scratch carriers, and emits Array index reads and writes directly against the correct backing-array type. Nested unresolved fields also recover their nominal declaration before field lookup. These fixes advanced external validation through functions 1509, 1511, 1515, 1516, 1523, and 1526.

Function 1526 exposed a second generic-container carrier gap. The linked program contained only generic `dew_map_get` runtime functions with `eqref` key and value carriers, even though the receiver field was `Map<U64, U32>`. Dew now recovers both applied Map arguments from the receiver's physical field layout and emits `Map::get` directly with `i64` key storage, `i32` value storage, and the carrier-specific `Option<U32>` subtypes. Match result recovery is scoped to these inline map results so unrelated non-fallthrough matches retain their previous carrier.

The Starshine map lookup bridge was inspected alongside the emitted instructions. Its lookup loop, reverse search, key comparison, and carrier-specific `Some`/`None` construction agree with the valid inline sequence. The missing `U64`/`U32` runtime specialization was in Dew's linked specialization and call selection, not in Starshine's validator, builder, or encoder. The earlier iterator-next bridge defect remains the only confirmed Starshine-side bug in this sequence.

Function 1534 was caused by unresolved receiver fields falling back to the first same-named field in the whole linked program. Receiver locals now recover the owning nominal type from the callable's declared `self_type`. The large `SelfHostResolvedModuleTypes` constructor therefore reads `SelfHostTypeResolver` fields from the correct physical type.

Unresolved qualified calls named `new` exposed a separate reachability bug. Specialization previously handled only unresolved Array calls, so `SelfHostTypeResolver::new` and nested constructors could fall through to the Array runtime solely because they shared the name `new`. Specialization now uses the result local's later receiver methods and enclosing call parameter types to recover the expected nominal owner, records the correct call edge, and links the selected constructor. Synthetic Array and Map empty values are emitted by one atomic task so sibling call arguments cannot appear between their constants and `struct.new`.

Map lookup provenance now follows locals initialized from `Map::get`. The emitter carries the Map value carrier into `Some` patterns, pattern-bound locals, and match initializer locals. This advanced external validation through functions 1534, 1535, 1568, 1570, 1585, 1594, 1595, and 1597.

Subject-aware pattern recovery now follows indexed collection fields to their element nominal, selects same-named enum variants by that owner, and keeps this provenance outside `SelfHostLinkedI32EmitTask` so task payload layout remains stable. Carrier recovery for `Some`/`Ok`/`Err` patterns now uses narrowly scoped binding use and scalar result context. Selected field emission also follows the base value's nominal instead of accepting the first same-named physical field. These fixes advanced external validation through functions 1598, 1599, 1603, and 1609.

The current diagnostic artifact fails in function 1622 at offset `0x35d7f`:

```text
type mismatch: expected i32, found i64
```

The failing sequence reads an `i64` physical field and constructs an `i32` payload subtype. The remaining correction is to make `Some` constructor carrier selection prefer the owner-aware physical field carrier when a stale planned type argument says `i32`, while preserving reference-carrier constructors that rely on the normal static shape fallback.

The Starshine validator and `wasm-tools` still agree on every inspected artifact. No new Starshine bug was found. The normal Starshine validation gate is restored. The final measured harness reaches that gate in 17.104 seconds. The focused smoke passes, with compiler execution taking 2.128 seconds and the complete serial lane remaining below 30 seconds. All compiler source checks pass in about 5.6 seconds. The Starshine validator lane still passes all 1,751 tests from the last full run.
