# Native initializer source checks

The native physical linker silently skipped an initializer when its body index
was outside the source arena. It also used the selected body's root shape
without checking its stored body/declaration IDs, body kind, or concrete shape.

A checked entry point now validates the encoded module owners before decoding
the body-relative index. It checks arena bounds, both stored IDs, module-let
body kind, and concrete root shapes, including product leaves. It also checks
all lowered body arenas, root membership, and owned child edges before constant
classification reads the root expression. The linker uses the returned source
record and no longer skips missing initializer bodies.
Failures retain all nine numeric fields through `ProgramFunctionLookupFailure`.

Eleven source-derived tests cover valid scalar/Unit access and one-field or
one-lookup negative cases, including both index boundaries, root membership,
and negative span starts. The initial test lane required the new checked entry
point and failed to compile before its implementation (1.009 seconds). The
first fixed routine native lane passed 1,229 tests (204.629 seconds). The added
arena cases pass the focused lane (11 tests, 31.931 seconds). The final routine
native lane passes 1,233 tests (172.325 seconds). All 268 integration tests pass
(61.835 seconds), as do the library's 326 tests and shared corpora (36.275
seconds). Generated checks pass (18.065 seconds). Hardening passes 632 tests,
270 exact records, and all shared probes (160.466 seconds, including a cold C
test-generator build). The clean Node bootstrap passes (187.858 seconds).
Compiler B/C raw and linked hashes remain identical and unchanged from the
preceding Unit-global batch:
`c2e0ae580b0acdab98876581b6115d4873170909f261f96ce67df337cf603fe2`.

This check covers initializer candidates, not the separate walk
through called bodies used to find startup dependencies; that walk still has
unchecked/skipping paths. Complete native initializer schedule/global lookup
verification and full link freeze remain open. No speed work is included.
