# Selected signatures determine call results

The self-host emitter still had three obsolete method-name routes: exact
expression lookup preferred receiver-element guesses for `get_unchecked`,
the final result check skipped three name suffixes, and function signature
emission took a separate route for getter names and returned Array loads.
The latter route already read the same frozen fragment; it was unnecessary.

Three new policy checks fail on those old routes. The runtime probe with user
methods named `get_unchecked`, `indexed_get`, and `into` already passed before
removal (0.370 seconds); it is positive coverage, not a reproduced runtime
failure. The shared member corpus now also checks those names with result types
different from the receiver's generic argument and a visible `123` effect trace.

Exact direct and unresolved call-result reads now use the selected call
mapping and fragment signature. They do not use a container's first or second
generic parameter, a `length` name, or a same-named receiver method. A missing
selected result stays missing. Two obsolete direct-get recovery helpers are
deleted, including the caller-name exception for `self_host_array_pop` and
the unproved I32 default. Their emission consumers use the selected signature;
diagnostics read the actual declared result type.

Final result verification no longer exempts `get_unchecked`, `indexed_get`, or
`into`. Function result signature emission always reads the fragment's result
span. Source names remain available for diagnostic text, not ABI decisions.
This is not removal of every older unresolved-receiver or collection heuristic;
those remaining paths are still tracked in the main worklist.

Measured checks:

- Four policy tests pass, 0.036 seconds (the initial red run had three failures).
- The first, narrower hardening run passes in 147.337 seconds, including a
  release native rebuild. It is not the final wider source validation.
- Final hardening: 450 tests, 137 exact invariant records, all emission and
  semantic probes, 56.161 seconds. The expanded shared member corpus passes
  all 10 executions.
- Library: 326 tests and all shared execution corpora, 24.083 seconds.
- Clean bootstrap: 166.668 seconds. B/C core and linked Wasm bytes match:
  `4d0637233131b75d7a1277a9a3a3163efa9f5b5e8f82063c525509b718832ab3`.
- Generated checks: 3.972 seconds.

The native compiler implementation is unchanged from the preceding batch's
1,147 native and 268 integration passes. The provider and generated FFI remain
unchanged. Runs above 30 seconds remain speed bugs; no speed work is included.
