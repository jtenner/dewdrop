# String library algorithms

String hashing, UTF-16 counting, searches, and prefix/suffix checks now reuse
the Dew Bytes/StringView scanning code. Native implementations of those scans
and their helper functions are removed. Search results remain logical byte
offsets, and hashing keeps the existing FNV-1a result.

String concatenation is an ordinary Dew function. It concatenates immutable
byte ranges through the Bytes API and casts the result back to String. Joining
valid UTF-8 ranges preserves validity, so no extra validation pass is needed.
Bytes allocation/copying is still a runtime helper until its storage migration.
String-to-Bytes now uses a single explicit unsafe reference cast, with no new
wrapper allocation; the immutable primitive record structures match.

Nine shared tests cover empty inputs, short and long needles, mixed view
affixes, each backing alignment, Unicode, stable hashes, concatenation, input
preservation, and literal pattern content comparison. They passed against the
old native implementation before migration (the first eight cases). The ninth
replaces a standalone equality probe that declared the removed concat builtin;
it tests computed values, function parameters, and record fields through the
real String library in both compilers. The compiler's main-file concat/Bytes
wrappers also call the library. Policy tests prevent these ten
algorithms becoming runtime builtins again.

## Remaining work

String equality is still a runtime builtin because literal pattern emission
looks up that runtime function directly. It needs a declared equality call in
the pattern plan before the old builder can be removed. The source-level Eq
and Ne methods must use the same planned declaration. Do not replace content
equality with `ref.eq`, or introduce a new source-name fallback.

String/Bytes storage access, views, builders, the SIMD storage bridge, and the
pinned provider's legacy builders remain separate open tasks. This commit does
not claim that all text builtins have been removed.

| Check | Result | Seconds |
| --- | --- | ---: |
| Native baseline before migration | 8 shared cases passed | 13.422 |
| Final stdlib and shared native execution | 326 tests and all shared checks passed | 13.064 |
| Self-host hardening | 234 tests, 29 invariant records, all shared checks passed | 54.708 |
| Native text integration | 19 passed | 13.568 |
| Final generated checks | passed | 3.490 |
| Clean A/B/C bootstrap | identical B/C bytes | 159.211 |

The hardening and bootstrap times remain performance bugs. Compiler A build
took 38.338 seconds; A and B compilation took 42.637 and 54.632 seconds. B/C SHA-256 is
`57848a045ae66eeaba6b4f50e747d312f36c622dffa5b1270de287c19f7e3f80`.
