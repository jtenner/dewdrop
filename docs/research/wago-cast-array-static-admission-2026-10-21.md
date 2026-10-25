# Actual final cast/array-read admission

One diagnostic compile, not a benchmark. Qualification commit
`a13816b55a4551fbb25b53cb44df9262b771da90`, with the combined safety fixes and
production candidate `b6e1e529884a717f31e00659f56ecff0d1bed178`.

The ordinary public Compile API selected the helper, exact-root, inline and
backend options. Configuration was CoreFeaturesV3 plus code-neutral GC telemetry.
A Go overlay captured its completed ModuleStats; no candidate files changed and
no manually reconstructed backend options were used. Diagnostic code was not in
the production host or any timed full-job binary.

Result: **164 actual fusions in156functions**,24,170,827native bytes. The compile
itself took0.512951s; Go build plus test took28.993s. Exact roots passed:
25,794safepoints,56,923callsites,77maximum roots,1,983,045metadata bytes.

The hot `array_get_unchecked#18446462654567415815#16` has one fusion,
942native bytes,3native GC calls and1inlined call. This confirms removal of one
resolver from the old4-call body. Its repeated wrapper resolution remains the
separate guard-certificate opportunity described in
[the proposal](astrawago-trapping-guard-certificate-2026-10-21.md).

Wasm input SHA256:
`c64fcf044b72cb7356ad598a35670045931337cfa7a6bb9d5916cd304b23fba6`.
Native code SHA256:
`ff27c014f7e75052539f34485198fc090e9a766c1e1f7365ff234ea9bc28fc89`.

All affected function rows, byte/frame/spill counts, calls, root metadata, source
hashes and exact command are under
[data/wago-cast-array-static-2026-10-21](data/wago-cast-array-static-2026-10-21/).
`prepare.py <wago-tree>` reconstructs the diagnostic API overlay from that tree;
its source hash must match source.json for this exact capture. It copies api.go
and adds the temporary capture hook/test through Go overlay paths. Set
WAGO_REAL_COMPILER_WASM and WAGO_REAL_COMPILER_STATS before running the command
recorded in run.json. All heavy work stopped after this check. No V8 run was made.
