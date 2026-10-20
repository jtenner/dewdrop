# Persistent transform results

The Native driver can save a version 1 expansion artifact in the existing
compilation cache pack. `DEW_TRANSFORM_CACHE=0` disables it. Automatic use needs a
nonempty `DEW_COMPILER_FINGERPRINT` from the compiler build. The explicit driver
API takes a compiler identity and prior artifact bytes, and returns a snapshot.

Keys bind the compiler identity, ordered source files and module graph, complete
source pool, standard sources, transform API sources, module IDs, root, preamble,
and test planning mode. File bytes are hashed separately; key construction does
not concatenate all source bytes. The automatic path checks input bounds before
hashing and shares its key with expansion.

Artifacts contain only expanded source and resource reports. They contain no VM
cells, AST handles, checked proofs, or compiler plans. A hit still runs ordinary
source, inference, lowering, and link checks. A miss is not published if those
checks report a source error. The late initializer cycle regression first failed
at the saved-snapshot assertion, then passed with the publication guard in both
driver paths.

The artifact limit is 16 MiB. This is a serialized size limit, not a heap limit.
The decoder checks the version, exact key, checksum, lengths, duplicate module and
file names, counts, resource report bounds, and exact end. A damaged inner entry
is a miss. A damaged outer compilation pack still follows its existing error
policy. Large artifacts compile normally without replacing the last saved entry.

## Native evidence

Raw data is in `.tmp/transforms-v5/resources/cache-native-*.log`.

- Initial intended cache test: warm session was a miss; 10.296 s.
- Six safety tests after the late publication fix: 6/6; 14.519 s.
- Corrupt artifact fallback and imported source-pool transforms: 8/8; 17.720 s.
- Read-only GPT review and follow-up: no remaining confirmed defect in reviewed
  Native code. At that review, no direct disk-pack late-error regression had run; the final
  control below covers it. Claude review
  was unavailable because its weekly quota was exhausted until October 24.

The first disk-cache control used a release Native CLI build before the final
publication guard and shared-key change. It is not the final build benchmark.
All other compiler cache layers were disabled. Seven separate process runs built
`examples/transforms/local.dew`. Every Wasm result was byte-identical (16,607 B),
validated, and returned 42. Cold miss: 0.706013 s. Three cache hits: median
0.244515 s, median peak RSS 36,376 KiB. Three cache-disabled runs: median 0.677258 s,
median peak RSS 40,460 KiB. One shared host, one small input; no broad performance
or retained-heap claim follows. Harness, build hash, and raw samples are under
`.tmp/transforms-v5/resources/cache-native-disk-v1/` and
`cache-native-disk.py`.

The Dew port and persistent request mode are now validated below.

## Dew implementation and final checks

The Dew port uses the same version 1 source/report record layout, with an engine
key domain and a preserved test-only file flag. It hashes views instead of copying
the whole payload for checksum validation. Official compiler builds generate a
separate source/build identity; direct builds retain an empty stub and reject
requested persistent caching. The ABI/provider fingerprint is not used as the
compiler build identity.

Request mode 0 keeps its existing form. Mode 1 adds bounded prior artifact bytes
and a distinct relative output file path after the source pool. Both compiler
request paths wait for normal checks, linking, and output write success before
writing a cache file. Cache reports use the Dew compiler's existing diagnostic
output API. An initial Node host test caught an unsupported stdout call; the
compiler now uses its existing stderr path.

Final validation to this point:

- Native cache tests: 9/9; request codec: 12/12. The final cache and
  standard-loader run takes 21.847 s, including all 30 standard-loader tests.
- Full Native compiler integration: 272 tests in 17 files; 73.737 s aggregate.
- Full Dew transform tests: 288/288; 79.551 s execution, 93.026 s aggregate.
  A later pool-only source regression passes in a separate 7-case cache run
  selected from 289 registered tests; 15.499 s. This is not a full 289-case run.
- Fresh-process request cache checks pass in Native and Dew under Node: cold
  miss, three hits, three disabled controls, corrupt checksum fallback,
  conservative unused-pool dependency invalidation, output-write error, and
  invalid cached generated source with a valid checksum. All nine successful
  outputs are byte-identical within each engine, validate, and return 42. Both
  failure cases leave a sentinel cache file unchanged. The invalid cached body
  produces a Native LocalTypeMismatch and a Dew logical type constraint error;
  it cannot fall back to a successful normal expansion.
- The checksum-negative source test uses the existing Native request fixture's
  BLAKE3 fingerprint writer with an empty provider, so it needs no new crypto
  package. It does not run that hash-only request.
- Final Native automatic disk-pack control: seven builds produce equal Wasm and
  the expected miss/hit/disabled states. A late initializer source cycle leaves
  the entire pack byte-identical. Raw results: `cache-native-disk-v3/`.
- Final B/C fixed point and semantic probes pass. B/C SHA256 is
  `2b2a7e0fc1459a88654ddfdb15277d6ffeb78d25e894692afcefd37cb0c3fec6`.
  Total 78.217 s; A build 18.410 s, A to B 22.498 s, B to C 23.817 s.
- A fresh identity generation matches the exact compiler build input identity.

