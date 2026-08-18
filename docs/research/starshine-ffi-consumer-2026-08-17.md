# Starshine raw FFI consumer

Date: 2026-08-17

## Result

Dewdrop now generates raw Dew declarations by inspecting every function export in the pinned Starshine WasmGC FFI module.

Inputs:

- `starshine-mb/dist/ffi/starshine-ffi.wasm`
- `starshine-mb/ffi/src/ffi/export-names.generated.json`

Outputs:

- `self_host/starshine/ffi.dew`
- `self_host/starshine/ffi-bindings.json`

The generator checks that the binary function-export set exactly matches Starshine's export-name metadata. It reads each exported Core Wasm function signature and maps primitive carriers directly. Each concrete WasmGC reference type gets a Dew foreign marker type. Nullable signatures use `NullableRef<StarshineRefN>` and preserve the same underlying marker identity.

The current provider has 3,350 function exports. Dew declares all 3,350. The 170 nullable signatures that were initially blocked now lower to exact `(ref null N)` parameters and results.

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
- all 3,350 generated Starshine declarations and a zero-entry unsupported list.

The complete Starshine provider still exposes a separate pre-existing linker validation problem: Starshine reports `func[15771]: type mismatch` for the linked candidate, while `wasm-tools validate --features all` accepts the encoded candidate. This is not caused by nullable signatures; the tiny non-null `I32::new` consumer reproduces it. The synthetic exact-nullability linker tests pass.

## Reproduction

```sh
tools/starshine-ffi.sh build
python3 tools/generate_starshine_ffi_consumer.py
python3 tools/generate_starshine_ffi_consumer.py --check
tools/dew check self_host/starshine/ffi.dew self_host/starshine/smoke.dew
tools/module-snapshots/run.sh --fixture wasmgc/nullable-ref-as-non-null-trap
```
