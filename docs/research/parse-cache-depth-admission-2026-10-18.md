# Parse cache depth admission

Date: 2026-10-18.

## Fault

The parse-event reader limits recursive syntax depth to 2048. The writer
previously stored deeper trees. A valid function with 2055 added terms passed
on a cold check, then failed on the next check when the stored tree was read.

## Change

The writer now carries the same depth value through each paired syntax helper.
Only the expression, type, and pattern node writers apply the depth bound,
exactly as their readers do. Array helper depth steps match the readers too.

`serialize_parse_events_for_cache` encodes and checks admission in one pass. It
returns no payload when the tree exceeds the reader bound. The loader then
keeps the freshly parsed events without storing an unreadable cache entry.
The explicit `serialize_parse_events` API returns a clear depth error.

There is no second parse, decode, or tree walk for ordinary admission. One
small mutable state object records rejection. The existing reader and cache
lookup error paths are unchanged: corrupt stored bytes still cause an error.
The source-size and syntax-depth limits remain separate.

## Validation

Boundary tests cover parsed function expressions with 2044, 2045, 2046, and
2055 added terms. The deepest expression in this function shape starts at
reader depth four, so 2045 terms reach depth 2048. The first two cases are
cacheable; the last two remain valid syntax but are not stored.

Separate type and pattern tests cover depths 2047, 2048, and 2049. Raw stored
expression bytes above the bound must still report a depth error.

Loader tests cover cold and warm use, a separate cacheable file, an edit to
that file, and corrupt stored bytes. They use an in-memory compilation pack
so that cache admission is checked without filesystem state from other tests.

All 305 parser tests pass (0.131 s). All three focused parse-event loader tests
pass (0.043 s). The full loader package passes 23 of 24 tests (7.615 s); its
unrelated fragment-cache count test expects five hits but observes four. The
lead agent received this failure for the owning change.

A same-process native release benchmark compares the prior writer against the
new writer on 128 function declarations. The new writer takes 47.14 us mean
with 0.28 us standard deviation; the old writer takes 47.89 us with 0.087 us
standard deviation. Each case uses ten batches of about 2100 iterations. The
complete command takes 20.664 s. This smoke comparison shows no time regression
on this input; it does not establish a speed gain or a peak-memory claim.
There is one small new admission-state allocation per encoded artifact.

The [raw benchmark output](data/parse-cache-depth-admission-2026-10-18/serializer-benchmark.txt),
[reproduction script](data/parse-cache-depth-admission-2026-10-18/reproduce_benchmark.py),
and [test/build details](data/parse-cache-depth-admission-2026-10-18/test-results.txt)
record the fixture, baseline, environment, build hash, and limits.
