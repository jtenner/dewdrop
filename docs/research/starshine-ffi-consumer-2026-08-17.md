# Starshine raw FFI consumer

Date: 2026-08-17

## Result

Dewdrop now inspects every function export in the pinned Starshine WasmGC FFI module and generates raw Dew declarations only for the exact compiler-used subset.

Inputs:

- `starshine-mb/dist/ffi/starshine-ffi.wasm`
- `starshine-mb/ffi/src/ffi/export-names.generated.json`

Inputs and selection:

- `self_host/starshine/ffi-used.json`
- `starshine-mb/src/lib/pkg.generated.mbti`
- `starshine-mb/src/binary/pkg.generated.mbti`
- `starshine-mb/src/validate/pkg.generated.mbti`
- `starshine-mb/src/ffi_bridge/pkg.generated.mbti`

Outputs:

- `self_host/starshine/ffi.dew`
- `self_host/starshine/ffi-bindings.json`
- `self_host/starshine/fingerprint-prefix.bin`
- `self_host/starshine/fingerprint.dew`

The generator checks that the binary function-export set exactly matches Starshine's export-name metadata. It reads each exported Core Wasm function signature and maps primitive carriers directly. Each concrete WasmGC reference type gets one stably named Dew foreign marker type. Nullable signatures use `NullableRef<NamedCarrier>` and preserve the same underlying marker identity.

## Stable carrier names (2026-09-04)

All 17 selected reference carriers now have names derived from the provider API,
not from Wasm heap type numbers. For example, `StarshineModule`,
`StarshineFieldType`, and `StarshineEncodedModule` name foreign types directly.
`CodeSec::new` returns `StarshineCodeSec`, an alias of `StarshineFunctions`.
Sections that share their backing array retain one foreign identity. The
generator checks each alias against explicit provider signature probes and
rejects references without an assigned name. Nullability remains at each use.
Raw indices remain in `ffi-bindings.json` for physical linking and diagnostics.

