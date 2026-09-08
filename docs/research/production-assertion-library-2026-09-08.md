# Production assertions in Dew

Test assertions now use an ordinary Dew function with explicit output. The
production preamble still declares dew_assert, whose emitter expands to a drop,
comparison, conditional, and trap. It is not a one-to-one Wasm intrinsic.

Replace that declaration with ordinary Dew control flow and retain the public
assert function. Preserve production's existing zero-I/O behavior; visible test
messages are handled by the module-local test assertion function. Remove the
native expansion, generated self-host expansion, and wasm_assert intrinsic alias.
The unreachable builtin remains the one-to-one Wasm instruction.

The prepared shared fixture explicitly imports the preamble assertion, so the
test harness's private assertion cannot substitute for it. A host effect probe
checks condition/message evaluation exactly once and in order, with no later
effect after failure and no host I/O call. Compile and instantiate before
checking the intentional unreachable trap.

The source policy red run reports five findings in 0.034 seconds. Both emitters
and generators now omit the old operation. The public function uses ordinary
Dew if/unreachable control flow; message evaluation still occurs before entry.
The source policy passes in 0.040 seconds. The shared fixture and two native
body/unsupported-operation checks are wired into the normal lanes.

The fixture's first foreign declaration syntax is corrected after a 0.158-second
diagnostic run. The valid baseline compiles in 0.162 seconds. The native test
harness retains a separate fd_write import even though the production assertion
never calls it. The shared probe therefore rejects every unexpected import and
throws on any use of that write function; it does not mistake an unused test
transport import for runtime assertion output. Both baseline execution paths
pass in 0.025 seconds. A brief follow-up fixture change to unqualified foreign
calls is rejected and reverted; the fixture uses its declared namespace.

Preamble, self-host opcode, intrinsic module, and registry regeneration take
0.036, 0.035, 0.058, and 0.038 seconds. Review catches and restores the unrelated
alias loop before compiler tests run; only the assertion expansion is removed.
The full provider lane has passed. Four focused native assertion tests pass in
11.808 seconds; the migrated shared fixture compiles in 11.253 seconds and its
two execution checks pass in 0.024 seconds.

The first self-host assertion probe stops at its import check: the existing
linker retains unused WASI imports (starting with args_get). This fixture now
checks the relevant contract directly: the explicit effect function has exact
identity, all other namespaces are rejected, and every WASI stub throws if
called. No ignored host call or compile failure can count as a passing trap.
The remaining forced-import linker rule is still part of the open linker audit.
Final checks pass: 1,067 native tests in 162.341 seconds, 268 integration tests
in 63.458 seconds, 326 library tests and all shared execution corpora in 34.291
seconds, generated checks in 20.343 seconds, and 15 stress tests in 0.361 seconds.
The self-host unit tests (365) and exact failure records (108) pass in the
159.689-second initial hardening run; its new import assertion fails as described
above. After correcting that probe, the complete emission corpus passes in
36.498 seconds, including both production assertion paths (1.507 seconds).

Clean bootstrap passes in 188.412 seconds. B/C raw and linked SHA-256 match:
`479bdd696f5a4473d7a2341e7a8ac4e40bf2d8156a66232bab09fc039c89401b`.
The unchanged pinned provider passed all 10,991 tests in 303.270 seconds in the
preceding transport run. No speed work is included.
