# Constructor evaluation order and erased values

## Source defects

The native emitter built constructor arguments by walking physical fields.
An erased Unit payload had no field, so its expression did not run. In the
new Dew iterator implementation, `Some(array_iter_next(iterator))` returned
Some without advancing a Unit iterator. Named fields could also execute in
declaration order rather than source order.

The self-host object emitter had the same ordering problem. Its explicit
Unit marker branch also skipped the source expression. Its carrier verifier
did not distinguish that marker adapter from an invalid Unit-to-reference
operand conversion.

## Changes

- Native structs and enum payloads share one constructor recipe. It keeps
  source evaluations separate from physical field sources. Each source runs
  once into a typed temporary; physical fields then load those values in
  layout order. Erased expressions still execute. Product payloads are boxed
  at the storage boundary.
- Self-host object construction uses source-ordered temporaries, including
  explicit null markers for stored Unit values. Local counts and types use
  the same source field count and certified expression carriers.
- A Unit marker is permitted for an erased generic field only by that
  field's declaration metadata. Tuple variant markers require a matching
  variant/payload identity and a declared Unit or generic payload type.
  Missing, Error, and conflicting evidence do not authorize these adapters.
- Raw array iteration unpacks stored product values before exposing its
  logical multivalue result.
- The direct raw array read path now checks the builtin target instead of
  source spelling. An ordinary function named `array_get` is not a raw read.

## Regression coverage

`tools/dew-test/constructor_evaluations.dew` is shared by native and self-host
execution. It checks an erased enum payload, Unit between scalar tuple
payloads, generic Unit object fields, and reversed named-field source order.
Every case checks effects as well as returned values.

Validation with the accompanying checked-array library migration:

- Native: 794 tests passed in 45.305 s; backend tests took 23.163 s.
- Complete native integration: 266 tests passed in 44.444 s.
- Library runtime: 319 tests, all existing scalar/SIMD/product/callback
  matrices, four constructor checks, and 17 array checks passed in 5.279 s.
- Self-host: 161 hardening tests and 27 numeric invariant records passed.
  The four constructor and 17 array execution checks passed with all other
  emission probes in 5.934 s.
- Generated checks passed in 16.171 s.
- Clean A/B/C bootstrap passed in 174.554 s. B and C, raw and linked, have
  SHA-256 `397d8dccf306cc5318521f73a97b9dff617002fd109390b983317a9208c50b4f`.

Native aggregate tests, integration, cold release test generation, and the
bootstrap still exceed 30 seconds. Compiler A build took 31.265 s. These
remain measured performance bugs, not correctness exceptions.

## Remaining work

This is not the full library migration. Legacy runtime builders, other
source-name paths, complete physical heap/nullability proofs, and the rest
of the worklist remain open. Constructor scratch allocation also remains
separate from the planned source-local table; its full freeze certificate
must be unified with the remaining scratch plans.
