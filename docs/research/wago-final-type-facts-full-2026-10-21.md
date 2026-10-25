# Repeated final-type facts: full compiler result

The type-only candidate is held. It passed its full normal, checked, and checked
benchmark suites. Its repeated-read microbenchmark improved by 6.75%, but this
did not become a clear full compiler gain.

The common source is the installed combined stack `321fae779`; candidate
production is `d2df1a91d6468daebe3a78a0a1a3766929447af2`, adapted in qualification
commit `90e37e98a`. No candidate code was pushed or installed. The earlier common
return-cache fix already exists in the installed reference-call ABI change.

| Engine | Three serial samples, seconds | Median, seconds |
| --- | --- | ---: |
| Combined control | 37.189480, 37.349002, 37.065532 | 37.189480 |
| Combined plus type facts | 37.057396, 36.931399, 37.217639 | 37.057396 |
| Default V8 | 3.998129, 3.981450, 4.037513 | 3.998129 |

The candidate median is 0.355% lower, with overlapping samples. These runs do not
establish a useful full-job improvement. The candidate remains 9.27 times V8.
All nine output Wasm and cache hashes match. The output validates, main returns
42, and every Wago artifact requires and supplies exact native roots.

The matrix uses identical compiler/request bytes, CPU12,14, GOMAXPROCS=2, fresh
native caches and transform-result misses. Orders are control/candidate/V8,
candidate/control/V8, control/candidate/V8. No task-owned build or test overlaps
the measurements. Exact commands, binary/source hashes, root admission, RSS and
raw logs are in [the data directory](data/wago-final-type-facts-full-2026-10-21/summary.json).

The change skips a repeated canonical-type comparison but retains the dependent
handle/space/header resolution chain. The new native profile points to that
chain as the stronger target. Astra identified an adjacent final array cast and
array read in the hot array accessor that resolve the same object twice. That
bounded fusion is the next experiment; this result is not evidence for broader
unchecked typed accesses.
