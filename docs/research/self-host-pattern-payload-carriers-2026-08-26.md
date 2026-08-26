# Self-host pattern payload carriers

Date: 2026-08-26

Compiler B reached function 1763 but failed validation:

```text
expected i32, found eqref (at offset 0x45102)
```

The failing source was `SelfHostBodyLowerer::lower_block`. An `Option::Some(expression)` pattern loaded an `eqref` payload, but the pattern local was declared as `i32`.

The linked backend now uses direct call-parameter evidence for pattern bindings. If a bound local is passed directly to a physical reference parameter, both pattern subtype selection and local allocation prefer the reference carrier. Unresolved method calls include the receiver parameter when selecting the physical argument shape.

The scan resolves a call only after it finds the target local in that call's arguments. This keeps the recovery narrow and avoids resolving every call once per pattern local.

`src/self_host_smoke_fixture/main.mbt` now includes an `Option<PatternRefBox>` match whose payload is passed to a reference-typed function. This is the focused regression for the failure.

Validation was run under the contended host after explicitly bypassing the timing blocker. The normal gate advanced past function 1763, then rejected compiler B. The normal run took 560.604 seconds: compiler A build 137.178 seconds, A validation 0.207 seconds, request build 1.257 seconds, and A execution 351.303 seconds.

A temporary diagnostic validation bypass produced compiler B for external validation. That run took 586.966 seconds and failed at function 1801:

```text
expected eqref, found i32 (at offset 0x46c6f)
```

The malformed sequence was an inline Array `push` in `SelfHostBodyNameResolver::bind_existing_local`. The physical receiver was `Array<i32>`, but the item scratch local was declared `eqref`.

Array pushes now reserve one item scratch local for every physical carrier. The bridge selects the correct item local from the emitted carrier instead of requiring local declaration inference to choose the same carrier independently. This fixed the Array push mismatch.

The next instruction in `bind_existing_local` exposed an unresolved `Map<U32, U32>::set` call that selected a generic reference specialization. Unresolved Map writes now lower inline through the existing array-push bridge entry point, using a private Map-write bridge path and universal key/value scratch locals. This avoids unstable FFI export numbering while preserving carrier-specific Map storage.

Compiler B now validates through function 1830. The fixes after function 1801 include:

- exact physical branch-tail shapes for valued `if` expressions;
- receiver-first Map key/value ownership when the receiver provenance is reliable;
- inline unresolved and direct Map writes with the correct implicit-receiver ABI;
- early inline `contains_key` lowering before a generic reference specialization is selected;
- receiver-aware call-result recovery for Array push item locals;
- consistent Unit match-result and drop decisions;
- direct Map-write scratch allocation.

The current failure is function 1835, `SelfHostBodyNameMergeBuilder::resolve_and_merge_body`:

```text
type mismatch: values remaining on stack at end of block
at offset 0x4d704
```

The function starts the chained call:

```text
SelfHostBodyNameResolver::new(...).run()
```

with four receiver-constructor arguments already on the stack. Only the one-parameter physical call at function 1695 consumes a value, so four `eqref` values remain below all later loops. The next fix is to preserve the complete nested receiver expression instead of lowering only the final receiver fragment or selecting the wrong same-name callable.
