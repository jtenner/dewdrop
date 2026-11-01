# Wave 1 item 10

Base: `4a35c1d75d434056c5efee34aec4ea4e9d171e29`.
Test checkpoint: two new tests specify bounded buffered byte records.
The API is absent at this checkpoint; tests are not yet run.

Contract: `buffered_reader_new(reader, chunk_limit, max_buffer)` owns one
unread chunk. `read_until(delimiter: Bytes, max_bytes)` returns
`Result<Option<Bytes>, IoError>` and retains the delimiter. `read_line`
uses LF and removes LF only (CR stays). Empty input returns None; an empty
line returns Some(empty). No UTF-8 decoding occurs. Bounds include the
retained delimiter. Errors consume the partial record; unread suffix stays.

## Implementation contract

The implemented delimiter is `Bytes`, with a nonempty delimiter required.
Prefix-table matching handles delimiters split across any read, and overlapping
prefixes. It takes O(input bytes + delimiter bytes) work per call.
`read_until` includes the delimiter; `read_line` uses `b"\n"` and strips LF.
It preserves CR and arbitrary non-UTF-8 bytes.

`max_bytes` counts returned bytes before LF removal. `max_buffer` bounds the
sum of the partial record and unread payload. Reads request no more than
`min(chunk_limit, max_buffer - partial_length)`. A full buffer with no
complete delimiter returns LimitExceeded, even if the next backend read
would have been EOF. Leave spare room for an EOF probe when accepting an
unterminated record of exactly the line bound. Zero chunk or empty delimiter
returns ZeroProgress; zero bounds or a delimiter larger than a bound returns
LimitExceeded. All bound checks precede consumption for that check.

Errors discard the partial record already consumed. The unread suffix remains
available to the next operation. Backend errors pass through unchanged.
Oversized backend results return InvalidProgress. An empty result caches EOF;
no further backend call follows EOF. Reader::read(0) returns empty without I/O.
Raw Reader calls drain buffered bytes before new reads and can be mixed with
record calls. Aliases share state, as with BytesInput. Calls must be sequential.

The bound is a logical payload bound, not a bound on the source Reader's
storage or on the host allocator. The wrapper retains at most one chunk;
fully consumed chunks are released. Bytes views can retain a Reader's larger
backing store. Prefix storage is 4 * delimiter_length bytes. The existing
BytesBuilder doubles capacity (initial 64 bytes) and finish shares storage.
Thus record backing capacity is < 2 * max(64, record_length), plus a chunk
and O(delimiter_length) prefix storage. Relocations copy a geometric series
of less than twice the final capacity. `copied_bytes` counts payload writes;
`read_count` counts backend calls. Both are U32 counters with wrapping totals.
No runtime builtin, compiler dispatch, module slot, or B-tree file is added.

## Gates and evidence

Test checkpoint: `0b67c185`. The final candidate has **14 new tests**.
All **23 focused IO tests pass, 0 fail** (14 new + 9 existing). This does not
repeat or count any B-tree provider test. No full standard-suite count is
claimed here; the owner runs that gate at integration. The G0 baseline remains
355 public tests, 41 separate private tests, 42 traps, 4121 probes, with the
owner's known-red ruling and accepted 67.88-second cold build. No snapshot
was changed. No held fix was imported.

All build, compiler, test, and check commands ran inside one exclusive
`flock /data/workspace/wave1-control/build.lock` per attempt. The script's
EXIT trap removed `_build`, `.mooncakes`, `.dew/cache`, and temporary Wasm
files before it released the lock. The pinned `/data/home/.moon` SDK was
unchanged. No push occurred.

Reproduce from this worktree (the wrapper flags must come **after** `"$@"`):

```sh
mkdir -p .tmp/bin
cp docs/research/data/stdlib-wave1-10/{gate.sh,bench.mjs,consumer.dew} .tmp/
cat > .tmp/bin/clang <<'SH'
#!/bin/sh
exec /usr/bin/clang "$@" -fbracket-depth=4096 -g0 -O0
SH
chmod +x .tmp/bin/clang
ln -sf /usr/bin/ar .tmp/bin/llvm-ar
flock /data/workspace/wave1-control/build.lock bash .tmp/gate.sh > .tmp/gate.log 2>&1
```

`data/stdlib-wave1-10/gate.sh` holds the exact timed commands. It uses
`MOON_CC=$PWD/.tmp/bin/clang`, a process-local PATH with `/data/home/.moon/bin`,
and `-j 1`. The native runner uses `--no-parallelize` too. Saved full logs:
`gate1.log.gz`, `gate2.log.gz`, `gate3.log.gz` in that data directory.

