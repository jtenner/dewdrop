# Wave 1 item 03: text split and lines

Base: `4a35c1d75d434056c5efee34aec4ea4e9d171e29`.
Test checkpoint: six new tests; not run at this checkpoint. The API is absent.

Contract: `StringView.split(delimiter)` returns a lazy `Iter<StringView>`.
Matches do not overlap. Leading, repeated and trailing delimiters yield empty
fields. Empty source yields one empty field. Empty delimiter yields the source
once (also for empty source). `lines()` splits on LF and removes a CR only
immediately before that LF. Lone CR stays. Final LF yields a final empty line.
Both return views of the source; `compact()` makes an explicit independent copy.
Exhausted iterators keep returning None. Iterator aliases share progress.

Plan: KMP prefix table, O(delimiter bytes) state, no source scan on construction,
one source byte read per scan step, at most twice as many search comparisons as
source bytes. Source scan and comparison counters give test evidence.
No compiler changes, new builtins, module slots, or B-tree edits are needed.

## Baseline and first attempt

Owner G0 is PASS WITH KNOWN RED; SDK is `/data/home/.moon` (moon
0.1.20261023, core/moonc 0.10.17+d971670cd). The given baseline is 355 public
std tests, 41 separate private B-tree tests, 42 builtin traps and 4121 operation
probes. This item does not recount the eight provider tests. Mission A reviewed
the eight historical snapshots at the dependency checkpoint; none are changed.
The accepted 67.88 s cold baseline is outside this item.

`flock /data/workspace/wave1-control/build.lock bash .tmp/gate.sh` attempt 1:
focused compile exited 1 in **218.95 s**, peak RSS **4,171,532 KiB**.
This is a visible >30 s performance bug. The initial local Clang wrapper put
`-g0` before Moon's `-g`, so debug data stayed enabled. Later runs put
`-fbracket-depth=4096 -g0 -O0` last and set process-local `MOON_CC`.
The SDK is unchanged. Compiler diagnostics rejected numeric range loop syntax
at `std/tests/text_split_test.dew:16`, `:85`, and `std/text.dew:392`, with
follow-on unknown helper errors. No tests ran (0 passed, 0 runtime failures;
compile gate failed). All numeric ranges are now supported functional loops.
The full first log is `data/stdlib-wave1-03/attempt-1.log.gz`.

Attempt 2 used the corrected flags: compile exited 1 in **28.33 s**, peak
RSS **1,080,348 KiB**. It found one more syntax error: the prefix fallback used
a Boolean `while` body at `std/text.dew:396`; Dew requires pattern arms.
That loop now uses pattern arms too. Again no tests ran. Full diagnostics:
`data/stdlib-wave1-03/attempt-2.log.gz`. No gate failure is suppressed.

## Implementation checkpoint

The API and generated mirror are now present. Eight focused tests cover the
contract above, late prefix fallback, a multiscalar delimiter, alias progress,
and a scan bound. `iter()` returns the same iterator for ordinary `for` loops.
The implementation uses existing StringView, FixedArray and Iter rules only.
Each `next()` moves forward or ends; prefix fallback strictly reduces the
matched width. A matched delimiter is consumed in full, so matches do not overlap.
Counters are stored once per returned field. `source_scans()` counts forward
search bytes, excluding the CR check in lines and delimiter table setup.

Production consumer and six production benchmark cases are in
`data/stdlib-wave1-03/`. They use no test module or host imports. The benchmark
checks exact total field bytes against a simple prefix/dense input oracle.
The third gate is queued; this checkpoint is not a passing handoff.
