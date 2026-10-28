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
added in the next checkpoint. Use the same IDs in generated tests. Check decode
AND validate at public codec entry points where these are separate operations.
Do not claim a passing decode alone proves schema validation.
