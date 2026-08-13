# JSON Bloom duplicate-key prefilter

Date: 2026-08-13

## Scope

Strict `dew.std.json` object parsing and serialization now use the reusable
`dew.std.bloom_filter` module to avoid most quadratic prior-key equality scans
for wide objects. The authoritative representation remains the source-ordered
`Array<JsonMember>` during parsing and the temporary source-ordered
`Array<String>` during serialization.

The optimization does not change JSON semantics:

- duplicate keys still produce `JsonParseError::DuplicateObjectKey` or
  `JsonWriteError::DuplicateObjectKey`;
- a Bloom positive is never accepted as exact membership evidence;
- every positive performs the existing full equality scan;
- a Bloom negative alone proves absence;
- distinct colliding strings such as `"p"` and `"0"` remain valid;
- key evaluation, member construction, and source order remain unchanged.

## Activation policy

Objects use the original linear duplicate check for the first 16 keys. At the
seventeenth key, parsing seeds four scalar `BloomFilter` values from the first
16 keys and then hashes each later key once. Serialization knows object width in
advance, so objects with at least 16 members use the four filters from the first
member; smaller objects stay on the original path and perform no key hashing.

Each key selects one of four filters from hash bits 43 and 44. The selected
filter still uses the reusable module's two standard probes. Four filters were
chosen because one 64-bit filter saturated too quickly on the large benchmark:
fixture analysis predicted roughly 1,959 exact-comparison units after Bloom
positives, whereas four filters with bits 43-44 reduced the prediction to 67.
The deterministic `"p"`/`"0"` collision remains in one shard, so tests exercise
the exact-positive fallback rather than avoiding it through sharding.

The implementation remains allocation-free beyond arrays already required by
strict JSON. It adds four `U64` locals per active object and no compiler builtin,
runtime helper, table, map, or set.

## Measurement

Measurements used the compact json-as small, medium, and large fixture strings,
Node 26.3.0/V8, approximately 256 KiB per timed batch, 30 warmups, 101 samples
per paired round, five rounds, and interleaved execution of modules built by the
same Dew compiler with Bloom disabled versus enabled. Reported percentages are
the median delta across the five paired rounds.

Threshold 16 with four filters and shard bits 43-44 measured:

| Fixture | Parse String | Parse Bytes | Stringify | Round trip |
|---|---:|---:|---:|---:|
| small, 44 B | -2.26% | -3.13% | +2.09% | +1.72% |
| medium, 1,070 B | -0.77% | -0.97% | -5.85% | -3.31% |
| large, 5,251 B | -20.77% | -21.22% | -25.43% | -23.40% |

Negative values are faster. Small and medium differences are near benchmark
noise except for the reproducible serialization gain once the 16-member medium
root activates the filter. The large fixture contains a 79-member root object
and a 19-member nested object, so it benefits substantially from replacing most
prior-key equality scans with scalar hash/filter operations.

A threshold of 32 avoided activating the medium root but was consistently slower
on the large fixture: repeated paired measurements were approximately 14.2%
faster for parsing and 18.2% faster for round trips, versus approximately 16.5%
and 19.4% with threshold 16 before selecting the better shard bits.

`tools/benchmark-json-bloom.py` reproduces the paired comparison by copying the
current standard package into isolated enabled and disabled roots, changing only
the private activation threshold in the disabled copy, building both variants
with the same compiler, and interleaving their Node/V8 execution.

These measurements remain machine-local evidence rather than a permanent
pass/fail performance budget. Future duplicate tracking may revisit the shard
count or threshold if key distributions, hashing cost, or object representation
changes.