| Final gate (attempt 3) | Seconds | Peak RSS, KiB | Result |
| --- | ---: | ---: | --- |
| `moon run --target native -j 1 src/dew_test_gen -- .tmp/focused.wasm dew.std dew.std std/tests/io_buffered_test.dew std/tests/io_buffered_test.dew dew.std std/tests/02_io_test.dew std/tests/02_io_test.dew` | 28.99 | 1080628 | compile passed |
| `node tools/dew-test/run.mjs --wasm .tmp/focused.wasm` | 0.03 | 51844 | 23 passed, 0 failed |
| `python3 tools/generate_io_std.py --check` | 0.02 | — | passed |
| `moon run --target native -j 1 src/module_snapshot_gen -- .tmp/consumer.wasm .tmp/consumer.dew` | 20.63 | 930552 | production compile passed |
| `env DEW_NATIVE_TEST_PACKAGES=standard_sources bash tools/test-native.sh -j 1` | 1.92 | 100036 | passed; package has 0 native tests |
| `node --expose-gc .tmp/bench.mjs` | 0.17 | 53800 | runtime and production checks passed |

The production consumer uses a normal imported IO module. Its Wasm has no
`dew.tests` section; `main` returns 0. There are no compiler/backend source
changes, no new module, and no new identity or interface registration. Thus
no new-module or compiler integration lane applies. The native package check
above is a compile check, not additional runtime test coverage.

### Failed attempts remain visible

1. Attempt 1: stopped the cold native build after **174.29 seconds**; exit 1,
   peak RSS **2727376 KiB**. This is a **performance bug** in that attempted
   build configuration. The wrapper placed `-g0 -O0` before SDK arguments,
   so later `-g -Og` flags replaced them. The corrected wrapper appends flags.
2. Attempt 2: **28.82 seconds**, exit 1, peak RSS **1079036 KiB**. Dew compilation
   emitted 69 diagnostics; no runtime test ran. The first was
   `std/tests/io_buffered_test.dew:14:34: NoMatchingMethod` at the generic
   associated constructor call, with later unresolved type diagnostics.
   The API now uses a free constructor, as existing generic collections do.
   No compiler rule was changed. The same tests pass in attempt 3.

No compiler activity in the final run exceeded 30 seconds.

### Runtime and memory

The scale tests build byte inputs, then read with 64-byte backend chunks and
an absent `b"xxxxxxxy"` delimiter. Repeated `x` prefixes exercise fallback in
the prefix matcher. The oracle checks the output length and final byte, exact
payload writes, backend calls, and empty unread state. The partition test
checks exact records at all chunk sizes 1 through 12, including overlapping
prefixes and retained suffixes. Other tests cover short reads, one-byte reads,
empty records, EOF caching, partial delimiter at EOF, raw Reader calls, zero
limits, line and total bounds, backend errors after partial progress, retries,
and oversized backend results.

| Input bytes | Payload writes | Backend calls | Mean fixture runtime, ms |
| ---: | ---: | ---: | ---: |
| 4096 | 4096 | 65 | 0.07894 |
| 32768 | 32768 | 513 | 0.49617 |

Each runtime mean covers 200 calls after 10 warmups, including input creation
and assertions. These are new APIs; no before/after speedup is claimed.
An 8x input increase took 6.29x time in this run. The counters and prefix
algorithm establish linear work independently of timing noise. For these
power-of-two outputs, builder growth copies 4032 and 32704 additional bytes,
respectively (the existing 64-byte initial capacity doubles). Finish copies
no bytes. Total output writes plus growth copies are 8128 and 65472, both
less than twice the input length. This relocation count follows the existing
builder code, rather than a new runtime counter.

The prefix table is 32 bytes for these fixtures. Final record backing arrays
are 4096 and 32768 bytes, plus one chunk and small state objects; the input
Reader's source is separate. Temporary old and new arrays can coexist during
growth. The benchmark's Node peak RSS was **53800 KiB**, including the VM and
compiled Wasm. After forced GC, heap use grew from 4120320 to 4219512 bytes
for 200 small calls and 4233768 to 4245360 for 200 large calls. Large-case RSS
was unchanged at 54829056 bytes before/after. These are process observations,
not exact per-reader allocation sizes. The byte bounds and geometric-growth
analysis above give the operation's storage bound.

Remaining blockers: **none**. Status: **READY candidate**, subject to owner
review and the combined full standard-suite gate.
