# Wave 1 item 01: wide decimal parsing

Base: `8c3b047fe633aa11c6634b929045376e9dfc7d6c`.
Test checkpoint: three new tests mirror the narrow parser contract for U64/I64.
They require APIs absent at this checkpoint (expected red; not yet run).
ASCII digits only; unsigned has no sign; signed permits only a leading minus.
Empty input is Empty; a lone minus is InvalidDigit(0). Negative zero is zero.
Overflow and invalid-digit offsets are bytes relative to the view, at the first
failing digit. No whitespace, plus, separator, exponent or fraction is accepted.
Implementation and measured gates follow in the next checkpoint.

## Implementation

`parse_u64_decimal` accepts 0 through 18446744073709551615.
`parse_i64_decimal` accepts -9223372036854775808 through 9223372036854775807.
For example, `parse_u64_decimal("!42?".view(1u32, 2u32))` is
`Result::Ok(42u64)`. The shared wide magnitude loop checks quotient and
remainder before multiply/add. Signed minimum has an explicit exact branch.
Existing narrow APIs and their code stay unchanged. No builtins, compiler
rules, new modules, identity slots or B-tree files change.

The byte access chain is `StringView.byte_at` (`std/string.dew`) ->
`string_view_byte_at` (`std/text_runtime.dew`) -> raw view cast and
`bytes_byte_at`. It reads the backing bytes; it never copies text. Working
state is a fixed set of scalar values, independent of input length; Result
and view wrappers are not claimed to have zero allocation.

## Gate record

All compiler commands run in one exclusive lock per attempt:
`flock /data/workspace/wave1-control/build.lock bash .tmp/gates.sh`.
The exact script is `docs/research/stdlib-wave1-01-gates.sh`; copy it to
`.tmp/gates.sh` after `mkdir -p .tmp` to repeat. The Node oracle and benchmark
scripts are adjacent. Logs are retained in `.tmp/gates-first.log` and
`.tmp/gates.log`; compact final results follow below.

First attempt: generator check PASS (0.02 s, 12164 KiB); focused compile FAIL
(73.96 s, 2429788 KiB peak RSS). Diagnostic at `std/text.dew:103:18`:
`ExpectedBlockEqual` on a typed local binding. Replaced it with an ordinary
U32-to-U64 conversion helper. No compiler change was needed. The other
seven diagnostics were consequences of that parse error. No tests ran in
this attempt. The 73.96 s cold compiler build is a visible performance bug
(over 30 s), not hidden by the accepted G0 cold-build exception.

Second attempt: generator check PASS (0.02 s, 12040 KiB); focused compile
PASS (74.42 s, 2430120 KiB); focused runtime PASS (0.12 s, 120912 KiB),
8 passed / 0 failed: three unchanged narrow tests, four new wide tests,
one generated oracle test with 528 assertions over 264 Node BigInt samples.
Production compile FAIL (67.72 s, 2578892 KiB): the generated consumer used
single-line function bodies; Dew requires a newline before `match`.
Corrected the fixture generator to emit normal multiline functions.
Both compile commands exceeded 30 s and remain visible performance bugs.
No library code changed after the focused pass. Full log: `.tmp/gates-second.log`.

## Final results

Final gate exit: **0**. Commands and measurements are retained in
`stdlib-wave1-01-results.txt`. All commands use the pinned SDK from G0 via
`PATH=/data/workspace/tools:/data/home/.moon/bin:/usr/local/bin:/usr/bin:/bin`.

| Gate | Seconds | Peak RSS KiB | Result |
| --- | ---: | ---: | --- |
| `python3 tools/generate_text_iteration_std.py --check` | 0.02 | 12060 | pass |
| `moon run --target native src/dew_test_gen -- .tmp/focused.wasm dew.std dew.std std/tests/decimal_parse_test.dew std/tests/decimal_parse_test.dew dew.std oracle_test.dew .tmp/oracle_test.dew` | 73.28 | 2430176 | pass |
| `node tools/dew-test/run.mjs --wasm .tmp/focused.wasm` | 0.10 | 120952 | 8 passed, 0 failed |
| `moon run --target native src/dew_cli -- build .tmp/consumer.dew -o .tmp/consumer.wasm` | 64.90 | 2578956 | pass, 7124 bytes |
| `wasm-tools print .tmp/consumer.wasm -o .tmp/consumer.wat` | 0.12 | 7780 | pass |

