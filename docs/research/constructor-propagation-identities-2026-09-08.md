# Exact constructor fields during propagation

The constructor emitter checked field identities, but the body worklist still
matched fields by name when an exact ID was absent or wrong. That could change
carrier evidence before the emitter reported the bad source identity.

The worklist now checks the complete source-to-physical field recipe before
changing any carrier. It uses only exact declaration IDs. Source spans,
physical spans, field counts, and duplicate assignments use the same checked
recipe as emission. The helper records the actual phase: body planning is
phase 6 and direct emission checks are phase 7.

Two source-derived tests change only a field ID, keeping the source name and
value intact. The red lane passed 607 tests and failed those two tests
(70.672 seconds). The existing end-to-end field-ID tests now require phase 6,
since the error is caught before emission. All numeric record fields are
checked. The fixed hardening lane passes 609 tests, 249 exact records, and all
shared probes (76.323 seconds). The library lane passes 326 tests and its shared
probes (29.105 seconds). Generated checks pass (4.599 seconds).

The default bootstrap command reached compiler A but could not find `wago` at
its old machine-specific default path (52.676 seconds). A fresh run with
`tools/check-self-host-bootstrap.sh --clean --fast` passes (212.726 seconds).
Compiler B and C have identical raw and linked SHA-256 hashes:
`9c3ccdef6e42d62e96eb8e50692bc45d5d6e7b410243b18b7d1b334bbfc2deb0`.

Constructor target recovery and retaining the complete constructor recipe in
the frozen body plan remain separate work. This change removes the field-name
fallback; it does not claim to remove the target inference fallback. Runs above
30 seconds remain speed bugs.
