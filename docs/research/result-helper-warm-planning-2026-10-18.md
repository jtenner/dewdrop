# Result helper warm-cache cost

## Result

Adding the `Result` methods reduces warm fragment hits from five to four on the
small planning-cache fixture. The two timing checks did not show a clear cost
above the sample noise. Cache policy is unchanged.

| Native warm path, 21 samples each | Old Result | New Result |
| --- | ---: | ---: |
| Whole CLI call, median | 220.887 ms | 221.560 ms |
| Whole CLI call, standard deviation | 4.132 ms | 3.578 ms |
| Lowering and fragment link planning, median | 66.982 ms | 67.135 ms |
| Planning, standard deviation | 1.701 ms | 1.637 ms |

The difference between CLI medians is +0.673 ms, or 0.30%. For each paired run,
new minus old has a mean of -0.137 ms and a standard deviation of 4.943 ms. CLI
sample ranges overlap: 218.768–234.676 ms old and 218.636–231.152 ms new.

The difference between planning medians is +0.152 ms, or 0.23%. The paired mean
difference is +0.091 ms with a standard deviation of 2.132 ms. Planning sample
ranges also overlap: 65.287–72.648 ms old and 65.433–72.408 ms new. Run order
affects individual planning samples; the order alternates to reduce that bias.
These results do not establish that the bypass has no cost.

## Controls

The fixture is the planning-cache test's `pub fn main() -> I32 { 1 }`. It loads
six modules: the user module, preamble, Option, Result, text runtime, and Wasm
intrinsics. Old and new standard-source trees differ only in `std/result.dew`.
The old file is the enum-only source before commit `a747c7c6be`; the new file
adds the four methods. Both variants use the new Option source.

The CLI comparison uses one copied native CLI executable for both variants:
SHA-256 `24665a1a8605c6c51061901a2aa2a88f5eb619f561e5f45c105643970a2832a3`,
7,816,072 bytes. This pinned executable predates the final flow fixes. The
fixture does not use the changed flow cases. Its exact identity is retained;
the test does not claim to time a later rebuilt CLI.

Each variant has its own cache directory and compiler fingerprint derived from
that binary. The command selects its standard-source tree, enables planning
caches, and disables program-output, interface, and body caches. Parse caching
is warm. Each variant runs one cold call, three warmup calls, and 21 measured
calls. Old/new order alternates per pair. Each subprocess is timed with
`perf_counter_ns`; that time includes process start, source loading, compiler
work, and cache reads.

Every measured CLI call reports 17 parse hits, six layout hits, zero layout or
fragment misses, and five old or four new fragment hits. The program-output
cache stays off so it cannot hide phase work. Each variant has one saved pack:
429,696 bytes old and 426,752 bytes new. These sizes are fixture observations,
not a general memory saving.

## Planning timer

The CLI has no phase timer. A separate temporary native executable uses public
compiler APIs and contains both variants in one build. It loads the same
standard-source trees, collects and analyzes each program before timing, and
opens separate in-memory pack sessions. Four initial calls include one cold
call and three warmups. It then alternates 21 measured pairs.

The timer covers `plan_program_lowering_with_cache` and
`plan_program_wasmgc_link_with_cache`. This includes warm layout recovery,
fragment context hashing, cached-fragment decoding, fresh generic enum fragment
planning, and linking. It excludes source loading, parsing, collection,
semantic analysis, and file publication. Each result is observed, and each
warm fragment count is checked. The timer uses the native monotonic clock.

This probe built once in 15.008 seconds with `-Og` and ran in 3.736 seconds.
Its executable SHA-256 is
`4e8e9e9c7f6fda33fb68c4defc0b48a2b4d5bdaf58ca37d9e46844f37716091b`.
The build uses the then-current native compiler source, including local flow
fixes. The source commit and every production source hash are recorded in
`planning-build-identity.json`. Both variants execute that same build. The
temporary package was removed after the run.

The host was an AMD Ryzen 7 8845HS on x86-64 Linux. Moon was
`0.1.20261012 (748b63c)` and moonc was `v0.10.15+943464bfa`. The tests used native
execution. No compiler activity exceeded 30 seconds; the longest CLI call was
0.261 seconds. No allocations, peak RSS, runtime helper speed, or production
code-size gain were measured.

## Limits and repeat steps

This one fixture does not call the new Result helpers. It measures their effect
on warm compiler work when they are available in the library. Larger programs
or other architectures need separate measurements. A normal whole-program
cache hit returns before these planning stages.

The [evidence directory](data/result-helper-warm-planning-2026-10-18/) contains
all raw samples and cache reports, summaries, fixture snapshots, exact CLI and
planning build identities, environment, and harnesses. To repeat with a native
CLI build from the repository root:

```sh
python3 docs/research/data/result-helper-warm-planning-2026-10-18/reproduce.py \
  --cli _build/native/release/build/jtenner/dewdrop/dew_cli/dew_cli.exe --planning
```

The script records the supplied CLI hash. A different binary is a new
measurement. It exports the pinned common standard-source commit and the saved
old/new Result files, uses a new temporary work directory, and removes its
temporary measurement package after the planning build.
