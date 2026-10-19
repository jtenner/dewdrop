# Native Wago transform check

The native host check uses Wago commit
`2dd978ccda6fd7955683cc926987b9243cd2bb6e` and released Facet v0.1.0.
Their Go module checksums are in `tools/wago-transform-host/go.sum`. This
Wago commit supports the compiler's 64-field records and 76-value fixed arrays.
The older Facet dependency pin rejects those valid Wasm operations. A current
Wago checkout also needs a Facet callback API change; the check does not use that
unreleased port.

The host loads `facet.Providers()` explicitly. A blank Go import does not load
the provider. It uses the existing `wago-lock.json` bindings. It adds no host
permission. `tools/prepare-wago-compiler.py` replaces unused MoonBit filesystem
and spectest imports with Wasm traps, as the Node test host does. Real Facet
imports stay imports. Defined function indices stay fixed. Named and numbered
import references, direct calls, and legacy table element lists have regression
checks in `tools/test-wago-adapter.py`. A call to an unused import fails visibly.

Run:

```sh
mise exec wasm-tools@1.262.0 -- tools/test-transform-wago.sh .tmp/self-host-bootstrap/a/compiler.wasm
```

The script builds the pinned host, adapts and validates the compiler, creates a
real request, runs the transform in native Wago, validates the output, and checks
`main() = 42`. It removes prior output before execution. The optional CI job is
`.github/workflows/transform-wago.yml`; it needs a Linux x64 project runner with
the `dewdrop` label and the normal Dew toolchain, `mise`, Node, and Bun. The job
runs on the trusted `master` branch or by manual request. It does not run
outside pull request code on the project runner. The job was added locally; no
remote CI run is claimed.

## Measured result and speed defect

The local native host compiled `examples/transforms/local.dew` successfully.
Its output validates, returns 42, and matches the Node output byte for byte.
These measurements used the same compiler and request, with Go 1.27.2 on Linux
amd64. Per-process RSS and exit status are in `.tmp/wago-probe/`.

| Activity | Seconds | Peak RSS, KiB |
| --- | ---: | ---: |
| Serial host module build | 1.774 | 111408 |
| Host module build with eight workers | 0.963 | 142560 |
| Compile, setup, and one trivial export call | 1.693 | 151956 |
| Full native compile request, eight workers | 115.917 | 2461272 |

The full request exceeds the project's 30-second limit. This is an open native
Wago guest speed defect. Parallel host compilation does not fix it. A separate
current-Wago probe took 113.096 seconds and used 2466020 KiB; these single samples
are not isolated benchmark controls and establish no stable gain. A 20-second
CPU sample shows frequent GC record/array helpers and native-to-Go transitions.
It does not name Wasm JIT functions or prove a full-run cost breakdown. Host GC
collection was not a top cost in that sample. Increasing the heap is not a
supported fix from this evidence. The pinned host also cannot reload its own
native image due to `unknown required feature bits 0x100`; the check uses raw
Wasm instead.

The production adapter's two Node/Wasm cases pass in 0.102 seconds. The pinned
production Go host builds with read-only dependency metadata. The complete
native request result above was obtained with the same host source and adapter
rules in the investigation harness. The final production script also passes with compiler B/C fixed-point SHA-256
`e41c19dba06cea722b1eeb263828fa9a991f603fc68a788aaa49d19012dc0aa7`.
Its host build took 0.381 seconds, adapter 3.576 seconds, request packaging
0.121 seconds, native guest execution 114.030 seconds, validation 0.004 seconds,
and result check 0.020 seconds. The output returns 42. This confirms correctness
for the production harness and retains the open guest speed issue. Logs are in
`.tmp/transforms-v3/wago-final.log`. The check covers one local transform,
not the full transform example suite. Exact probe commands, build identities,
raw samples, and profile limits are in `.tmp/wago-probe/RESULTS.md`.
