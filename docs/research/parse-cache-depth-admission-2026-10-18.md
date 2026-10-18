# Parse cache writer and reader bounds

Date: 2026-10-18.

## Fault

The parse-event reader limits recursive syntax depth to 2048. The writer
previously stored deeper trees. A valid function with 2055 added terms passed
on a cold check, then failed on the next check when the stored tree was read.

A later independent review found the same mismatch for list counts. The
reader accepts at most 1,048,576 items in each list, while the writer had no
count bound. A list with 1,048,577 small values needs about 2 MiB of source,
which fits below the separate source-size limit. Rejecting depth alone does
not make that stored payload readable.

The count audit found another reader fault: five scalar index/arity fields
used the array-count reader. That reader checks that at least one payload
byte remains per item. Scalar values have no such payload requirement. A
product field at index 31 with arity 32 can have only two trailing bytes.

## Change

The writer now carries the same depth value through each paired syntax helper.
Only the expression, type, and pattern node writers apply the depth bound,
exactly as their readers do. Array helper depth steps match the readers too.

`serialize_parse_events_for_cache` encodes and checks admission in one pass. It
returns no payload when the tree exceeds the reader bound. The loader then
keeps the freshly parsed events without storing an unreadable cache entry.
The explicit `serialize_parse_events` API returns a clear depth error.

All 21 nested list-count writes now use one checked helper. The top-level
event count is checked before its output-buffer size hint is allocated. An
oversized count rejects the entry before the count or any list element is
written. The same admission object stores the rejection and its reason;
there is no second tree walk. The explicit serializer reports an item-count
error, while cache serialization returns no payload. Fresh syntax stays usable.

The product-field index and arity, plus three diagnostic-arity values, now
use a bounded scalar reader. Their numeric bounds are unchanged. The 22 real
list readers retain both the item limit and the remaining-byte guard. Their
writer checks use the same bounds. Scalar index/arity writes also obey their
paired reader bounds.

There is no second parse, decode, or tree walk for ordinary admission. One
small mutable state object records rejection. The existing reader and cache
lookup error paths still make corrupt stored bytes cause an error.
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
pass (0.043 s). An earlier full loader run exposed a stale fragment-cache test assumption.
The new Result helpers add another generic enum module that is intentionally
not cached. The test now checks the two excluded modules and the four stored
fragments. Its three focused tests pass (5.044 s). This was a test assumption,
not a production cache defect.

Before the count and scalar-reader follow-up, a same-process native release
benchmark compared the prior writer against the depth-checked writer on 128
function declarations. The new writer takes 47.14 us mean
with 0.28 us standard deviation; the old writer takes 47.89 us with 0.087 us
standard deviation. Each case uses ten batches of about 2100 iterations. The
complete command takes 20.664 s. This smoke comparison shows no time regression
on this input; it does not establish a speed gain or a peak-memory claim.
There is one small new admission-state allocation per encoded artifact.

The [raw benchmark output](data/parse-cache-depth-admission-2026-10-18/serializer-benchmark.txt),
[reproduction script](data/parse-cache-depth-admission-2026-10-18/reproduce_benchmark.py),
and [test/build details](data/parse-cache-depth-admission-2026-10-18/test-results.txt)
record the fixture, baseline, environment, build hash, and limits.

## Count and scalar follow-up validation

The bounded-count helper is tested below, at, and above 32 and 1,048,576. The
accepted count cases carry one dummy payload byte per item. This checks the
actual array reader guard without allocating one syntax object per item.

A real 1,048,577-element expression array shares one expression object. Its
writer rejects the array before writing its count. Both serializer APIs reject
the entry with the expected result. A second test checks a real event array
of the same size; the event bound runs before allocating its size hint.

Product field index 31/arity 32 and bounded scalar diagnostic values now round
trip with short payloads. Oversized diagnostic values are cache-skipped.
Oversized stored event counts remain visible errors.

All 18 focused parse-event tests pass in 1.410 s. The complete Moon command
used 244,156 KiB peak child RSS, including compilation. Separate direct native
runs exclude the compiler. Each actual oversized-array test was run three
times, with a fresh test process for each sample. They take 3.6–4.5 ms and use
16,184–16,496 KiB peak RSS. These figures include native process overhead and
the shared-reference arrays. They do not measure accepted-list decoding or
claim a general compiler memory improvement.

The [raw native samples](data/parse-cache-depth-admission-2026-10-18/item-runtime-samples.json)
record source and binary hashes. The
[measurement script](data/parse-cache-depth-admission-2026-10-18/measure_item_admission.py)
checks native result messages as well as exit status. The environment remains
Moon 0.1.20261012, Linux x86_64 on an AMD Ryzen 7 8845HS. These follow-up tests
use the native debug test build.