The two final compiler commands exceed 30 s: visible performance bugs.
No claim of a faster compiler or parser is made. Compiler source did not
change, so routine native/integration and full std gates remain the combined
landing owner's gates. This focused run does not recount the G0 public
provider tests, private B-tree tests, traps or operation probes.

New coverage: **4 permanent tests**, plus **1 generated oracle test**.
Final focused total: **8 passed / 0 failed** (3 existing + 5 new).
The oracle uses Node BigInt decimal text, a fixed 64-bit LCG seed, exact signed
and unsigned range checks, and a prefix scan for the first overflow byte.
It checks **264 bounded samples / 528 assertions**, each inside an offset view.
The generated oracle source stays out of the committed test manifest.

### Runtime and memory

`node --expose-gc docs/research/stdlib-wave1-01-bench.mjs` verifies the production
signed minimum and each benchmark result. Each row uses 10,000 warm calls,
then 100,000 measured calls; heap/RSS deltas are after explicit GC.

| Decimal digits | ms / 100,000 calls | Heap delta bytes | RSS delta bytes |
| ---: | ---: | ---: | ---: |
| 1 | 6.13638 | 96520 | 3411968 |
| 20 | 7.36529 | -32 | 393216 |
| 200 | 38.66219 | 12936 | 679936 |

The longer inputs use leading zeros and end in 7, so every digit is read.
These times include consumer input-literal construction, view/result wrappers,
Wasm boundary calls and Node assertions. They are not isolated parser timings.
RSS includes VM/GC effects; it does not prove per-call zero allocation.
Source inspection proves one forward byte scan and constant scalar state.

The unoptimized production WAT has 4 `array.new_fixed`, 0 `array.copy`,
19 `struct.new`, and 0 `memory.grow` instruction sites. All four array
allocations construct the original input literals in the exported consumer
functions (24–27); no parser or text helper allocates a backing array.
The magnitude loop is function 18; its successful path allocates one fixed
Result wrapper after the scan, not per digit. Thus the parser makes no
temporary text copy and needs no storage proportional to input length.
The adjacent benchmark script also asserts this WAT property.

The lock trap removes `_build`, `.mooncakes`, `.dew/cache`, generated Wasm and
harness outputs before lock release. Full warning/failure logs remain in
`.tmp`; compact results and repeatable source scripts are committed.
No B-tree, snapshot, global SDK, registry or identity edits. No push.
No unresolved item blocker. Status: READY for owner review, not landed.

Final WAT assertion replay: `flock /data/workspace/wave1-control/build.lock bash
.tmp/wat-proof.sh`, with `node docs/research/stdlib-wave1-01-bench.mjs --wat-only`
as its check command: PASS, 0.03 s, 45556 KiB, exit 0. This used the saved WAT
from the successful production build. Its cleanup trap also removed generated
consumer/oracle sources, WAT and the scratch benchmark harness. The main saved
gate script now runs these same assertions and removes those sources on exit.
Test/doc checkpoint: `d4d351f5`. Implementation checkpoint is the next commit.

## Combined landing gate

Integration tree includes item 02 at `1d970ba3` and this item's
`4cca698a`. Full `bash tools/dew-test/run.sh` exited 0 in 161.73 s:
365 public tests (355 baseline + 6 trim + 4 permanent wide-parse tests), 41 private tests,
builtin traps, and all 42 operation check scripts passed. Repeat bytes match.
The first public compile and private compile exceeded 30 s; the runner logs
both as performance issues. A process-local Clang wrapper uses -g0 -O0
with bracket-depth 4096, preserving the pinned Moon SDK.
The standard_sources native package lane exits 0 with zero tests, so no
coverage is claimed for it. Compiler loading rules are covered by the final
full native lanes. Full logs: `data/stdlib-wave1/landing-01-{std,native}.log.gz`.
Build output removed before releasing the lock.

Count note: the worker focused total of 8 includes 3 existing tests,
4 permanent new tests, and 1 temporary Node-oracle test with 528 checks.
That oracle test is regenerated by the saved script and is not part of the
full public manifest. Thus the combined permanent total is 365, not 366.
