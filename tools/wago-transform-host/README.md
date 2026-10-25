# Pinned transform host

Build with:

```sh
mise exec go@1.27.2 wasm-tools@1.262.0 -- python3 tools/build-wago-transform-host.py .tmp/wago-host --test
```

The helper downloads the checksum-verified pinned Wago module, extracts it into a
new private directory, applies the local safety patches, runs
the selected reference safety tests, and builds the Facet v0.1.0 host with a
local callback API patch.
It saves the build identity next to the executable. It does not change the Go
module cache or a Wago checkout. Temporary build sources stay under
`.tmp/wago-transform-host/` for inspection. `GOWORK=off` avoids the upstream
workspace's nested modules, which Go module archives do not include.

The host pins Wago `7997c86c36e05cfba4c4f39cabb026a318f55fc0`, fetched from
`origin/main` on 2026-10-20. This includes the AMD64 GC update `7538462db`
and the shared ARM64/AMD64 GC changes `a45a096e7`. The module version is
`v0.1.0-beta.13.0.20261020170030-7997c86c36e0`.

The patch retains the three root-tracking source changes from Wago commit
`14e81db2a9a9e57ef5cba347f93474fdaa151378`. It keeps reference
local types after exact frame liveness removes dead locals. A loaded reference
can still be live on the operand stack. Losing its reference classification can
let collection reclaim that object. The patch preserves the compact safepoint
masks and adds no host API. It does not add a separate direct-getter optimization.

The shared footprint test and two runtime test files come from that upstream
repair. Bad-reference tests accept only the exact helper errors used by this
runtime or the specified typed trap; null still requires its typed trap.
The tests cover fresh and serialized native code, small and normal heaps,
decoder tuples, and live loaded child references across collection.

The plan grows from 136 to 160 bytes on 64-bit Go. If compaction removes locals,
the original reference-local array also stays live. Lookup remains binary
search. No ARM64 runtime measurement is available.

`facet-patches/host-call-api.patch` adapts Facet v0.1.0 to the current Wago
callback API. It uses flat `HostFunc` registration and scoped `Caller`/`HostCall`
callbacks. Facet keeps its internal binding functions; borrowed slot slices are
used only during the callback. The Facet wire format and grants stay the same.
The builder applies this patch to a private checksum-verified Facet copy.

The full Wago and Facet patch-set hash is part of the native artifact cache identity. Use the
build helper: the worker host requires the local `ForkIsolated` API and the
Facet callback patch. Use a new absolute `WAGO_HOME` for each measured cold
compiler run. Reuse that home only when testing native artifact loading.

## Current compiler check

The 2026-10-20 current-main rebuild passes the reference safety tests, worker
race tests, and a real compiler request with a fresh native cache. That request
still reaches a compiler invariant trap when it loads the saved native artifact.
Use a new absolute `WAGO_HOME` for each compiler invocation until that fault is
fixed. This is a known failing check; do not treat it as a warm-cache speed gain.
See the [runtime profile](../../docs/research/wago-runtime-profile-2026-10-20.md)
for exact inputs, status, and measured time and memory use.

## Local worker plugin

The host also registers `dewdrop.local/transform-workers`, version 1.0.0, under
`dewdrop.transform.workers`. Set `DEW_TRANSFORM_WORKERS=2` to enable it; empty or
`0` keeps it off. Other settings are errors. The plugin's production source hash
is part of the native artifact identity, together with the reference patch hash.
The builder copies and hashes the same bytes before it builds.

The plugin uses the local `InstanceManager.ForkIsolated` API to reuse the caller's
compiled module in at most two owned instances. Each instance runs its normal Wasm start function during creation, then
`__dew_transform_worker_run` for each assigned job. Fresh checked plans
and interpreter machines keep application state separate. It loads no other
Wasm payload. It closes and waits for both children on success, trap, or cancel.

Imports are `capacity`, `run_batch`, `input_size`, `input`, and `output`. Messages
use caller-owned mutable i8 arrays. GC handles and array views stay inside their
host storage scope; only copied bytes leave it. Input and output are each bounded
by 32 MiB per batch and 16 MiB per job. At most 64 jobs are accepted. A busy pool
rejects before copying bytes. Children cannot create nested workers. Results and
errors use source order. Output must be published exactly once per job.

Managed-instance grants reserve at most 32 MiB of aggregate linear memory.
`prepare-wago-compiler.py` caps the compiler's private scratch memory at 256 pages.
Managed heaps inherit the caller's GC profile and heap sizes; the linear-memory
grant does not cap these heaps or total process RSS. There is no native ARM64
memory or timing claim.

All wire formats use version 1. Batch requests/results have `DWWB`/`DWWR`, a
little-endian u32 version and count, then length-prefixed byte records. Jobs use
`DWWJ`, version, file index, function index, preamble flag, and a length-prefixed
DWTC source snapshot. Results use `DWWX`, version, and status: 0 with a DWTC source
and report payload, 1 for serial replay, or 2 with an error string. Counts, byte
bounds, checksums, sites, complete input, UTF-8 and function headers are checked.
The codec key is a format marker, not an authentication secret. The fixed compiler
entry point performs ordinary source checks before it evaluates a job.

Run `tools/test-transform-workers.sh COMPILER.wasm HOST` for real serial/worker
requests, output and report equality, and time/RSS samples in a new work directory.
`--test` on the builder runs the upstream root checks and worker tests with the Go
race detector. Tests cover real overlap, separate state, source-error priority,
busy pools, traps, deadlines, pool cleanup, buffer bounds, and publication rules.

## Isolated fork repair

`patches/managed-isolated-fork.patch` adds `ForkIsolated` to the private pinned
Wago source. Ordinary `Fork` keeps its current behavior. An isolated fork keeps
the caller's Runtime ownership, policy, compiled code, plugin hooks, cancellation,
and managed-instance limits. It creates a new private reference store and a new
collector. It rejects reference-valued global imports, and keeps the existing
checks against borrowed memory, tables, globals, and cross-instance functions.
Registered private worker domains can use their own plugin GC arguments; token
validation still uses the active instance's store. No general collector-ownership
check is removed.

This is required by a race found in the worker tests. Ordinary forks of the same
module shared one collector. A host argument check read its handle table while
another worker allocated. The same shared collector also forced guest compute
through the process-wide execution lock. A private store gives each safe worker
its own execution lock under the existing runtime policy. Internal tests check
store/collector identity, compiled-code reuse, independent execution, reference
import rejection, and full close. Plugin race tests retain the triggering case.

The former `cli-module-lifetime.patch` is no longer needed. Current Wago keeps
the CLI module handle alive and closes the instance, module, and Runtime in
that order. The local patch is removed. Public closed-code admission rules
stay unchanged.
