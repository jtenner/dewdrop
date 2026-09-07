# Bytes library algorithms

Bytes equality, FNV-1a hashing, byte search, substring search, prefix/suffix
checks, strict UTF-8 validation, and checked String conversion are now ordinary
Dew functions. The old native builders and implicit validator link dependency
are removed. Facet conversion helpers call the library too.

Equality uses complete 16-byte SIMD chunks and a scalar tail. Byte search uses
a comparison mask and trailing-zero count. Short substring search filters
candidates by their first and last byte; long search uses a rolling hash.
Both paths compare the actual bytes before accepting a candidate. Hashing keeps
the existing FNV constants and U64 wrap behavior. No operation allocates a view
or a temporary array while scanning.

The UTF-8 validator has an ASCII SIMD path and checks the exact two-, three-,
and four-byte ranges. It rejects overlong forms, surrogate encodings, values
above U+10FFFF, stray continuation bytes, and incomplete sequences. Bounds use
remaining length before any following byte is read.

Checked conversion runs this validator in Dew and traps with `unreachable` on
invalid input. Its final explicit unsafe cast emits one `ref.cast`, with no
copy or new wrapper. The current immutable String and Bytes records have the
same three-field WasmGC structure, including the backing heap type. Shared tests
check empty values and unaligned views. This does not justify arbitrary casts
between records or mutation of immutable storage.

The native planner incorrectly marked GC-backed SIMD loads as linear-memory
operations. Removing those flags restores the existing no-linear-memory tests.

## Tests

The nine algorithm cases passed against the old implementation before it was
replaced. The shared corpus now has twelve cases, including two exact
`unreachable` checks for invalid checked conversion. It runs with both compilers.
A source policy test prevents these eight entry points becoming builtins again.
The backend test checks that the validator and checked conversion have linked
Dew bodies, rather than compiler runtime bodies.

| Check | Result | Seconds |
| --- | --- | ---: |
| Native text/backend integration | 18 passed | 12.138 |
| Stdlib and shared native execution | 325 tests and all shared checks passed | 21.230 |
| Self-host hardening, including method-context regressions | 232 tests, 29 invariant records, all shared checks passed | 53.211 |
| Generated checks | passed | 15.414 |
| Clean A/B/C bootstrap | identical B/C bytes | 159.714 |

The hardening and bootstrap runs exceed 30 seconds and remain performance bugs.
Compiler A build took 38.634 seconds; A and B compilation took 42.683 and 54.754
seconds. B/C SHA-256:
`df19716a8126930fd8c2cd0c0d34784199d5342bbf8d400bf56967ceaaecdf80`.

The Bytes probe also exposed a method result-context error. The independent
[inference fix](method-result-context-2026-09-06.md) lets the outer method supply
the inner conversion's required U8 result without hiding true ambiguity.

## Remaining storage work

Bytes length/access, views, concatenation, builders, and the SIMD storage bridge
still use old runtime helpers. String and StringView still use shared native
algorithms. These are separate remaining tasks, not completed by this commit.
The pinned Starshine provider still contains legacy runtime builders; no new
Bytes algorithm call is emitted to them. Remove the remaining provider builders
with the complete text storage migration.
