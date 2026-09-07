# Front-end body arena contracts

## Scope

Both compilers now check all ten HIR body spans before name resolution, local
inference, or flow analysis allocates body-local work arrays. Name resolution
also checks its parameter span against the correct regular/lambda parameter
arena.

Relative expression, pattern, block, block-item, arm, and object-field lookups
use one checked helper per compiler. The check proves the global span is valid,
then checks membership before subtraction. It does not use an overflowing
`start + length` comparison. Pattern inference's direct relative accesses and
flow analysis's relative reads/writes now use the helpers too.

Self-host flow's explicit absent-optional-expression case still has fall-through
flow and performs no array access. The new checks apply to present expressions;
they do not change that optional syntax rule. A loop's proven end-of-span test
also remains a loop condition, not an attempted element lookup.

## Stable records

Failures use ARN-101 for bad spans and ARN-102 for body membership. Records retain
module, declaration, body, and phase. A present expression ID is included for
expression accesses. Other arenas use the expression sentinel and retain the
bad index in `actual`. The high 32 bits of `detail` identify the arena; the low
32 bits retain span length for ARN-101 or span start for ARN-102. Native signed
indices are recorded as their unsigned 32-bit representation.

| Tag | Arena |
| --- | --- |
| 0 | Expressions |
| 1 | Expression children |
| 2 | Blocks |
| 3 | Block items |
| 4 | Patterns |
| 5 | Pattern children |
| 6 | Pattern arms |
| 7 | Arm children |
| 8 | Object fields |
| 9 | Pattern fields |
| 10 | Name-resolution parameters |

The callers use phase 1 for name resolution, 2 for inference, and 3 for flow.
Tests check cross-body IDs, a machine-boundary span, an invalid final arena,
and the exact record from actual name-resolver calls. Valid fixtures are checked
before a one-field mutation.

This is not a claim that all child lists, stored semantic IDs, parallel arrays,
or later lowering/emission consumers are fully verified. The larger arena and
physical-boundary tasks stay open.

## Measured checks

- The first fixture used invalid inline Dew blocks and caused a test setup array
  trap (11.089 seconds focused; 92.567 seconds in the already-started native lane).
  Fixtures now use valid multiline blocks and assert collection diagnostics and
  body counts before indexing. The two focused tests pass in 9.412 seconds.
- Native suite: 1,024 tests pass in 146.966 seconds. Semantic tests took 91.581
  seconds and backend tests took 42.799 seconds; these remain speed bugs.
- Self-host hardening: 325 tests, 75 exact invariant records, and all shared
  execution corpora pass in 74.475 seconds. Generation took 33.165 seconds.
  Both exceed 30 seconds and remain speed bugs. No speed work is included.
- Compiler integration: 268 tests pass in 55.184 seconds.
- Library tests and all shared native execution corpora pass in 17.933 seconds.
- Generated-source checks pass in 16.045 seconds.
- Clean bootstrap passes in 165.590 seconds. A build took 40.722 seconds;
  A and B execution took 45.172 and 57.756 seconds. These remain speed bugs.
  B/C core and linked bytes match. Linked SHA-256:
  `5b3ef47c54c90923e4b9014c1719d623a7189c1e703422f4c05168384e02b27b`.
