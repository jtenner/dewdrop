# Bounded transform annotation preparation

This change removes repeated source scans from annotation setup. It keeps the
logical resource costs for name queries and fresh-name collisions.

## Implementation

- The existing lazy Plan source index now stores transform keys and first-entry
  call targets. A cold transform entry call no longer scans all declarations.
  Checked-source calls keep their proof-selected path. Loader append invalidation
  remains in place.
- The scanner stores each annotation's original line and byte column. One forward
  byte cursor computes the positions. LF starts a new line; CR and tab each add
  one byte to the column.
- Each function stores a start and count into the file's annotation array. Sorted
  cursors compute these spans and transform markers once. Annotation application,
  reflection selection, validation, and entry-root collection use these spans.
  Unannotated functions do not create a per-function VM or incur a new fee.
- A per-module map indexes raw source occurrences of `__dew_transform_` followed
  by decimal digits. It includes strings, comments, digit prefixes and overlapping
  occurrences. Each occurrence creates at most ten short keys. Each key stores
  the longest following underscore run. This preserves substring collisions.
  Each rejected candidate still charges 16 logical allocation units and one
  step. The final name is built once, after all collision charges succeed.

The new maps consume memory. The saved positions and spans also consume memory.
Construction is proportional to source size and declaration count, rather than
annotation count times source size. This is not a claim about constant heap cost.

## Checks

Native transform tests: 130/130 pass in 5.707 seconds. The private Native timing
control build and its four checks pass in 4.656 seconds, using a debug build.

Final Dew artifact:

- preparation 5/5;
- resource accounting 10/10;
- bytecode 13/13;
- frame roots 5/5;
- source index 4/4;
- transform interpreter 21/21;
- signature changes 10/10.

Dew generation took 9.993 seconds and linking took 2.193 seconds. The longest
selected test file took 12.357 seconds. The paired preparation tests cover
stacked annotations, public/private transform markers, original source positions,
raw substring collisions, leading zeros, longer digit strings, overlap, first
cold call selection, annotated call rejection, exact collision charges and a
65,536-underscore work-limit failure. The wide timing fixture also scans 4,096
unannotated functions.

The initial test used unsupported `transform pub fn` syntax. It failed visibly;
the fixture now uses supported `pub transform fn` and `transform fn` headers.
Two attempted Native command forms were rejected before compilation; their logs
are retained. These are not successful checks.

## Timing controls

Raw evidence is in `.tmp/transforms-v5/preparation-draft/`: `samples.json`,
`measure.py`, `identity.json`, `host-load.txt`, individual logs, both control
sources, `native-controls.exe`, and `dew-tests/tests.wasm`. One priming sample and
three measured fresh processes are saved for each case. Every sample passed.
The complete sample collection took 22.351 seconds.

| Engine | Functions | Method | Median process wall ms | Median peak RSS KiB |
| --- | ---: | --- | ---: | ---: |
| Native debug | 8 | scan | 19.252 | 16852 |
| Native debug | 8 | index | 12.417 | 16852 |
| Native debug | 4096 | scan | 3255.335 | 17412 |
| Native debug | 4096 | index | 129.628 | 17508 |
| Dew | 8 | scan | 146.663 | 78236 |
| Dew | 8 | index | 140.663 | 78260 |
| Dew | 4096 | scan | 1568.528 | 122812 |
| Dew | 4096 | index | 275.124 | 120808 |

Each case repeats marker, location and no-collision fresh-name setup 1,024 times
for one source annotation. It checks the results and unchanged logical counters.
This is a control for the removed setup work, not 1,024 full transform executions.
Both methods share one artifact and the new scanner. Thus the samples do not
measure the separate removal of old function-by-annotation scanner work. The
Native scan reproduces its old key-concatenation order; the Dew scan keeps its
cheaper transform-first filter.

Process time includes fixture creation, plan construction, parsing, index
construction, and test startup. Dew also includes Node startup and Wasm loading.
These are not isolated query times or a release Native runtime comparison. The
host is shared. Small timing and RSS changes are noise. Peak process RSS does not
measure live guest heap or retained index memory. There is no heap allocation
count, retained-memory gain, code-size gain, or full compiler throughput claim.
The ten-key-per-occurrence bound is structural; a separate adversarial peak-heap
profile for many distinct fresh-name occurrences was not collected.

The broader paired checked-source report lane and full lanes remain root-owned.
The old Dew untyped cold name-call path rejected the selected function if another
same-name function in that file was annotated. This over-rejection is removed.
The new offset guard retains the selected-declaration check, as Native and
checked-target calls do. Normal name resolution rejects ambiguous overloads.
The main agent reviewed and accepted this semantic correction after lane release.
