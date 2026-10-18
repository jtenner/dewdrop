# Native test-generator cold builds

The UTF and WASI parity tools built the whole native Dew compiler with release
C optimization. On October 18, these build-and-generation steps took 96.188 and
93.698 seconds. Both exceed the project’s 30-second compiler budget. The root
validation run observed GCC compiling the large generated C file with `-O2`.

The tools now use native debug builds with two build workers. The snapshot tool
has the same compiler dependencies and uses the same build mode. It builds its
generator once and still runs each fixture twice with a private cache, compares
the Wasm bytes, validates Wasm, runs both engines, and compares WAT snapshots.
No expected output, fixture, assertion, Dew optimization, or runtime was removed.
Both parity generators still select `CompilerPipelineOptions::production`.
Each parity phase and the snapshot native build report elapsed time. A phase
over 30 seconds prints a performance-bug message. Command failures still fail.

## Measurements

These are single wall-time samples on Linux x86-64, GCC 14.2, Moon
0.1.20261012, and Node 24.21.0, with normal development host load. Each cold
sample used a new, empty Moon target directory. They are local observations,
not portable time guarantees. Raw samples, commands, executable hashes, and
the environment are in [results.json](data/parity-generator-cold-builds-2026-10-18/results.json).
The check summaries are in [checks.txt](data/parity-generator-cold-builds-2026-10-18/checks.txt).

| Work | Release build and generation | Debug build and generation | Full new script |
| --- | ---: | ---: | ---: |
| UTF, 971 cases and 17,471 checks | 96.188 s | 23.230 s | 23.534 s |
| WASI, 196 checks | 93.698 s | 11.517 s | 11.826 s |

A separate cold build of both native debug generators took 13.360 seconds.
Direct debug execution then took 12.830 seconds for UTF and 0.853 seconds for
WASI, with fresh private interface caches. The two scripts were also tested
from separate empty target directories; their build times must not be added
to the separate shared-build sample.

UTF output was 8,109,244 bytes, SHA-256
`05c160d07da02322663ee94a6f888955814ed80e989398053c9cbf4d77f05f37`.
WASI output was 575,591 bytes, SHA-256
`e02b71287f7bf2666574e4333dd9b9b340460aa49ad6651a70a39ad6c2e8827c`.
Both match the release-generated artifacts byte for byte. Guest runtime and
guest memory behavior therefore use the same program bytes in these probes.

The snapshot generator’s cold debug build took 12.806 seconds. Its first
runtime probe then stopped because the Go version was not selected in the test
environment. This is separate from compiler time. With Go selected, the full
`text/concat` probe took 3.872 seconds and passed compilation, repeat-byte
comparison, Wasm validation, Node/Wago output agreement, and the expected
runtime output. It failed the WAT snapshot comparison: the current Option and
Result helper declarations add physical function signatures and shift type
indices. That failure remains visible. No snapshot was updated by this work.
Direct debug and existing release snapshot generators both emit identical
`text/concat` Wasm, SHA-256
`6cf2ed1cb10f5c721e82a7e67db3161702db6440ceaab5d46543d0544e6d6721`.
The existing release generator was not rebuilt or proven current for all source
changes; this comparison establishes output identity for this fixture only.
No cold release snapshot build was measured; the parity measurements establish
the release-build defect, while snapshot uses the same preventive tool change.

## Costs and limits

The debug parity executables are about 39.5 MB on disk; their release versions
are about 9.0 MB. This includes debug data and is not a resident-memory claim.
The change makes no claim of lower compiler RSS. The WASI cold-script process
tree high-water sample was 775,548 KiB; no matching release RSS control was
collected. Debug native compiler execution can be slower after the first build.
The August warm UTF result in [validation-performance.md](validation-performance.md)
remains historical evidence of that cost. The present direct debug UTF sample
is below 30 seconds. Further native compiler build optimization is still useful;
this change removes the costly release C pass from correctness test tools.

## Repeat

The scripts accept Moon options, and the snapshot tool accepts `--target-dir`.
Use new paths for cold samples. They write normal ignored generated artifacts
but do not update snapshots.

```sh
tools/utf-parity/run.sh --target-dir /tmp/dew-utf-new
tools/wasi-parity/run.sh --target-dir /tmp/dew-wasi-new
mise exec wasm-tools@1.262.0 go@1.27.2 -- \
  tools/module-snapshots/run.sh --fixture text/concat \
  --target-dir /tmp/dew-snapshot-new
```

The repeat harness [measure.py](data/parity-generator-cold-builds-2026-10-18/measure.py)
uses new target directories, records elapsed time, and saves stdout and stderr
outside committed research data. It checks each command’s exit status and
reports failures; it does not change expected data.
