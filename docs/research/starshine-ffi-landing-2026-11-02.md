# Starshine FFI landing — 2026-11-02

Adopted the saved function-export builder restoration and modern integer FFI
generator repair. Regenerated the 504 consumer bindings and fingerprint for
Starshine `79e91e5e58effb187e6abb62851ae04d13868fce`.

The strict `tools/check-self-host-bootstrap.sh` FFI contract check passes.
Compiler A builds, links, and validates; its request is built. Execution stops
before the guest starts: locked `github.com/jtenner/wago-facet v0.1.0` tests import
`github.com/wago-org/wago/tests/wasmtest`, which is absent in clean Wago
`90f2b57dafa7f8c3cc7e3aca38b91148f15e1d1e`. `go mod tidy` thus fails while
Wago prepares project plugins. Compiler B, compiler C, fixed-point comparison,
and transform/inference/hardening guest tests were not reached. The landing
brief requires stopping at this runtime provisioning blocker; no source or
lockfile workaround was added.

Built the Wago manager and `wago_runtime` executable from that clean commit.
Installed under `/home/metidos/.wago`; selected with:

```sh
WAGO_HOME=/home/metidos/.wago /home/metidos/.wago/bin/wago version use 0.0.0-fix3-90f2b57da --profile standard --build normal --no-input
```

The runtime binary is at
`/home/metidos/.wago/data/versions/0.0.0-fix3-90f2b57da/standard/normal/wago-runtime`.
The clean source is retained at `/home/metidos/.wago/src`; plugin source builds
can select it with `WAGO_SRC=/home/metidos/.wago/src`. The strict script and
`tools/self-host-common.sh` have no Wago version pin.

Generator tests pass (9/9). The FFI provider build passes. Compiler A source
build takes 37.283 seconds, a performance bug under the 30-second project limit.
The known full native `cmd_gc` package-selection failure was not rerun.

Evidence: `/tmp/starshine-ffi-fix3-evidence-2026-11-02/`.
Partial guest staging: `/tmp/moonbit-guests-staging-2026-11-02/manifest.json`.
Only compiler A and its request are staged. The manifest marks the six remaining
workloads missing; this is not a complete seven-guest handoff.
