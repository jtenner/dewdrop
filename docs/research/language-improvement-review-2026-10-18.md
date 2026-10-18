# Dew language improvement review

Date: 2026-10-18. Source commit: `9d86b829292b1efa8f1aca32b0ff49565c878ee0`.

Five GPT agents reviewed semantics, runtime libraries, compiler speed, the
backend, and language use. The lead checked their strongest findings against
source and repeated the main probes. Claude Code received a separate read-only
review of parser, tokenizer, compiler-driver, and cache inputs. Its status and
coverage are recorded below.

This is a discovery report. No compiler, library, or test code was changed.
The project plan still puts self-hosting first. The items below are small fixes
or bounded next steps; they do not replace that plan.

## Best next work

| Order | Change | Evidence | First work unit |
| --- | --- | --- | --- |
| 1 | Keep selected operator behavior during constant folding | Wrong result and lost trap in emitted Wasm | Check the selected callable before folding |
| 2 | Check generic and trait match coverage | Accepted program traps on an uncovered input | Treat valid unknown value domains as open |
| 3 | Keep parse-cache writer and reader limits equal | Valid long expression passes once, then fails | Admit only entries the reader can accept |
| 4 | Read host input only on request | Empty program waits for stdin EOF | Replace eager preload with bounded reads |
| 5 | Protect checked JSON values | Public constructors can produce invalid JSON | Add module-only fields/construction, or recheck writes |
| 6 | Keep raw JSON document limits | Depth 129 passes validation, then fails materialization | Store and reuse limits |
| 7 | Use current compiler indexes | Current source still has repeated full scans | Replace dense function-index scans first; measure |
| 8 | Add small Option/Result helpers | Package parsing repeats nested forwarding matches | Ordinary Dew `map`, `map_err`, `and_then`, lazy defaults |

Orders 1–6 are confirmed behavior faults. Order 5 also exposes a useful language
feature. Order 7 is a speed hypothesis with source evidence and an old profile;
there is no new before/after speed result. Order 8 is a library feature.

## 1. Constant folding skips custom operators

