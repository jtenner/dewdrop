# Outlined scalar instruction contracts

## Fault

The public Dew request for `examples/transforms/overloads.dew` failed after its transform had expanded. The message was `outlined builtin needs an explicit instruction stack contract`. The selected Bool callback uses `i32.eqz`. Both compilers could interpret that instruction, but neither backend emission table nor raw stack-contract table listed it. Taking its address required a real Wasm wrapper, so the missing backend entry became visible. The earlier overload-selection fix remains required and unchanged.

The coverage check found 109 of 136 Core Wasm scalar numeric instructions in the Native emission tables. The 27 missing entries were:

- `i32.eqz`, `i32.clz`, `i32.rotl`, `i32.rotr`;
- `i64.eqz`, `i64.clz`, `i64.ctz`, `i64.popcnt`, `i64.rotl`, `i64.rotr`, and `i64.extend8_s`, `i64.extend16_s`, `i64.extend32_s`;
- `f32.min`, `f32.max`, `f32.copysign`, `f64.min`, `f64.max`, `f64.copysign`;
- all eight signed/unsigned F32/F64 saturating conversions to I32/I64.

This scope excludes constants, reference operations, memory access, and SIMD. Each added backend entry is one Wasm instruction. It does not implement a library algorithm or choose behavior from a declaration name or module path.

## Change

`tools/wasm_scalar_intrinsics.py` defines the 136 instruction names, their Starshine constructors, and stack carriers. `generate_wasm_scalar_intrinsics.py` generates the existing Native numeric/conversion emitters and two scalar signature helpers. Native and Dew raw-contract lookup use those helpers. Reference, memory, and SIMD contracts remain in their own tables.

The existing Dew emission generator checks that the two Native tables match this catalog, then emits its normal linked instruction table. The standard FFI consumer generator adds 25 missing constructor declarations from exports already present in the pinned provider. The provider binary does not change. Both `eqz` constructors were already declared.

The generated runtime fixture calls every instruction directly and through a function value. It tests concrete results. Saturating signed conversions use the exact upper bound and require the signed maximum; unsigned cases clamp a negative value to zero. The runtime source and test source are separate so the same runtime source is valid in a public non-test request.

At this backend checkpoint, thirteen integer operations still lacked interpreter support. The later byte/vector checkpoint adds clz/ctz/popcnt in both widths, rotl/rotr in both widths, and the three I64 sign extensions to both VMs. See `transform-byte-vector-execution-2026-10-19.md` for its tests. Float min/max/copysign and saturating conversion execution already existed in the VM; they now have complete backend contracts and emission.

## Reproduce

```sh
mise exec wasm-tools@1.262.0 -- tools/test-scalar-intrinsics.sh
mise exec wasm-tools@1.262.0 -- tools/test-scalar-intrinsics.sh COMPILER.wasm
```

The optional compiler argument adds actual Dew requests for the public overload example and all 136 runtime checks. It validates both output modules and requires `main() == 42`.

## Results

- All 136 Native-generated direct/outlined runtime tests passed. Test generation: 0.264 seconds; Wasm validation: 0.012 seconds; runtime execution: 0.029 seconds. The cold Native generator rebuild took 27.879 seconds; the final unchanged build check took 0.029 seconds.
- The Native negative contract test passed six malformed signatures in one test, 9.746 seconds. The existing Native overload source test passed, 8.541 seconds.
- All seven Dew outlined-builtin tests passed, including the new Bool `eqz` callback regression. Generation: 5.681 seconds; link and validation: 1.183 seconds; execution: 0.068 seconds.
- A private compiler A source build passed in 16.666 seconds. Link: 1.153 seconds; explicit Wasm validation: 0.023 seconds.
- The actual public overload request passed in 2.854 seconds. Its emitted Wasm validated in 0.015 seconds and returned 42 in 0.023 seconds.
- The actual public scalar fixture request passed in 1.373 seconds. Its emitted Wasm validated in 0.014 seconds and all 136 checks returned 42 in 0.022 seconds.
- The scalar source/contract/fixture generators, FFI consumer check, and both changed policy tests pass. `tools/check-generated.sh` now includes the new generator checks.

Evidence is under `.tmp/transforms-v3/scalar-contracts/`: `full-scalar-runtime-final.log`, `native-contract-tests.log`, `dew-backend-tests.log`, `compiler-A-build-final.log`, `compiler-A-link.log`, `compiler-A-validate.log`, and `generator-checks.log`. The private linked compiler SHA-256 is `bc7afe18e1f7de771572ec5936ebbb421adaeb673bf4cbb3c3f44f572d928cb0`. The exact owned file list is `owned-files.txt` in that directory.

The linked compiler grew from 2,717,565 to 2,721,828 bytes (+4,263; about 0.16%). Its unlinked core grew from 3,456,007 to 3,469,161 bytes (+13,154; about 0.38%). Build identity and source were fixed during these checks. The times are completion measurements, not a controlled speed benchmark. Initial fixture/runner failures remain in separate logs: a too-large float literal, test declarations passed as runtime source, and missing `wasm-tools` in the runner PATH. The final fixture uses valid literals, separate source files, and the pinned tool environment.
