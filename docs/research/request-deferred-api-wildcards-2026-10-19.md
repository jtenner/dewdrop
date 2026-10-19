# Deferred compiler API wildcard imports

The new Dew source-pool loop checks imports before transform preparation adds
`dewdrop.ast` and `dewdrop.transform`. It deferred exact imports of those APIs,
but not a matching wildcard. A transform source that used `open dewdrop.*`
therefore failed with `missing imported module dewdrop.*` when its request had a
nonempty pool. The old empty-pool path let preparation add the APIs first.

Deferred import matching now uses the same descendant wildcard rule as ordinary
module selection. It still considers only the explicit deferred API paths. It
does not fabricate a module, trust source-pool bytes as an API, or defer an
unmatched wildcard. The strict closure after preparation still requires the
actual API modules. Their repeated use still requires exact tracked indices,
file paths, flags, and canonical bytes.

The small resolver regression also checks that strict selection fails before
API injection and that `unknown.*` remains an error. The regression failed
before the fix with the exact missing-module error. Raw evidence is in
`.tmp/request-codec-bounds/wildcard-red.log`; generation took 6.017 seconds and
linking took 1.456 seconds. All seven request tests pass with the fix. Final results are in
`.tmp/request-codec-bounds/wildcard-final.log`; build times are in
`.tmp/request-codec-bounds/wildcard-final-build.log`. The intermediate green
build lacked newly added compiler helper files and did not produce a usable
artifact; its stale-artifact test output is not validation evidence.
