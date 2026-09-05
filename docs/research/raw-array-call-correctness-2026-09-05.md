# Raw array call evaluation order and identity

An emitted self-host execution test confirmed that `array_new(length, value)`
evaluated `value` before `length`. Wasm `array.new` consumes value then length, but
that stack order must not change Dew's source evaluation order. The native
`FinishStarshineFixedArray` path already stages both evaluated arguments in locals.

The self-host now evaluates length once, stores it in a call-specific i32 local,
evaluates value once, reloads length, and emits `array.new`. All scratch allocation
and slot accounting paths include the new local. Each expression gets its own
slot, so nested constructors cannot overwrite an outer length.

The four raw array operations now dispatch only on builtin target metadata.
The source-name fallbacks for `wasm_array_new`, `wasm_array_len`, `wasm_array_get`,
and `wasm_array_set` have been removed. This does not rename the current builtin
targets or claim that the remaining collection runtime has moved into Dew.

The minimal side-effect test writes 1 during length evaluation and adds 10 during
value evaluation. Before the fix, the emitted program returned 1; after the fix,
it returns 11. A nested-constructor probe separately checks that lengths 3 and 1
do not share storage and returns 307. A source-name collision probe binds all four
array spellings to integer addition and returns 15.

All 103 hardening tests, 16 invariant-record checks, and 21 emitted execution
probes pass. Generation took 2.697 s, linking 4.983 s, and execution probes 0.867 s.
Logs: `/tmp/dewdrop-raw-array-before.log` and `/tmp/dewdrop-raw-array-final.log`.

The final clean A/B/C bootstrap passes. B and C validate and are byte-identical,
with SHA-256
`bf43e8f1a8e24f1e249557dc70dc0100f4bca551fef3880fc092f89a7cd18b30`.
Log: `/tmp/dewdrop-raw-array-bootstrap.log`. The A build and both compiler
execution steps still exceed the 30-second limit; speed work remains deferred.