Source: [program_optimization.mbt](../../src/semantic/program_optimization.mbt#L2362).
`PlannedOperatorCall` contains the selected declaration. The fold drops that
identity and uses only the operator and constant scalar values.

The probe defines a local `Add` trait and an I32 implementation that returns
`77`. Constant `1 + 2` returns `3`. A call with variable inputs `1` and `2`
returns `77`. A second probe makes the selected method trap. The constant call
still returns `3`; the variable call traps. Both probes build valid Wasm.

Require proof of the selected callable's intrinsic behavior before folding.
Do not infer this from a module path, declaration ordinal, or source name.
Keep ordinary Boolean expression folding where the semantics are fixed.
Tests must cover custom results, effects and traps, plus retained folding for
the standard intrinsic-backed methods. Check the self-hosted compiler too.

Builds took 0.151 s and 0.162 s. These are single probe times, not speed tests.

## 2. Generic matches bypass coverage checks

Source: [body_flow.mbt](../../src/semantic/body_flow.mbt#L559) and its early
return in `analyze_coverage` at line 741. Generic and trait types share the error
coverage domain. That domain suppresses coverage checks.

```dew
fn bad<t>(value: t) -> I32 {
  match value {
    _ if false => 42
  }
}
pub fn main() -> I32 {
  bad(7)
}
```

The check passes, the build passes, and `main` traps with `unreachable`.
The Boolean control reports `NonExhaustiveMatch`. An unguarded generic wildcard
returns `42`. Empty generic matches and an empty generic functional loop also
pass checks.

Use `OpenCoverageDomain` for valid generic and trait values. Keep suppression
for actual error types. Recheck deferred projections after they resolve; do
not assume that every pending type is valid or invalid. Add negative generic,
trait, guarded-only, and loop tests with positive wildcard controls in both
compilers. This does not need the larger nested pattern feature.

Check/build/runtime times for the guarded probe: 0.195/0.155/0.029 s.

## 3. A valid parse cache entry cannot be read back

Source: [parse_event_artifact.mbt](../../src/parser/parse_event_artifact.mbt#L7).
The reader rejects syntax deeper than 2048 nodes. The writer has no matching
admission check. The expression parser can build a long left-nested arithmetic
chain without that reader limit.

Claude found this mismatch by inspection. The lead confirmed it with a function
that adds 2055 `1` terms. With parse caching on and whole-program caching off,
the first check passes in 0.229 s. The second exits 2 in 0.010 s with
`corrupt parse-event cache pack entry` and `syntax nesting exceeds limit`.

A second control leaves cache flags at their defaults and adds a valid small
file. It passes once in 0.223 s, fails on the second check in 0.007 s, and still
fails after changing the other file. These commands use `--bootstrap-std` and
an isolated working directory. An exact whole-program hit, where available,
could mask the parse-cache defect; it does not fix the stored entry.

Make serialization admission obey the reader's depth rules. An unsupported
fresh tree must stay usable without storing an unreadable entry. Preserve
visible errors for actual corrupt stored bytes. A later iterative reader could
extend the accepted depth, but raising the limit alone leaves the mismatch.
Add cold/warm and edited-file tests at, below, and above the limit. Keep the
source-size limit and tree-depth limit distinct.

The first two-file probe had an invalid one-line control function and could
not test cache reuse. It was corrected before the result above was accepted.

## 4. The reference run host waits for all input

Source: [dew-run.mjs](../../tools/dew-run.mjs#L11).
`new Uint8Array(readFileSync(0))` runs before Wasm compilation. It waits for EOF,
retains the full stream, and copies the input buffer.

A 33-byte Wasm module with an empty `main` stays blocked with stdin open.
The agent stopped it after 1.004 s. With EOF it exits in 0.032 s.
The lead repeated the test: blocked after 0.504 s; EOF exited in 0.029 s.

Read into the requested guest iovec only when `fd_read` runs. Keep short reads,
EOF, zero-length reads, and errors visible. Do not wait to fill all iovecs.
Test a program that never reads, a write before a read, one input chunk without
EOF, repeated reads, multiple iovecs, and exact bytes. Compare peak memory for
small and large piped input before claiming a memory gain.

## 5. Public fields cannot protect checked values

Source: [json.dew](../../std/json.dew#L26), `json_write_validated_string` at line
1550, and `JsonValue::ValidatedNumber` output at line 1590. The
[specification](../spec.md#struct-declarations) says that fields have no separate
visibility rules.

Ordinary imported user code can construct `JsonNumber::{lexeme: "BAD"}`.
`json_stringify` then returns `Ok("BAD")`. It can also construct
`JsonString::{value: "a\"b", needs_escape: false}`. The writer returns success,
but `json_validate` rejects its output. No unsafe cast is needed.

A general module-only construction and field rule would protect these values
while keeping the validate-once output path. It would also help other library
types with internal state. Define public type access, field reads, field
writes, construction, patterns, and compile-time field queries together.
Cover frozen interfaces, caches, imported use, and both compilers. Do not add a
JSON-specific compiler rule.

A smaller library fix can recheck these values at output. That adds repeated
work and needs a fresh runtime comparison. Public low-level writer helpers and
state types also need a visibility review before the API can claim a protected
boundary.

## 6. Raw JSON documents drop custom limits

Source: [json.dew](../../std/json.dew#L52), raw document construction at line
1384, and `materialize` at line 1409.

The probe validates 129 nested arrays with `max_depth = 130`. The raw document
stores only source text. `materialize()` then uses the default limit of 128 and
returns `DepthLimitExceeded(129)`.

Store the supplied `JsonLimits` and use `json_parse_retained_with_limits`.
This adds a retained field and keeps the existing limits object alive. It does
not require a new limits allocation. Test custom depth, input and value limits,
plus default behavior. The depth failure is confirmed; the other limits were
not separately exercised.

The combined JSON/map probe built in 0.372 s, with 53,956 KiB peak child RSS and
59,506 bytes of Wasm. These are single-run observations, not memory or speed
comparisons.

## 7. Replace searches with current compiler indexes

Start with [semantic_wasm_body_plan.dew](../../self_host/compiler/semantic_wasm_body_plan.dew#L954).
Result-carrier and result-owner queries each scan `link.functions`. Related
parameter and declaration queries do the same. The link constructor assigns
`function_index = functions.length()` when it appends a function.
The code at `starshine_module.dew:6884` already uses a checked direct slot read.

Use the same bounds and identity checks. Do not confuse logical indexes with
physical indexes, which include an offset. For C calls and F functions, these
queries can fall from O(C × F) work to O(C), with no new index storage.

Two later small slices are available:

- `starshine_module.dew:14962`: reuse the declaration-owner and callable indexes
  for declared result shapes.
- `starshine_module.dew:4999`: use the dense linked-type slot for field metadata.
  Reuse checked ordinary-field lookup where valid. Keep enum payload and
  synthetic-field rules separate.

The saved [September profile](data/self-host-performance-followup-2026-09-14/profile-after.json)
attributes about 419 ms, 267 ms, and 633 ms of sampled self time to these paths.
These are old samples, not new gains. Do not add them to predict a speedup.

Before keeping a change, compare old/new query results for imports, generic
specializations, lambdas, missing indexes and exact identity failures. Measure
call-heavy fixtures at several sizes, record raw times and memory, and require
the A/B/C bootstrap fixed point and identical Wasm output.

Claude also found avoidable copies in cache hashing. At
`src/cache_binary/artifact_pack_lazy.mbt:10`, footer verification copies the
covered pack bytes before hashing. `artifact_pack.mbt:602` has the same pattern.
A checked BLAKE3 range API can remove this temporary full-range copy. Its
internal block/chunk functions already take source offsets. This does not
remove all BLAKE3 scratch allocations or prove lower peak RSS. A separate entry
decode/view change would be needed to remove payload copies. Test digest parity
at block/chunk boundaries and nonzero offsets, bounds errors, corrupt footers,
and cache publication. Measure time, allocation volume, and peak memory before
keeping the change.

## 8. Small value APIs before more syntax

[option.dew](../../std/option.dew) and [result.dew](../../std/result.dew) lack
ordinary mapping, chaining, and lazy-default helpers. The nested forwarding
matches in `std/package.dew:513–532` show a current use case.

Start with `Option.map`, `Option.unwrap_or_else`, `Result.map`,
`Result.map_err`, and `Result.and_then` as ordinary Dew functions or methods.
Method generics already exist. No new builtin or error-propagation syntax is
needed. Test skipped callbacks, one callback call, order, captures, imported
generics, and scalar/reference changes. Compare hot loops with direct matches
before replacing library code widely.

Other bounded candidates are checked U32/I32/U64 conversions and strict decimal
U32/I32 parsing from StringView. Keep current `Into` rules and exact JSON number
text. These are features, not confirmed overflow bugs.

## Lower-priority findings and limits

- Full nested pattern coverage remains a known feature limit, Q-114. A complete
  `Wrap(Zero)` / `Wrap(One)` match is rejected. The probe confirms the limit;
  it does not show a new regression.
- A saved Map entry changes from 10 to 20 after replacement of its key. It is
  the live chain node. An old collection note discusses immutable entry
  snapshots, but it also describes older trapping iterator behavior. This is
  an API/documentation decision, not a proven violation of a current immutable
  entry promise. Do not add one allocation per yielded entry without a measured
  need. Private internal nodes are a separate useful visibility boundary.
- No new cross-engine runtime benchmark, allocation profile, full suite, or
  self-host bootstrap was run. Only small probes and a no-work compiler build
  were needed for this source review.

## Evidence and build identity

The release CLI was current: `moon build --target native --release -j 8
src/dew_cli` reported no work in 0.029 s. Its SHA-256 is
`d5e3276407243876a914280f0defce9553dfe3cc920e5b5461c5ab0a5064f7bd`.
Runtime probes used Node v24.21.0 on this Linux host. Each compiler activity
recorded here was below 30 s.

Small inputs and raw records are in
[the evidence directory](data/language-improvement-review-2026-10-18).
The JSON records preserve the original exact commands and temporary paths.
To rerun, replace the source/output paths with this directory and a writable
temporary directory. Call exported functions with Node's WebAssembly API;
call `__dew_init` first when present. No Wasm binaries are stored in the review.
The stdin record includes the complete 33-byte fixture as hex.

Full agent notes, stdout, stderr, generated Wasm and the Claude review packet
remain outside production source at `/tmp/dewdrop-review-2026-10-18/`.

## Claude Code review status

Claude Code Opus completed with normal authentication, read-only tools, exit 0,
and no stderr. No denied reads or authentication faults were reported. The
lead read the assessment and independently checked its main source claims.
The cache-depth defect was reproduced. The cache-copy paths were confirmed by
source inspection; no memory or speed gain was measured.

Claude also predicted a parser stack crash from deeply nested arrays. The lead
tested 30,000 unmatched opening brackets in an isolated process, with core dumps
off and a 5 s timeout. It returned a normal parse diagnostic in 0.191 s. This
does not prove all nesting safe, but it does not confirm the predicted crash.
Do not list that prediction as a confirmed fault.

Its malformed-escape recovery finding and F32 double-rounding concern remain
unverified. The lexer does return early on a bad escape. The exact claimed
declaration recovery effect was not executed. These need focused tests before
a fix is selected. The cache-owner collision concern and unused file-descriptor
comment-read concern also remain unverified.

Coverage is partial. Claude read the cache codec and pack files, compiler driver,
tokenizer/lexer, recovery, and module stream. It read only parts of expression
parsing and parse-event serialization. It did not cover most other parser files
or most tests, and did not audit BLAKE3 algorithm correctness. It ran no tests or
benchmarks itself. Its full scope statement, review instructions, stdout, stderr,
and exit status are in `/tmp/dewdrop-review-2026-10-18/claude/`.
