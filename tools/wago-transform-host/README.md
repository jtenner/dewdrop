# Pinned transform host

Build with:

```sh
mise exec go@1.27.2 -- python3 tools/build-wago-transform-host.py .tmp/wago-host --test
```

The helper downloads the checksum-verified pinned Wago module, extracts it into a
new private directory, applies `patches/gc-frame-reference-liveness.patch`, runs
the selected reference safety tests, and builds the existing Facet v0.1.0 host.
It saves the build identity next to the executable. It does not change the Go
module cache or a Wago checkout. Temporary build sources stay under
`.tmp/wago-transform-host/` for inspection. `GOWORK=off` avoids the upstream
workspace's nested modules, which Go module archives do not include.

The patch backports the three root-tracking source changes from Wago commit
`14e81db2a9a9e57ef5cba347f93474fdaa151378` to `2dd978ccda6f`. It keeps reference
local types after exact frame liveness removes dead locals. A loaded reference
can still be live on the operand stack. Losing its reference classification can
let collection reclaim that object. The patch preserves the compact safepoint
masks and adds no host API. It excludes the separate upstream direct-getter
optimization, whose source context and API differ at this pin.

The shared footprint test and two runtime test files come from that upstream
repair. Bad-reference tests accept only the exact helper errors used by this
older pin or the specified typed trap; null still requires its typed trap.
The tests cover fresh and serialized native code, small and normal heaps,
decoder tuples, and live loaded child references across collection.

The plan grows from 136 to 160 bytes on 64-bit Go. If compaction removes locals,
the original reference-local array also stays live. Lookup remains binary
search. No ARM64 runtime measurement is available.

The patch hash is part of the native artifact cache identity. A plain `go build`
is labeled `unpatched` and has a separate identity. Use a new absolute
`WAGO_HOME` for each measured compiler run to exclude native code cache reuse.
