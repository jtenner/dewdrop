# Wave 1 item 07: incremental SHA-256

Base: 8c3b047fe633aa11c6634b929045376e9dfc7d6c.
Test checkpoint: new stream test reuses all CAVS messages and checks every
split, empty updates, shared state aliases, repeated finalize, rejected
post-finalize updates, and independent returned digests. Not run yet;
sha256_new/update/finalize do not exist at this checkpoint.

Contract: new state is shared by aliases. Update returns false after finalize
or if total bytes would exceed 2^61-1; rejection makes no change. Finalize
closes the state, is repeatable, and returns a fresh FixedArray<U8> digest.
Empty updates succeed only while open. State retains no input Bytes.

## API and example

```dew
open dew.std.integrity.sha256
let state = sha256_new()
assert(sha256_update(state, first_chunk), "update failed")
assert(sha256_update(state, next_chunk), "update failed")
let digest = sha256_finalize(state)
```

The digest remains `FixedArray<U8>` with 32 bytes. The one-shot code is
unchanged. `Sha256State` has a 16-word block, eight hash words, a U64 byte
count, a U32 block offset, and a closed flag. Do not change these fields.
The block is also the circular schedule; no separate schedule is retained.
There is no allocation, host call, or input reference assignment in update
or compression. Finalize allocates one fresh digest per call.

Tests use all 65 CAVS messages (0–64 bytes), plus a 65-byte Node vector.
They run all 2,211 two-part splits and all 4,290 fixed-size chunk runs
(sizes 1–65). This includes 55, 56, 63, 64 and 65 bytes. Each split checks
empty updates, alias writes, repeat finalize, closed-state rejection, and
returned-digest mutation. Other tests check 1 MiB and 4 MiB against full
Node digests, the U32 count boundary, and the last legal U64 byte count.
The synthetic count tests check arithmetic without hashing exabytes.

## Reproduce

All commands run from `/data/workspace/wave1-item-07`.

```sh
mkdir -p .tmp
cp docs/research/data/stdlib-wave1-07/consumer.dew .tmp/consumer.dew
cp docs/research/data/stdlib-wave1-07/measure.mjs .tmp/measure.mjs
cp docs/research/data/stdlib-wave1-07/gate.sh .tmp/gate.sh
cp docs/research/data/stdlib-wave1-07/cc .tmp/cc
chmod +x .tmp/cc
ln -s /usr/bin/ar .tmp/ar
flock /data/workspace/wave1-control/build.lock bash .tmp/gate.sh > .tmp/gate-output.log 2>&1
```

The gate uses the pinned `/data/home/.moon` SDK. `MOON_CC` selects a local
Clang wrapper with `-g0 -O0 -fbracket-depth=4096`; each Moon command uses `-j 1`. These are process
settings. The SDK is unchanged. The gate times each command, retains logs,
and removes `_build`, `.mooncakes`, `.dew/cache`, and generated Wasm/WAT
and harness files in an EXIT trap before it releases the build lock.

The test compiler is `src/dew_test_gen`; the production compiler is
`src/dew_cli`. Both use ordinary on-disk standard module loading and the
existing compiler pipeline. The Node memory probe uses a production build,
warms each method once, collects garbage before each sample, and records
heap and RSS changes while hashing. It checks the first digest byte against
Node for each measurement; the long Dew tests check all 32 bytes. Heap
changes are observations, not exact allocation counts.

The initial attempt was stopped by the owner while waiting for the build
lock. It produced no compiler log or test result. The first test checkpoint
was not run and must not be counted as a measured failure.

## Gate results

Test checkpoint: `36c1cbc1`. Implementation checkpoint: the commit that adds
this result section. All files use the assigned branch and dependency base.
No B-tree, module registry, compiler rule, builtin, SDK, or snapshot changed.

The final command is the `flock ... bash .tmp/gate.sh` command above. It ran
the following commands inside one exclusive lock. All exits were zero:

| Command after `/usr/bin/time -p` | Seconds | Result |
| --- | ---: | --- |
| `python3 tools/generate_sha256_std.py --check` | 0.02 | mirror current |
| `moon run --target native -j 1 src/dew_test_gen -- .tmp/stream.wasm dew.std dew.std std/tests/sha256_stream_test.dew std/tests/sha256_stream_test.dew` | 28.35 | cold compiler build and stream compile pass |
| `node tools/dew-test/run.mjs --wasm .tmp/stream.wasm` | 0.11 | 4 passed, 0 failed, all 4 new |
| `moon run --target native -j 1 src/dew_test_gen -- .tmp/oneshot.wasm dew.std dew.std std/tests/08_sha256_test.dew std/tests/08_sha256_test.dew` | 0.88 | one-shot compile pass |
| `node tools/dew-test/run.mjs --wasm .tmp/oneshot.wasm` | 0.03 | 1 passed, 0 failed, existing CAVS test |
| `moon run --target native -j 1 src/dew_cli -- build .tmp/consumer.dew -o .tmp/consumer.wasm` | 16.53 | production compile pass; 11,682-byte module |
| `node --expose-gc .tmp/measure.mjs` | 0.68 | all 8 samples match Node's first digest byte |

