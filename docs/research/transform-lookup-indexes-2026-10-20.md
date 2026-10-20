# Transform lookup indexes and source resource costs

This change removes repeated scans from checked struct construction, source name
resolution, wide Dew record reads, and reference-view field access. The resource
policy still counts source events. Metadata index construction adds no logical
source fee. This counter is not measured heap allocation.

## Rules retained

- A Plan builds its source index on first use. It indexes module paths, members,
  import aliases and ordered open imports. Native checked-module appends clear
  the cache. Dew also checks module, file and imported-type-name counts.
- Member entries retain separate local/public results and the first shadow or
  overload error. Alias conflicts and duplicate open-import query fees remain.
- Dew records retain their binding array and mutable binding cells. Up to eight
  fields use a bounded reverse scan; wider records use a map. The last duplicate
  binding wins. Reference views use the first duplicate field position, with
  the same small/large rule in both compilers.
- Native helper guards use binary search over annotation targets stored in
  source order. The range is still `[function.offset, function.name_offset)`.
- Each raw Text storage read uses one step and UTF-8 byte length plus 16 logical
  allocation units, on both cold and warm reads. Text length reads use that same
  storage-read path. ByteText reads have no new fee. Failed Native charges do not
  populate the text cache.
- Array copy charges before temporary reads. A failed read commits no writes;
  overlap still uses the original source values. The new final-read failure
  test failed in Dew before the error guard was added.

## Checks

Final Native transform tests: 123/123 in 3.467 seconds. Final Dew artifact:
resource 8/8, source-index 4/4, bytecode 13/13, reference 16/16, intrinsic-contract
3/3, ordinary interpreter 21/21. The bytecode lane includes exact failure
boundaries. Final Dew generation took 7.942 seconds; linking took 1.578 seconds;
build plus selected resource tests took 14.645 seconds.

The Text cost test was measured red (two work events versus one) before its fix.
The Dew last-read copy test was measured red (target changed on failure) before
its fix. Logs are under the evidence directory below. Syntax errors during
intermediate generation were visible failures, not successful test runs.

## Scaling control

Evidence: `.tmp/transforms-v5/resources/index-scaling/`. It contains raw samples,
logs, the harness, build identities and host load. All cases check the result
and source-event counts. Each has one unmeasured priming process and three
measured fresh processes. Member cases make 4,096 queries; record cases make
65,536 queries. The large record scan visits up to 268 million bindings.

| Engine | Case | Median process wall ms | Median peak RSS KiB |
| --- | --- | ---: | ---: |
| native | members 8 scan | 6.514 | 16808 |
| native | members 8 index | 6.411 | 16808 |
| native | members 4096 scan | 52.301 | 16808 |
| native | members 4096 index | 19.921 | 16808 |
| dew | members 8 scan | 75.702 | 79104 |
| dew | members 8 index | 75.496 | 78640 |
| dew | members 4096 scan | 251.859 | 112856 |
| dew | members 4096 index | 120.766 | 99944 |
| dew | records 8 scan | 74.427 | 75968 |
| dew | records 8 index | 71.014 | 76044 |
| dew | records 4096 scan | 932.626 | 78936 |
| dew | records 4096 index | 79.662 | 80420 |

These are process measurements. They include VM startup, test setup, source
parsing, proof setup where present, and index construction. They are not isolated
query times. The scan member control omits some old shadow/visibility checks;
this makes the comparison conservative. The eight-field record control uses the
same short scan in both modes. Small time and RSS differences are noise.

The host was Linux x86_64 with Node v24.21.0. Other GCC jobs used about 3.8 and
3.7 GiB RSS and one CPU each during sampling. Do not infer small gains from this
shared host. Native control code was built before the final annotation guard,
inactive-plan access branch, and added copy tests; it is not a final-build Native
speed claim. Exact artifact and harness hashes are in `identity.json`. The Dew
artifact matches the final source for this lane.

The wide cases show the expected removal of repeated scans. Peak RSS neither
measures live guest heap nor proves retained-memory improvement. Wide records
keep an index in addition to their original binding storage. This has a memory
cost. Narrow records avoid a field-name map; the wrapper itself still has a cost.
No byte-size, heap-allocation-count, or retained-memory gain is claimed.

The first Native release build of the private scaling control took 31.608
seconds. This exceeds the project limit and remains a recorded build performance
fault. Shared host load is a confounder, not proof of its cause. Routine final
Native tests were below the limit. The temporary Native benchmark source was
removed; its source and executable remain in the private evidence directory.

The full paired checked-source report lane remains root-owned and must run
before the combined resource-policy change is committed. This task did not
stage or commit files.