Measurements above 30 s remain recorded performance faults. They include full
suite and multi-process batches. They are not hidden by the successful results.

## Fresh-process measurements

Raw samples include command, build hash, elapsed time, and process peak RSS.
These are three samples per hit/disabled group on one shared linux/amd64 host.
They are not retained-heap measurements or a general compiler benchmark.

| Test | Hit median | Disabled median | Hit peak RSS median | Disabled peak RSS median |
|---|---:|---:|---:|---:|
| Native automatic pack | 0.238234 s | 0.675266 s | 36,268 KiB | 40,444 KiB |
| Native source request | 0.677866 s | 1.475908 s | 214,348 KiB | 214,440 KiB |
| Dew source request, Node | 1.636646 s | 3.505628 s | 442,076 KiB | 543,096 KiB |

The source-request artifact is 492,700 B in both engines. The output is 598 B in
Native and 11,021 B in Dew; no cross-engine code-size equality is claimed. Request
samples are in `.tmp/transform-cache/run-6kppcvcq/` and `run-2riama__/`. The final
additional source-error controls are in `run-cze44fgb/` and `run-yl6v_jls/`.

## Pinned Wago fault and bounded repair

The self-built B fails in ordinary lowering on pinned Wago 2dd978ccda6f, with a
cast trap. The prior pre-cache B also fails in the same helper with caching off.
The current B with caching off reaches a compiler invariant trap. This establishes
a pre-existing B/Wago compatibility problem, not a confirmed cache-specific cause.
Node success and the fixed point do not prove Wago execution correctness.

A read-only review found a later Wago reference-root repair at commit
14e81db2a9a9e57ef5cba347f93474fdaa151378, but did not link it to this trap.
A private host build at that revision cannot compile with Facet v0.1.0 because
its HostFunc API has changed. The repository pins and the separate dirty Wago
checkout remain unchanged. Native-built A passes the cold and cache-hit requests on the unpatched pin.
Cold: 171.319063 s, peak RSS 2,466,204 KiB. Hit: 56.104615 s, peak RSS 2,503,916 KiB.
Both outputs validate and return 42. The Wasm outputs and artifacts are
byte-identical between runs; the artifact also matches the Node B control.
The full command takes 231.497 s. These remain performance faults. One cold and
one hit sample are not a general Wago performance claim. Evidence is in
`.tmp/transform-cache/wago-6p58pa2i/` and `cache-wago-a.log`.
Those A timing samples did not isolate Wago's native artifact cache. The hit may
reuse native code as well as transformed source; the difference is not an
isolated transform-cache speed gain. No dependency update was included in the
cache commit.

The follow-up keeps the same Wago and Facet pins and backports only three
reference-root source changes from that commit. The old exact-liveness pass
removes dead frame locals, but a reference loaded from one of those locals can
remain live on the operand stack. Retaining the original reference-local type
list lets `TracksLocal` classify that load correctly. Compact safepoint masks
remain unchanged. The separate newer direct-getter optimization is excluded.

The reduced decoder-tuple test fails on the original pin with a reference field
type mismatch (9.500 s). With the three-file patch it passes, along with the
frame-root, loaded-child, serialized-code, pressure, and invalid-parent tests
(8.084 s). Tests accept only the pinned helper's exact known errors for forged,
wrong-type, and i31 parent references, or the specified typed trap. Null still
requires its typed null trap. The plan footprint assertion passes at 160 B,
up from 136 B. A compacted plan also retains its original source-local array.
This is a known static memory cost, not a measured memory improvement.

The exact current B compiler then passes both real cache requests in the patched
host. Each process uses a different new absolute `WAGO_HOME`, so neither can
reuse the other's native artifact. Cold: 87.915754 s, peak RSS 3,263,896 KiB.
Hit: 32.899978 s, peak RSS 3,292,456 KiB. Both outputs validate and return 42;
their Wasm bytes and cache artifacts match each other and the Node cache
artifact. Total: 124.532 s. These are performance faults. These single samples
were on a shared linux/amd64 host with other Go activity; they are not a general
speed claim or an isolated heap measurement. No ARM64 runtime test was run.

`tools/build-wago-transform-host.py` now extracts a checksum-verified pinned Go
module into a new private directory, applies the checked-in code and exact test
patch, optionally runs those tests, and builds the host. It writes an identity
record. The patch hash is part of the host's native artifact cache identity.
The Go module cache and the separate Wago checkout stay unchanged. The public
`tools/test-transform-wago.sh` command uses this build with safety tests and a
fresh host cache, then checks B's real output. It passes in 99.141 s total;
the host execution is 83.981 s. CI now tests self-built B instead of A.

Read-only independent review found no remaining defect in the three source
changes or exact adapted tests. Claude review was unavailable due to the weekly
usage limit. Evidence:

- `.tmp/transform-cache/wago-root-control-wsytffno/` (red/green and build identity);
- `.tmp/transform-cache/wago-root-fixed-_zkl_5fy/` (cold/hit requests);
- `.tmp/transforms-v5/resources/wago-root-public-command.log`;
- `.tmp/transforms-v5/resources/cache-review/root-only-final.md`.
