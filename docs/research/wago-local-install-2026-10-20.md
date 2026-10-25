# Local Wago GC stack install

See the [new batch-fix install](wago-native-batch-cancel-2026-10-20.md) for the
current `local-gc-ce9e051d6` build. This note records the prior install.

Installed the existing local GC stack on 2026-10-20 for Linux/amd64.

The later [GC instruction study](wago-gc-instruction-bottlenecks-2026-10-20.md)
finds a large batch cleanup cost in this build. It records the full compiler
checks, a tested batch-size workaround, and the remaining native source-map gaps.

- Source: `/home/dev/Projects/dewdrop/.tmp/wago-local-stack-2026-10-20/wago`
- Branch: `dewdrop/local-gc-perf-20261020`
- Commit: `e2fe43ffc83d31b16c7d82e66dc5a97782db942d`
- The pick plan and ledger each contain 182 entries. No further picks were needed.
- The existing uncommitted change removes one blank line in
  `src/core/compiler/backend/railshot/arm64/call.go`. It was left in place.
- Build tool: `go1.27.1 linux/amd64`, with `CGO_ENABLED=0`.
- Manager: `/home/dev/.local/bin/wago`, already on `PATH`.
- Runtime: `/home/dev/.local/share/wago/versions/local-gc-e2fe43ffc/standard/normal/wago-runtime`.
- Active version: `local-gc-e2fe43ffc`, standard profile, normal Go build.

## Build and selection

These commands built the staged binaries from the working tree:

```sh
cd /home/dev/Projects/dewdrop/.tmp/wago-local-stack-2026-10-20/wago
CGO_ENABLED=0 go build -trimpath -tags wago_runtime -ldflags '-s -w -X main.version=local-gc-e2fe43ffc' -o ../local-install/wago-runtime ./cli/wago
CGO_ENABLED=0 go build -trimpath -ldflags '-s -w -X main.version=local-gc-e2fe43ffc' -o ../local-install/wago ./cli/wago
```

The staged files were copied to the install paths above with mode `0755` and
an atomic rename. Neither install path had an existing binary. Selection used:

```sh
wago version switch local-gc-e2fe43ffc --profile standard --build normal --offline --no-input
```

The manager build took 7.292 seconds. The runtime build took 8.170 seconds.
The two builds overlapped. No source change or commit was needed.

## Checks

- Selected GC tests passed in 18.035 seconds, including Go test compilation.
- Selected tests with `wago_regalloccheck` passed in 14.304 seconds, including
  Go test compilation. These cover large array cancellation, branch casts,
  element drop lifetime, null extern conversions, and open struct allocation
  and reads. No full upstream suite or ARM64 execution run was done.
- A fresh login shell resolves `wago` to `/home/dev/.local/bin/wago`.
- `wago --json --version` reports the local manager and selected runtime.
- The installed command returned `6765` for the checked-in Fibonacci fixture
  with input `20`.
- A small Core 3 module creates a GC struct and array, then returns the sum of
  its struct field and array length. Input `39` returned `42`.
- `wago build` saved that module as a `.wago` artifact. Loading that artifact
  through the installed command also returned `42`.
- Both installed binary hashes match their staged build files.

The CLI checks ran offline from `/tmp`. Each took less than 0.020 seconds.
Their commands, output, and times are stored in
`/home/dev/Projects/dewdrop/.tmp/wago-local-stack-2026-10-20/local-install/verification.json`.
The GC smoke module and native artifact are in the same directory.

## Use

```sh
wago --version
wago run --invoke main /absolute/path/to/module.wasm
```

Use the module's actual export name in place of `main`.
