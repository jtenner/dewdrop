# Cold compiler host build time — 2026-08-25

## Problem

A cold release build of `src/dew_cli` took 94.626 seconds. The generated native C file was approximately 54 MiB and more than one million lines. GCC `-O2` compilation was the dominant stage and exceeded 45 seconds by itself.

## Changes

- The Dew CLI native executable now uses `-Og -pipe` instead of `-O2` for the final generated-C compilation. `-O0` was rejected because linked self-host compiler builds segfaulted. `-Og` preserves correct execution.
- `tools/dew` and the bootstrap child builds limit Moon jobs to eight. On this 8-core/16-thread host, eight jobs reduce memory pressure and outperform the default sixteen-job build.
- Starshine remove-unused-module-elements cleanup now has a standalone `jtenner/starshine/rume` package. Dew's core linker depends on that package instead of the complete Starshine passes, IR, WAST, and filesystem stack.
- Starshine production packages no longer compile files that contain only validator or library tests. Those files now use the `_wbtest.mbt` suffix. Binary fuzz helpers remain in the production package because the Starshine fuzz executable imports them.
- The Starshine FFI generator scopes `moon info` to the `jtenner/starshine` packages and the WasmGC target, so the parent Dew workspace does not enter unrelated backend checks.
- The supported compiler host is now the MoonBit JavaScript release target. It avoids generation and GCC compilation of the approximately 54 MiB native C translation unit.
- `tools/run-dew-cli-host.sh` builds the JavaScript host, then runs Node with a 65,500 KiB stack. The larger stack is required when Starshine encodes the linked self-host compiler.
- The JavaScript cache platform uses temporary-file writes, `fsync`, and atomic rename. Persistent compiler caches therefore retain their native safety and behavior.
- `tools/dew` keeps its small process-launching bootstrap native. `DEW_BOOTSTRAP_TARGET_DIR` and `DEW_HOST_TARGET_DIR` permit exact cold-build measurements without deleting shared build artifacts.

The core linker still runs RUME cleanup. This is required to remove unused provider imports such as `__moonbit_fs_unstable` from linked self-host compiler modules.

## Measurements

All measurements used a new `--target-dir`.

| Build | Time |
|---|---:|
| Original cold release `src/dew_cli` | 94.626 s |
| Without the complete Starshine passes dependency | 88.493 s |
| `-O0` final C compile | 23.658 s total, but runtime-invalid |
| `-Og`, standalone RUME, default 16 jobs | 30.091 s |
| `-Og`, standalone RUME, 8 jobs | 28.623 s |
| Cold JavaScript compiler host build and check | 5.621 s |
| Fully cold `tools/dew check`, including native bootstrap | 8.922 s |
| JavaScript-host self-host compiler A build | 18.380 s |

The supported `tools/dew` path supplies `-j 8` and uses the JavaScript compiler host. The full cold measurement used separate empty target directories for both the bootstrap and compiler host. The normal warm scalar build completed in 0.825 seconds.

## Validation

- `src/core_linker`: 9/9 tests passed.
- Native Dew suite: tokenizer 36/36, parser 283/283, semantic 350/350, backend 46/46, standard loader 16/16, compiler driver 2/2.
- Starshine validator: 1,751/1,751 tests passed.
- Starshine library and binary: 134/134 tests passed.
- Self-host smoke passed after FFI regeneration and carrier-ID remapping. The JavaScript host built compiler A in 18.380 seconds.
- Native and JavaScript compiler hosts emitted byte-identical scalar Wasm with SHA-256 `206e43b04f94a827c768e85f74f89a67cf8c4f3661e8cadb688b7a8cf5b3bfa6`.
- JavaScript cold and warm cache checks reported the expected miss-to-hit transition: parse events 0/15 to 15/0 and standard interfaces 0/3 to 3/0.
