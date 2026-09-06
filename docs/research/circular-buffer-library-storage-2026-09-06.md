# Circular-buffer storage in Dew

## Representation and algorithms

`CircularBuffer<t>` is a declared struct with typed raw backing storage, head,
logical count, public capacity, and a growth flag. `CircularBufferIter<t>` has a
declared owner and cursor. Neither type aliases Array or uses its hidden layout.
All allocation, growth, indexing, push, pop, peek, clear, and iteration run in Dew.
Only raw Wasm array instructions cross the compiler builtin boundary.

The backing has one extra default-initialized slot beyond public capacity. No
push writes this slot. Pop copies it to the removed slot, which releases stored
references and products without allocating a new clearing object per pop. Unit
still occupies a logical slot and keeps all source effects.

Bounded capacity zero rejects pushes. Growable capacity zero grows to four;
later growth doubles with explicit integer overflow checks. Growth copies the
two live sections of a wrapped ring with two `array.copy` operations. Indexing
uses subtraction to avoid overflow in `head + offset`. Empty pops and peeks
return None. Clear keeps capacity and wrapper identity. Iteration follows the
owner's current logical order and traps when exhausted.

Queue and Deque now use these functions through normal calls. The old generic
scratch-local failure exposed by their migration is gone in native execution.
No specialized runtime adapter selects their operations or physical fields.

## Compiler cleanup

Remove all remaining native `PlannedCircularBuffer*`, `PlannedQueue*`,
`PlannedDeque*`, and unused `PlannedStack*` nodes. Remove their scratch-local
planning, transfer edges, emission arms, and ring runtime builders. The remaining
legacy Array emitter accepts only literal operation 48. Every other legacy
operation reports the exact `UnsupportedExpression(body, -409)` diagnostic.

The direct compiler regression now emits bounded and growable buffers without
an Array literal. This covers the former missing-wrapper-demand failure.
Map's Option construction helper and Array literal code remain for their own
data-type migrations; this commit does not claim to remove those paths.

## Tests

The 20-case shared native/self-host corpus covers bounded-zero rejection, wrapped growth,
both ends, Unit effects on accepted and rejected pushes, products, reference
identity, cleared reference slots, Queue and Deque calls, iterator exhaustion,
capacity overflow, growth from zero, repeated growth, the reserved empty slot,
the normal Iter interface, F32, and F64.
Six stdlib execution tests also cover Queue and Deque order, aliases, and clear.

Results and timings are recorded below after the final runs. Checks above 30
seconds remain performance bugs and are not skipped.

| Check | Result | Seconds |
| --- | --- | ---: |
| Circular-buffer source policy | 2 passed | 0.040 |
| Full native | 922 passed | 141.577 |
| Full integration | 266 passed | 50.955 |
| Full stdlib and shared execution | 325 stdlib tests and shared corpora passed | 26.148 |
| Generated checks | passed | 18.075 |
| Full self-host hardening | 225 tests, 29 invariant records, and shared corpora passed | 55.646 |
| Clean A/B/C bootstrap | identical B/C output | 186.036 |

B/C linked SHA-256:
`c812e0ab713355fd79aff47bffdab2361e408cfe1b69897dc154cea3f0108854`.

The isolated self-host ring compilation and execution takes 0.874 seconds.
The fixture request now includes all three migrated library modules and the
source explicitly opens Option. Missing imports remain diagnostics; they are
not converted to successful or skipped tests.
