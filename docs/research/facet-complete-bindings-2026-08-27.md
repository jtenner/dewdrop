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

One module owns all raw foreign imports. The public wrappers use broad operation
groups:

```text
dew.std.facet
dew.std.facet.imports
dew.std.facet.core
dew.std.facet.fs
dew.std.facet.process
dew.std.facet.clock
dew.std.facet.random
dew.std.facet.poll
dew.std.facet.net
```

`dew.std.facet.imports` declares the raw adapter functions as public foreign
library members. The grouped modules call them through an import alias without
an extra forwarding function. `dew.std.facet.fs` includes `fd_sync` and
`fd_datasync`. The old fine-grained Facet modules and the old
`dew.std.fs.facet` and `dew.std.process.facet` adapters were removed.

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

The smoke module references every grouped public function and requires exactly
the 261 canonical `facet` imports after static linking. Parser, interface, and
semantic tests also require public foreign library members to survive an import
alias and remain directly callable.
