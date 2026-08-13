# Final JSON performance experiments

Date: 2026-08-13

## Retained production changes

The final bounded experiment tranches retain four source-level APIs:

- specialized `json_validate`, which skips `JsonValue`, `JsonMember`, and value-array
  materialization while preserving exact duplicate tracking and every strict limit;
- `JsonRawDocument`, which retains only validated source until explicit materialization;
- parsed validated-number modes, which produce `JsonValue::ValidatedNumber` directly
  and skip number grammar revalidation during canonical serialization;
- canonical parse modes, which additionally produce `ValidatedString` values with
  parser-proven escape requirements so clean strings skip serialization rescans.

These remain ordinary Dew source. No JSON-specific compiler builtin, runtime helper,
host dependency, table, or dynamic call was added.

## Paired measurements

Node 26.3.0/V8, 30 warmups, 101 paired samples per round, five rounds.

### Specialized validation versus retained parse-and-drop

| Fixture | Retained parse/drop | Specialized validation | Delta |
|---|---:|---:|---:|
| small | 297.31 ns | 262.42 ns | -11.81% |
| medium | 3.533 us | 3.404 us | -3.57% |
| large | 9.799 us | 9.542 us | -2.83% |

### Number-heavy retained parse and canonicalize

A 973-byte array containing 128 exact numbers improved from 12.951 us with legacy
`Number(String)` values to 11.033 us with parsed `ValidatedNumber` values:
**14.81% faster**.

### Canonical string provenance

`json_parse_canonical` and `json_parse_retained_canonical` produce both
`ValidatedNumber` and `ValidatedString` variants. Clean parsed strings serialize
between quotes without another SIMD special-byte scan; decoded escaped strings
retain the checked writer path.

| Fixture | Legacy retained round trip | Canonical-provenance round trip | Delta |
|---|---:|---:|---:|
| small | 615.32 ns | 573.84 ns | -6.74% |
| medium | 8.211 us | 7.823 us | -4.72% |
| large | 23.712 us | 22.497 us | -5.12% |

### Current pinned json-as comparison

A fresh interleaved run after canonical provenance measured:

| Fixture | Dew compact parse | Dew retained parse | Dew validate | Dew raw source doc | json-as dynamic parse | json-as typed parse |
|---|---:|---:|---:|---:|---:|---:|
| small, 44 B | 380.27 ns | 310.81 ns | 281.39 ns | 288.53 ns | 230.25 ns | 82.77 ns |
| medium, 1,070 B | 5.364 us | 3.914 us | 4.274 us | 4.258 us | 769.12 ns | 1.806 us |
| large, 5,251 B | 15.364 us | 11.319 us | 11.286 us | 11.203 us | 2.578 us | 3.361 us |

Ratios:

| Fixture | compact / dynamic | retained / dynamic | validate / dynamic | raw / dynamic | compact / typed | retained / typed |
|---|---:|---:|---:|---:|---:|---:|
| small | 1.65x | 1.35x | 1.22x | 1.25x | 4.59x | 3.75x |
| medium | 6.97x | 5.09x | 5.56x | 5.54x | 2.97x | 2.17x |
| large | 5.96x | 4.39x | 4.38x | 4.35x | 4.57x | 3.37x |

Dew compatibility stringify measured 252.72 ns, 4.155 us, and 13.444 us for
small/medium/large. json-as generated typed stringify measured 57.48 ns,
488.46 ns, and 1.583 us. Dynamic `JSON.Obj` stringify remains semantically
non-equivalent source passthrough. Dew canonical-provenance parse plus stringify
measured 575.48 ns, 7.680 us, and 23.452 us, versus compatibility round trips of
723.05 ns, 9.706 us, and 28.710 us in the same run.

## Experiments tried and rejected

The following were implemented in isolated package roots or backend prototypes and
not retained because they did not improve all required workloads or did not link:

- fixed Array capacities 1/2/4/8/16;
- unconditional or threshold-free builder preallocation;
- cached writer-length state;
- fused scalar number-end/grammar scanning;
- shared and validated-mode SIMD digit-run validation; results were unstable
  across interleaved runs and did not consistently improve both paths;
- batched JSON punctuation through ordinary String appends;
- direct String SIMD for serialization;
- recursively generic visitor dispatch (`MissingFunction`);
- unconditional two-pass exact-size output;
- JSON-local exact Set tracking, still blocked by the Array-before-Map/Set backend
  scratch-local defect.

A SIMD digit-run scanner was also isolated to parsed validated-number mode. Results
were not stable enough to retain: one run improved the validated path 2.51% while
another regressed it 1.54%; the compatibility path ranged from -3.19% to +0.32%.
The scalar implementation remains deterministic and smaller.

## Remaining credible work

1. Fix recursive generic visitor linkage, then expose a reusable event engine.
2. Fix Array-before-Map/Set scratch-local allocation and benchmark exact tracking
   on objects with hundreds or thousands of keys.
3. Add general allocation counters and phase timing to separate scan, token,
   collection-growth, tree-construction, and serialization costs.
4. Prototype generated typed decoding for one frozen schema before designing
   annotation or derivation syntax.
5. Investigate general compiler constructor-to-array-store forwarding, nominal-cast
   CSE, and private Result success-path specialization.
6. Consider a structural index for `JsonRawDocument` only after selective-access
   workloads and source-retention limits are specified.
7. Revisit Array first-growth only with a representation change or a proven
   cross-library backend simplification; zero capacity and deterministic 4x first
   growth are public, snapshot-tested behavior.

The remaining medium/large gap is now dominated by exact duplicate policy and
generic recursive materialization rather than UTF-8 validation or token copying.
The next order-of-magnitude improvement requires typed decoding or indexed lazy
access, not another unmeasured scanner micro-optimization.
