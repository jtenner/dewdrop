# Remove self-host text runtime dispatch

The self-host compiler no longer classifies `dew_string_*` or `dew_bytes_*`
names as runtime functions. Inline instructions do not receive physical
function slots. Function-value uses take the ordinary outlined-instruction
path. A stray inline instruction in a physical function slot produces an
explicit emission error; it is never sent to a provider runtime builder.

Removed the runtime name lookup, name builder, two carrier-guessing helpers,
their now-unused value-type helper, and runtime append bridge. This removes
three selected FFI calls and the RuntimeFunctionBuilder carrier assertion.
The regenerated consumer selects 473 APIs instead of 476. The pinned provider
is unchanged; its retired rejection API and native runtime function kind are
separate remaining cleanup work at this checkpoint. The subsequent
[protocol retirement](runtime-protocol-retirement-2026-09-09.md) removes them.

Five physical-planning fixtures still declared removed text builtins. They
now declare explicit foreign signatures. Their Dew helper bodies and body
counts remain unchanged. The imported fixture uses an explicit public member;
these are planning tests, not replacements for the shared library execution
tests.

The new regression starts from source and checks that a removed text builtin
cannot enter the linked physical function table. Baseline hardening reports
874 passes and one expected failure in 94.930 seconds, while still running
the other checks. Consumer regeneration takes 4.008 seconds. The four policy
tests pass in 0.049 seconds. Post-change hardening passes all 875 tests, 457
exact invariant records, and all shared execution probes in 94.204 seconds.
Generated checks pass in 5.324 seconds. Clean bootstrap passes core, raw, and
final B/C comparisons in 182.014 seconds. Both final compiler hashes are
`5940d074ae4d8f250bc3e9396a565c1c8be2d39e0b6d7586ac261f8b05b6d74e`.

All compiler activities over 30 seconds remain timing defects. Speed work is
deferred. Array/Map identity recovery and their physical storage plans are not
changed here.
