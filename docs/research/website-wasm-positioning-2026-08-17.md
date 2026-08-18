# Website Wasm positioning evidence

Date: 2026-08-17

## Selected example

The landing page uses the existing `tests/module-snapshots/structs/construct-read.dew` program. It defines a two-field `Pair`, reads both fields in `sum`, constructs one value, and exports `main`.

This example is small enough to show the complete relevant module. Its generated output directly contains:

- one Wasm GC `(struct (field i32) (field i32))` type;
- `struct.get` for both Dew field reads;
- `struct.new` for the Dew constructor;
- a direct `call` to `sum`; and
- an explicit `main` function export.

The module has no imports and no linear memory.

The second example exports `maybe` and `divide`. It uses the standard `Option<I32>` and `Result<I32, I32>` types. The compiler emits tagged Wasm GC struct families:

- `Option::None` uses tag `0`.
- `Option::Some` uses tag `1` and the `i32` payload field.
- `Result::Ok` uses tag `0` and the `i32` payload field.
- `Result::Err` uses tag `1` and the `i32` payload field.

Each payload subtype contains only its tag and the carrier that its Dew type needs. For `Option<I32>` and `Result<I32, I32>`, each payload subtype has two `i32` fields. The compiler does not add empty `i64`, `f32`, `f64`, `v128`, or reference slots.

## Verification

The current native Dewdrop CLI compiled `docs/website/examples/direct-struct.dew` to a 458-byte Wasm module. `wasm-tools validate --features gc` accepted it. After `wasm-tools strip` removed only custom metadata sections, `wasm-tools print` produced output that matched both:

- `docs/website/examples/direct-struct.wat`; and
- `tests/module-snapshots/structs/construct-read.wat`.

The compiled Wasm SHA-256 was `fec7a518f7ec5045460954d929a9f2f9d12cc991a9e3498ff0f0c765e1850d68`.

The current native Dewdrop CLI also compiled `docs/website/examples/option-result.dew` to a 534-byte Wasm module. `wasm-tools validate --features gc` accepted it. Its stripped and printed output matched `docs/website/examples/option-result.wat` exactly. The compiled Wasm SHA-256 was `e5140da57747887ee05bed0b6c2c81fa2071b1fe2c74615fed3f68842f673b09`.

Both annotated WAT files parse and validate. Printing them removes the comments and produces their raw WAT files exactly.

## Supported claims used on the page

- Dewdrop emits core WebAssembly GC modules.
- Struct construction and field access can map to `struct.new` and `struct.get`.
- Public root functions become Wasm exports.
- The compiler performs program-wide reachability and static linking.
- WASI Preview 1 adapters are implemented for host I/O.
- Compiler snapshots check deterministic Wasm and canonical WAT.

## Claims not used

- No benchmark numbers are shown because this work did not run a current public benchmark suite.
- Self-hosting is not presented as a current user capability because that work is not complete.
- Dew is not described as stable or released. The page states that it is under active development.
- Package maturity and broad ecosystem claims are omitted.
