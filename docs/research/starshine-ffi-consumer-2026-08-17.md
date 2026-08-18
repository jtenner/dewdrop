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

The production provider now links with normal Starshine validation and post-link cleanup enabled. The earlier `func[15771]: type mismatch` was a Starshine validator bug: MoonBit emitted two separately indexed but structurally equivalent mutable `f64` array types, and ordinary defined-reference matching followed only declared subtype chains. Starshine commit `a7f0b6b05` adds canonical structural equivalence before subtype traversal.

That repair exposed a second Starshine cleanup bug. A retained declaration-only element segment contained both live and dead functions; RUME converted the dead function's `-1` remap into an invalid unsigned function index. Starshine commit `f9e312013` tracks declaration-only versus runtime element use and prunes dead declaration entries before remapping survivors. Both commits are pushed to `starshine-mb` `master`.

At pinned Starshine revision `f9e31201392df4a08586e2a71f3ffa342d8422bd`, the regenerated provider SHA-256 is `6acfccb8afcb1e9d296d99ed7e5f4611e30fd0f7ceb65112bd8c667ba878681b`. Two complete linked smoke builds are byte-identical at 680,107 bytes and SHA-256 `1fc978dd89dc8abd58c50dc7d67d880dc2841cb57d8bad7c58497cf153144c14`; `wasm-tools validate --features all` accepts the result.

## Reproduction

```sh
tools/starshine-ffi.sh build
python3 tools/generate_starshine_ffi_consumer.py
python3 tools/generate_starshine_ffi_consumer.py --check
tools/dew check self_host/starshine/ffi.dew self_host/starshine/smoke.dew
tools/module-snapshots/run.sh --fixture wasmgc/nullable-ref-as-non-null-trap
```
