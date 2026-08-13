# Generated WebAssembly intrinsic parity

Status: implemented August 12, 2026.

## Scope

`dew.std.wasm.intrinsics` is the explicit source-addressable view of Dewdrop's backend inline-builtin surface. The module covers every inline operation that currently has a Dew-safe carrier signature: scalar arithmetic and comparisons, numeric conversions, typed linear-memory access, SWAR operations, V128 and typed-lane operations, fixed lane extraction/replacement, SIMD memory forms, shuffles, narrowing/widening, and cross-lane conversions.

Reference, WasmGC, table, and host-boundary instructions are not declared merely to mirror the Core instruction catalog. Dew does not yet expose raw reference/table/index or host-handle carrier types with contracts suitable for a public intrinsic API. Those families should be added only with their carrier, validation, and ABI rules.

## Generation contract

`tools/generate_wasm_intrinsics_std.py` scans all Dew standard sources except the generated target and test files. Every `builtin` declaration whose external name is recognized by backend inline emission becomes a public declaration in `std/wasm/intrinsics.dew` with:

- the exact existing Dew parameter and result signature;
- the exact backend external name;
- a `wasm_` prefix on the public alias, preventing collisions under `open dew.std.*`;
- stable path and source order.

The backend name set is extracted from `starshine_code.mbt` and every `starshine_*builtins.mbt` file. The otherwise internal `i32_lt` operation has one explicit generated signature. Generation fails if:

- a backend inline name has no Dew declaration;
- two generated aliases collide;
- the checked-in source or bootstrap mirror is stale.

The first published `i64_trunc_i32` spelling remains as a compatibility alias. The generated module currently contains 1,314 aliases covering 830 distinct backend inline names. Multiple aliases are intentional where typed packed-lane APIs share one physical operation. One added declaration, `wasm_bytes_load_u8x16(Bytes, U32)`, is a bounds-checked WasmGC representation bridge rather than a linear-memory load; it exists so Dew source can apply ordinary SIMD instructions to private GC-backed Bytes without adding domain-specific scanner builtins.

## Validation

`std/tests/04_wasm_intrinsics_test.dew` directly exercises scalar arithmetic, `u32_ctz`, the backend-only comparison, integer truncation, float square root, typed memory, and SIMD through the imported intrinsic module. Text tests separately exercise aligned, unaligned, and bounds-failing GC-backed Bytes SIMD loads.

The module snapshots:

- `tests/module-snapshots/wasm/intrinsics-core-runtime.dew`
- `tests/module-snapshots/wasm/intrinsics-runtime.dew`

execute in Node and the pinned Wago Core 3 runner. The core WAT architecture case forbids host imports, linear memory, function references, globals, and tables while requiring the exact native instructions `i32.add`, `i32.lt_s`, `i32.wrap_i64`, `f32.sqrt`, `i32x4.splat`, `v128.xor`, and `v128.any_true`. The memory fixture separately proves typed linear-memory intrinsics remain directly executable.

## Maintenance

After changing any backend inline builtin name or any standard builtin signature, run:

```text
python3 tools/generate_wasm_intrinsics_std.py
python3 tools/generate_wasm_intrinsics_std.py --check
```

Generated-source checks run the parity validation on every full or quick project check.