Final focused count: **5 passed, 0 failed, 4 new**. The owner will run the
combined standard suite. The accepted owner baseline is 355 public tests,
41 separate private B-tree tests, 42 traps and 4,121 operation probes; this
worker does not add those counts to its focused result. No native compiler
source changed, so no native compiler or integration lane was needed here.

Two setup failures remain recorded, not counted as passing tests:

- Attempt 1: local C wrapper lacked a sibling archiver. Stream build exited
  255 in 0.09 s; one-shot and consumer builds exited 255 in 0.04 s each.
  Generator check passed in 0.02 s. Fixed with local `.tmp/ar` link.
- Attempt 2: Clang's default nesting limit of 256 rejected generated C
  mapped to `src/backend/starshine_v128_builtins.mbt:533:71`. Cold stream
  build exited 1 in 27.08 s; one-shot retry exited 1 in 1.72 s; consumer
  build exited 1 in 7.12 s. Generator check passed in 0.02 s. Fixed by
  `-fbracket-depth=4096` in the process-local wrapper.

No measured compiler command in this item exceeded 30 seconds. The owner's
accepted 67.88-second cold baseline remains outside this item. Compressed
logs for both failed attempts and the passing gate are in
`docs/research/data/stdlib-wave1-07/`. `results.json` records passing times
and the raw memory samples. Compiler deprecation warnings remain in logs.

## Runtime and memory

Each method hashes a reused 64-byte chunk. The stream method feeds it directly
to state. The existing one-shot method joins the chunks in a BytesBuilder,
then calls the unchanged `sha256`. This comparison includes the join cost.
It is not a claim about the speed of one-shot hashing of an existing Bytes.

| Bytes | Stream ms | Stream heap growth (bytes) | Join + one-shot ms | Join + one-shot heap growth (bytes) |
| ---: | ---: | ---: | ---: | ---: |
| 65,536 | 1.55 | 221,064 | 0.89 | 67,088 |
| 1,048,576 | 13.87 | 149,664 | 14.60 | 1,049,800 |
| 4,194,304 | 55.11 | 596,560 | 56.50 | 4,195,336 |
| 16,777,216 | 202.65 | 808 | 225.17 | 16,778,248 |

The stream samples show no retained-memory growth with input size. Early
samples include engine compilation and heap noise. RSS deltas, including
negative values after garbage collection, are retained in `results.json`.
The exact source storage bound is 96 bytes of array elements plus the fixed
state fields and object headers. Update and compression create no arrays,
structs, closures, or Bytes views; input size does not change that bound.
Finalize creates one 32-byte array per call. The ordinary Dew algorithm uses
no runtime builtin, new host call, or module-path/source-name dispatch.

The two long tests use Node SHA-256 digests of 1,048,576 and 4,194,304 `a`
bytes. To regenerate those expected strings, use Node's
`crypto.createHash('sha256').update('a'.repeat(size)).digest('hex')`.

Status: **READY candidate**, not landed. No remaining blocker. The build
trap removed `_build`, `.mooncakes`, `.dew/cache` and generated Wasm files
before lock release. No push occurred.

## Changed files

- `std/integrity/sha256.dew`
- `std/tests/sha256_stream_test.dew`
- `src/standard_sources/standard_sha256_sources.mbt`
- `std/README.md`
- `docs/research/stdlib-wave1-07.md`
- `docs/research/data/stdlib-wave1-07/cc`
- `docs/research/data/stdlib-wave1-07/consumer.dew`
- `docs/research/data/stdlib-wave1-07/gate.sh`
- `docs/research/data/stdlib-wave1-07/measure.mjs`
- `docs/research/data/stdlib-wave1-07/results.json`
- `docs/research/data/stdlib-wave1-07/gate-attempt1.log.gz`
- `docs/research/data/stdlib-wave1-07/gate-attempt2.log.gz`
- `docs/research/data/stdlib-wave1-07/gate-pass.log.gz`

## Combined test-module correction

The first combined standard compile exited 1 in 27.80 s: six copied
stream-test helpers had the same names as helpers in the original one-shot
file. `DuplicateName` diagnostics start at `std/tests/sha256_stream_test.dew:8`
and point to `std/tests/08_sha256_test.dew:8`. The stream-test helpers now
have a `sha256_stream_` prefix. Corpus bytes, assertions, and library code
are unchanged. No runtime tests ran in that failed attempt. Native loader
tests passed 31/31 in 13.45 s. Failed logs are preserved at
`data/stdlib-wave1/landing-07-{std,native}-attempt1.log.gz`.

## Combined landing gate

Full `bash tools/dew-test/run.sh` exited 0 in 163.61 s:
391 public tests (387 prior + 4 permanent new tests), 41 private
tests, builtin traps, repeat-byte check, and all 42 operation check scripts
passed. `DEW_NATIVE_TEST_PACKAGES=standard_loader bash tools/test-native.sh`
passed 31/31 tests in 14.26 s. Process-local Clang uses trailing
-g0 -O0 and bracket-depth 4096; the pinned SDK is unchanged. Compiler calls
over 30 s remain visible in the full logs. Build output was removed.
Logs: `data/stdlib-wave1/landing-07-{std,native}.log.gz`.
