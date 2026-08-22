# Self-host driver semantic pipeline

Date: 2026-08-22

The version 1 compile-request decoder now retains the complete manifest instead of discarding every module and file except the root source.

The decoded request carries:

- the root module name;
- all manifest modules in request order;
- all logical file paths and source bytes;
- test and default-preamble flags;
- the exact Starshine provider and compiler fingerprint;
- the output path.

Before the temporary smoke emitter runs, the compiler driver now executes the production self-host semantic path:

```text
request manifest
→ multi-module collection
→ signature-interface freezing
→ imported semantics
→ program lowering
→ transitive specialization
→ WasmGC fragment ABI planning
```

Invalid manifests, imports, or missing root modules now fail before output emission. The current final emitter remains the bounded `I32` smoke emitter; replacing it with fragment body emission, physical linking, and complete encoding is the next driver tranche.