Regeneration includes the previously pending provider metadata and fingerprints
for pinned revision `89be0d37df99fc8cfcb0a7983b0865ca67d439d6`: 386 selected
exports from 4,190 available exports. The two pending provider generated-export
files are now committed in the submodule as `2f9f705a0`, and the parent pin and
fingerprints include that revision. The provider worktree is clean. A fresh
provider rebuild took 11.218 seconds and reproduced the same provider bytes.
The cache-disabled A/B/C check also passes from clean tracked source; see
[the final verification record](library-owned-runtime-2026-09-04.md#final-verification-for-this-commit-series).
A separate cloned checkout was not tested. These new commits are local and
have not been pushed.

Validation: all eight generator tests pass (0.05 seconds), generation takes
4.12 seconds, and the self-host hardening lane passes: 92 Dew tests, 16 trap
records, two record-decoder tests, 13 emission probes, and four semantic probes.
Tests check stable declarations after type renumbering, nullable named types,
constructor result aliases, and missing-name diagnostics.

At pinned Starshine revision `c544a96d367351145aecdbbc9c6e40e6095e13ca`, the provider has 3,366 concrete function exports. The typed bridge API was introduced in `664cafba9`; `c544a96d3` keeps its generated interface in Moon's canonical form. Dew declares the exact 32 exports used by the linked smoke compiler. Nullable signatures lower to exact `(ref null N)` parameters and results.

Starshine's `ffi_bridge` package provides typed mutable builders for `Array[ValType]`, `Array[RecType]`, `Array[TypeIdx]`, `Array[Instruction]`, and `Array[Func]`, plus an empty module constructor, validation, and encoded-byte inspection. This keeps the boundary on the public object model without adding a command language.

## Nullable foreign references

`dew.std.wasm.intrinsics` now provides the compiler-known `NullableRef<t>` carrier for foreign `t`, plus direct WasmGC operations:

```dew
wasm_ref_null<t>() -> NullableRef<t>
wasm_ref_is_null<t>(value: NullableRef<t>) -> Bool
wasm_ref_as_non_null<t>(value: NullableRef<t>) -> t
```

A non-null foreign `t` widens to `NullableRef<t>` without a runtime instruction. The linker binds non-null and nullable references separately while using the same foreign marker identity. `NullableRef` rejects primitive, structural, nested-nullable, and other non-foreign arguments.

## Integer newtypes

A raw `i32` signature does not retain the MoonBit source newtype name. Calls must preserve the source API's semantic constructors even when the physical carrier is the same.

For example, the smoke consumer calls `I32::new` before `Instruction::i32_const`:

```dew
let value = StarshineFfi.ffi_lib_I32_new(42i32)
StarshineFfi.ffi_lib_Instruction_i32_const(value)
```

This keeps the Starshine API boundary explicit and avoids treating an untagged Dew integer as a Starshine `I32` value.

## Validation

Coverage includes:

- semantic rejection of primitive and nested nullable arguments;
- frozen cross-module interface transport;
- zero-instruction non-null-to-nullable widening;
- exact nullable function parameters, results, locals, and physical references;
- direct `ref.null`, `ref.is_null`, and `ref.as_non_null` emission;
- runtime null observation and `ref.as_non_null` trapping in Node and Wago;
- linker marker binding, `ref.null` type remapping, and both nullability-mismatch directions;
- exact ordered selection of 32 declarations from 3,366 available provider exports;
- rejection of missing or duplicate selected exports;
- interface and selected-signature fingerprint-prefix changes;
- typed Starshine array and encoded-result bridges.

The production provider now links with normal Starshine validation and post-link cleanup enabled. The earlier `func[15771]: type mismatch` was a Starshine validator bug: MoonBit emitted two separately indexed but structurally equivalent mutable `f64` array types, and ordinary defined-reference matching followed only declared subtype chains. Starshine commit `a7f0b6b05` adds canonical structural equivalence before subtype traversal.

That repair exposed a second Starshine cleanup bug. A retained declaration-only element segment contained both live and dead functions; RUME converted the dead function's `-1` remap into an invalid unsigned function index. Starshine commit `f9e312013` tracks declaration-only versus runtime element use and prunes dead declaration entries before remapping survivors. Both commits are pushed to `starshine-mb` `master`.

Starshine commits `664cafba9` and `c544a96d3` add the typed bridges and canonical generated interface; both are pushed to `master`. The regenerated provider SHA-256 is `b0108c45dd634f9f3c9c971663ee3a3016ab9c35488573b7fe375d6a0f041f63`.

The compiler fingerprint is BLAKE3-256 over a canonical prefix containing the submodule revision, four interface SHA-256 digests, and every selected export name and signature, followed by the exact provider bytes. With the complete in-memory tokenizer and first parser slice linked, the source-request compiler builds byte-identically at 898,311 bytes with SHA-256 `130e30b3e5d5b8d76620a589328092f92eaa33f5d00a5d2287e877e7e496e576`. It emits a 28-byte validated module containing `i32.const 73`, with SHA-256 `abaf57175758ac133a309c4700feface2a9ad611b3eb0fe926d1036bee80e288`. The harness rejects both a one-byte compiler-fingerprint mutation and an unbounded `0xffffffff` module count.

## Reproduction

```sh
tools/starshine-ffi.sh build
python3 tools/generate_starshine_ffi_consumer.py
python3 tools/generate_starshine_ffi_consumer.py --check
PYTHONPATH=tools python3 tools/test_starshine_ffi_consumer.py
tools/dew check \
  self_host/starshine/ffi.dew \
  self_host/starshine/fingerprint.dew \
  self_host/compiler/request.dew \
  self_host/compiler/starshine_module.dew \
  self_host/compiler/main.dew
tools/check-self-host-smoke.sh
```
