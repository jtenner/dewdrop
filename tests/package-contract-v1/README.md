# Package contract v1 vectors

Rules: `docs/research/package-contract-v1.md`.
Run from the repository root. Node 24 and Python 3 are enough. No install is needed.

```sh
python3 tests/package-contract-v1/generate.py
node tests/package-contract-v1/run.mjs tests/package-contract-v1/adapters/baseline-registry.mjs
```

The baseline command MUST fail on the old publisher. It is regression evidence,
not a passing production test lane. It reads source from commit
`20f902acb6caa56a49712df832aeb0c46ec520b8`. It calls unchanged `capsule` and
`sourceFiles` function bodies in memory, with fresh temporary files. It removes
only imports, CLI state, and command dispatch. It supplies Node bindings and
blocks compiler/process/network calls. It does not read auth files. The probe
passes placeholder provenance to reach manifest and source checks. It does not
prove source integrity, compiler output, or capsule decoding.

## Stable schema

Each suite has `schemaVersion: 1`, `kind`, and `cases`. Each case has a stable
`id`, `input`, `expected`, and `rule`. The full ID is `kind/id`. `rule` names the
specific cause the case tests. Expected values are literal, not calculated by a
reader under test. `limits.json` lists byte and count caps, not a test suite.

Text can be a JSON string or a recipe:

- `{"repeat":"a","count":252}` repeats text.
- `{"concat":["@a/",{"repeat":"b","count":252}]}` joins text.

Recipes expand recursively in arrays and objects. Use only these exact tagged
objects. Expansion is bounded to 1,048,577 UTF-8 bytes per text. Manifest inputs
are RAW JSON text, not parsed objects. Do not use `JSON.parse` and reserialize
before sending them to a reader. That would erase duplicate and escaped keys.

| Kind | Expanded input | Expected output fields |
| --- | --- | --- |
| `name` | Name string | `accept` |
| `semver` | Version string | `accept` |
| `requirement` | Request string | `accept` |
| `requirement-match` | `{requirement,version}` with valid strings | `accept:true`, `matches` |
| `manifest` | Raw JSON string | `accept`, optional normalized `dependencies` object |
| `artifact-paths` | Array of source paths, in record order | `accept` |
| `source-selection` | `{entries:[{type,path,text?,target?}]}` | `accept`, compiler and artifact path arrays on success |
| `artifact-budget` | Numeric preflight fields | `accept` |

Budget inputs change one bound at a time. Unspecified fields mean a valid
single-file capsule with valid provenance, one small source, no dependencies,
and the local policy. `encodedBytes` is the COMPLETE encoded capsule, including
header, length prefixes, and the 32-byte digest. Budget vectors do not allocate
large buffers and do not prove a real codec enforces the bounds. A worker must
call a real preflight API or build the corresponding artifact under a later
resource lease. Do not count a synthetic budget checker as codec coverage.

Source fixtures use a fresh package root. Create parent directories, then each
entry in order. A symlink target is relative to the link parent. The escape case
points outside the package but stays inside the disposable fixture directory.
Reject a symlink in the selected source tree, including a `src` symlink. Ordinary
unselected files do not become source. Compile excludes `_test.dew`; artifact
and integrity include it. Successful arrays use global UTF-8 byte path order.

## Adapter API

Export `kinds` (an array of supported kind strings), and async
`evaluate(kind, expandedInput, test)` from an ESM module. Return an object with
`accept` and all expected fields. A rejection must carry a nonempty `diagnostic`
from the actual reader. Throw setup faults and unexpected errors. Never turn an
exception from the harness, a missing compiler, or a denied read into a package
rejection. Invalid cases must reach the intended field; keep nearby positive
controls. Check the diagnostic for the case's rule in the language-specific
adapter when the reader provides distinct error codes.

The runner compares all expected fields. Extra output is allowed. It reports
unsupported cases by ID. An explicit unsupported case or kind is an error.
There is no silent success when no cases run. Pass kind names or full case IDs
after the adapter path to select checks. Example:

```sh
node tests/package-contract-v1/run.mjs tests/package-contract-v1/adapters/baseline-registry.mjs manifest/dependencies-absent manifest/dependencies-empty
```

A Dew or MoonBit worker can import the JSON directly, or use the JSONL bridge
described below. Use the same IDs in generated tests. Check decode
AND validate at public codec entry points where these are separate operations.
Do not claim a passing decode alone proves schema validation.


## Batch reader bridge and test generator input

`adapters/jsonl-reader.mjs` accepts `DEW_CONTRACT_COMMAND` as a JSON argv array,
with no shell parsing. `DEW_CONTRACT_KINDS` is a comma-separated list of supported
kinds. The main runner selects cases, then calls optional `prepare(cases)` once.
The adapter starts the reader once for the selected supported cases. Use an
already-built narrow reader. Do not make the adapter build the compiler, or run
large allocation checks during the timing hold.

Each stdin line is one JSON object with `schemaVersion:1`, `id`, `kind`, and
expanded `input`. It contains NO expected answer or rule. Each stdout line must
be one response with the same `id`, `accept`, and the fields in the expected
result. Rejections require a reader `diagnostic`. Replies can arrive in any
order. Missing, duplicate, unknown, malformed, or ill-shaped replies are errors.
Stderr stays visible. Nonzero exits and setup faults are errors. The batch has a
30-second deadline and an 8 MiB output bound. This is a functional safety bound,
not a compiler performance result.

This command checks the protocol with a deliberately small fixture reader. It
is NOT a real package-reader check:

```sh
DEW_CONTRACT_KINDS=name DEW_CONTRACT_COMMAND='["node","tests/package-contract-v1/support/jsonl-reader.mjs","valid"]' node tests/package-contract-v1/run.mjs tests/package-contract-v1/adapters/jsonl-reader.mjs name/empty
```

For a generated language test suite, `emit.mjs [kind/id ...]` writes full expanded
case records as JSONL, INCLUDING expected values and rules. Keep this generator
input separate from the request protocol. Example:

```sh
node tests/package-contract-v1/emit.mjs manifest/duplicate-name-escaped
node --test tests/package-contract-v1/harness.test.mjs
```

The harness tests check data and process handling. Their green result does not
mean the production readers agree. `evidence/baseline.*` records production
reader differences; `evidence/harness-red.*` and `evidence/harness-green.*`
record the test-only bridge change. `evidence/functional.json` records generator,
CLI bridge, unsupported-case, raw-export, and baseline replay checks. No native
compiler or remote service is part of these checks.
