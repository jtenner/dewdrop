# Complete Facet bindings — August 27, 2026

## Audited inputs

The implementation was checked against:

```text
wago-facet commit 471eb2f3fe3c1dadad1fbb153f5c15b10ba71c4a
facet-spec commit c3d06ad1b3e7f8ad6b83ecb4e96e999c922b5140
```

The plugin implements the complete canonical Facet 0.1 surface: 261 imports.
The pinned canonical declarations are stored in `tools/facet-imports.wat`.

## Dew namespaces

The low-level bindings are split by operation group:

```text
dew.std.facet
dew.std.facet.process
dew.std.facet.clock
dew.std.facet.random
dew.std.facet.fs.preopen
dew.std.facet.fs.descriptor
dew.std.facet.fs.read
dew.std.facet.fs.write
dew.std.facet.fs.position
dew.std.facet.fs.sync
dew.std.facet.fs.path
dew.std.facet.fs.directory
dew.std.facet.fs.link
dew.std.facet.net.socket
dew.std.facet.net.datagram
dew.std.facet.net.dns
dew.std.facet.poll
```

`dew.std.facet.fs.sync` exposes `fd_sync` and `fd_datasync`.
The existing provider-neutral `dew.std.fs.facet` and
`dew.std.process.facet` modules remain supported.

## Representation rules

The generated adapter preserves the canonical raw imports. It converts
multi-value results into WasmGC result records that Dew can consume. Allocating
GC string results keep nullable references inside private foreign records and
become typed Dew `Result` values only after the error code is checked.

Numeric and abstract-reference GC arrays need structural type coalescing across
the Dew module and the static-link provider. The Core Wasm linker now coalesces
non-nominal array fields, not only packed `i8` and `i16` fields. Arrays whose
elements contain a defined reference type remain nominal.

## Generation and validation

Regenerate the source, adapter, and fixture with:

```sh
python3 tools/generate_facet_bindings.py
python3 tools/generate_host_std.py
python3 tools/generate_facet_adapter.py
```

Run the complete smoke gate with:

```sh
tools/check-facet.sh
```

The smoke module references every low-level function and requires exactly the
261 canonical `facet` imports after static linking.
