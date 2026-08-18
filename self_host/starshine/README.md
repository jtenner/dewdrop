# Starshine FFI consumer

Dewdrop pins the raw Core WasmGC provider at the `starshine-mb` submodule revision. Starshine currently exports 3,366 concrete functions. Dewdrop selects the exact compiler-facing subset in `ffi-used.json`; the generated `ffi.dew` currently contains 32 raw carrier declarations.

Starshine's `ffi_bridge` package provides the typed mutable arrays, module constructor, validation result, and encoded-byte inspector needed by Dew. It does not add a second command language.

## Generate

```sh
tools/starshine-ffi.sh build
python3 tools/generate_starshine_ffi_consumer.py
```

Generated files:

- `ffi.dew`: exact selected foreign carrier declarations;
- `ffi-bindings.json`: selected names and signatures, provider SHA-256, submodule revision, and SHA-256 digests for the `lib`, `binary`, `validate`, and `ffi_bridge` interfaces;
- `fingerprint-prefix.bin`: canonical compiler-fingerprint prefix;
- `fingerprint.dew`: Dew BLAKE3 helper over the prefix followed by the exact provider bytes.

The compiler fingerprint changes when the submodule revision, an interface digest, a selected export name or signature, or any provider byte changes.

## Check

```sh
PYTHONPATH=tools python3 tools/test_starshine_ffi_consumer.py
python3 tools/generate_starshine_ffi_consumer.py --check
tools/dew check \
  self_host/starshine/ffi.dew \
  self_host/starshine/fingerprint.dew \
  self_host/compiler/tokenizer.dew \
  self_host/compiler/parser.dew \
  self_host/compiler/request.dew \
  self_host/compiler/starshine_module.dew \
  self_host/compiler/main.dew
tools/check-self-host-smoke.sh
```

The smoke compiler reads a frozen version-1 source-Bytes request through WASI, verifies the compiler fingerprint against the request's exact Starshine provider bytes, tokenizes and parses the bounded `pub fn main() -> I32` bootstrap grammar, builds and validates one module through Starshine, and writes the encoded Wasm output. The harness builds the linked compiler twice in separate directories, requires byte-identical compiler and output modules, validates both, checks the emitted `i32.const 73`, and rejects a modified fingerprint plus an unbounded module count.
