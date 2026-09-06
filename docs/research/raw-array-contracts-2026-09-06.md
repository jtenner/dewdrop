# Declaration-based raw array contracts

Status: complete for raw array contracts. Array library algorithms have not yet
moved to these primitives.

## Contract

Both compilers derive the raw array owner from the selected builtin's resolved
signature. The owner must be an empty generic struct with one element argument.
Arity, receiver absence, U32 indices/lengths, element identity, and Unit results
are checked. Raw storage cannot be allocated with an ordinary struct constructor.
The spelling and position of the Dew declaration are not representation evidence.

The supported instructions are `array.new`, `array.len`, `array.get`, `array.set`,
`array.new_default`, and `array.copy`. The four older underscore opcode spellings
remain aliases for their Wasm instructions. `array.new_default` creates storage,
not a proved initialized logical T; callers must initialize reference/product
slots before reading them as T. `array.copy` keeps Wasm overlap and bounds rules.

The native compiler binds contracts after loading logical interfaces. It rebuilds
the metadata from current signatures on cache hits as well as cold builds. The
version-1 interface codec remains unchanged. Selected-body copies retain the
metadata. Physical layout planning omits raw owners from nominal struct tables.
The self-host compiler retains the same owner set across specialization runs.

`array.len` casts to Wasm's abstract array reference. It does not need to guess an
element carrier. Other raw operations specialize their actual element type, not
the first type parameter of the enclosing function. Products use existing box
and unbox adapters; scalars keep typed backing storage. Unit reads and copies
still perform bounds checks.

## Defects exposed by the tests

- Native user-defined raw intrinsics previously remained generic calls that had
  no physical function. Their stdlib counterparts were recognized by ordinals.
- The self-host compiler lacked `array.new_default` and `array.copy` emission.
- Native local assignment assumed every call had a precise nominal result.
  Generic reference results can have an eqref ABI. Such results now use the
  declared local's checked nominal cast.
- Remaining self-host constructor and unresolved-call paths used FixedArray or
  wasm_array_* source names. Those raw-array shortcuts have been removed.
- Self-host argument recovery could leave raw allocation and writes generic.
  These instructions now use the value's exact type and specialization. Unknown,
  erroneous, and Never storage shapes are rejected, including nested products.

## Checks

- Native routine lane: 919 tests pass, 114.979 seconds. The final nested-storage
  check also passes its targeted lane, 25.527 seconds.
- Native raw-contract tests: four pass. These check renamed/reordered owners,
  invalid signatures, invalid owner fields, and rejected struct allocation.
- Native integration lane: 266 tests pass, 45.226 seconds.
- Standard library: 319 tests and all shared probes pass, 23.307 seconds.
  The raw-array corpus has 14 cases, including generic reference/product values,
  packed storage, Unit evaluation order, overlap, and exact bounds traps.
- Self-host hardening: 223 tests, 29 invariant records, and all shared probes
  pass, 47.343 seconds. The same 14 raw-array cases run on this compiler.
- Generated checks pass, 15.064 seconds.
- FFI consumer generation: 3.902 seconds. Four existing provider exports added
  to the consumer: allocation, copy, ref.cast, and the abstract array heap type.
  No Starshine provider source change was needed.
- Clean bootstrap passes, 158.700 seconds. Compiler B and C raw/linked output
  share SHA-256 `60f2ebfde00ba473c55e2a47dee627adc0cb08f493b5f84c900983438c6faca1`.

Native, integration, hardening, and bootstrap lanes still exceed 30 seconds and
remain performance bugs. Full stress and pinned Starshine lanes remain scheduled
for the end of the broader migration. Next is the ordinary Array library; see
[the storage design](array-library-storage-design-2026-09-06.md).
