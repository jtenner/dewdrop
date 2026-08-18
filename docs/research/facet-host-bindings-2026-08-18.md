# Facet host bindings — August 18, 2026

## Result

Dewdrop now uses `facet` as the host provider and import-module name.

Public standard modules:

```text
dew.std.fs.facet
dew.std.process.facet
```

Static linking:

```sh
tools/dew build \
  --link-wasm facet fixtures/facet/facet-adapter.wasm \
  -o app.wasm app.dew
```

## Audited source

The bindings follow:

```text
https://github.com/jtenner/facet-spec
```

Audited commit:

```text
c6014e7f086f3d3d7ff5e1e7d65a7e6f24e1dcab
```

The Core Wasm import module is `facet`. The previous import-module namespace is
not retained as a compatibility alias.

## ABI changes applied

- Removed `fs_scratch`. Filesystem access starts from `fs_preopen_get(index)`.
- Removed argument, environment, and string-resource handles.
- Arguments use `args_len_i8` and `args_read_into_array_i8`.
- Environment fields use `env_len_i8` and `env_read_into_array_i8` with field
  selectors `0` for the name and `1` for the value.
- Text transfer uses strict UTF-8 with `wtf == 0`.
- Path transfer uses strict UTF-8 with `wtf == 0`.
- Added `abi_version`; Facet 0.1 reports ABI generation `1`.
- Removed the provider-specific memory-zero linker rule. Facet linear-memory
  operations select memory explicitly, and this adapter uses GC arrays.

## Generated adapter

Source:

```text
tools/facet-adapter.wat
```

Generated provider:

```text
fixtures/facet/facet-adapter.wasm
```

SHA-256:

```text
6c94d783980b003c1330b7397f3321f5ade3e99ce81791522553a0f4a283058f
```

Reproduce and validate it with:

```sh
python3 tools/generate_facet_adapter.py
tools/check-facet.sh
```

The smoke check links the Dew filesystem and process adapters, validates the
result, requires the selected `facet` imports, and rejects legacy import names.
