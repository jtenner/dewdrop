# Lazy cache owner replacement

## Defect

Warm JavaScript CLI transform builds failed at cache commit with
`artifact pack contains duplicate section owners`. The current failing CLI hash
was `c3e81fa2108f6d7d36d4127f5f8dc74ca7fd918d032f1d8fae6119aac4d94dac`.
The failures included `default_references.dew` and `generic_trait_impl.dew`.

The lazy artifact pack retains old indexed bytes. A compiler phase can store a
new version for an owner, then another phase can request the old content digest.
The old lookup decodes that indexed version and adds it after the new in-memory
entry. Digest-keyed lookup can use both versions. However, materialization copied
both entries into a format that permits only one entry per section and owner.
The old loaded-index test reproduced this order but expected encoding to fail.

This is a cache materialization defect. It is independent of transform frame
context isolation.

## Fix

Materialization now retains the first in-memory entry for each `(kind, owner)`.
This is the same entry that upsert replaces. Older loaded versions remain
available to digest-keyed lookups during the compilation session. Encoding saves
only the current version and preserves entries for unrelated owners.

The materializer still checks the footer and decodes every indexed saved entry,
even when a current entry replaces it. Corrupt saved data therefore remains a
visible error. The format remains version 1. The pass remains linear before its
existing canonical sort. Its output vector has at most as many entries as the
previous copy; this is not a peak-memory measurement.

## Verification

The loaded-index regression now requires a successful encode/decode with the
current owner and no old persisted version. A standard-loader regression covers
store, lookup of an earlier compiler-phase version, another store, and saving
with an unrelated owner retained.

The two regressions failed before the fix (7.909 seconds for the focused lane).
All ten focused cache tests passed after the fix (6.277 seconds), including the test
which checks corrupt indexed data hidden by a replacement. The current JavaScript
CLI rebuilt in 4.409 seconds. No Moon lock wait was reported.

Evidence: `.tmp/transforms-v3/cache-owner-before.log`,
`.tmp/transforms-v3/cache-owner-after.log`,
`.tmp/transforms-v3/cache-owner-js-build.log`, and
`.tmp/transforms-v3/cache-owner/`.

Both public examples passed two serial rounds with caches enabled. All four
compiles completed in 2.347–2.571 seconds, validated with wasm-tools 1.262.0,
and returned `main() = 42` on Node v24.21.0. Each example produced the same Wasm
hash in both rounds. The updated CLI hash was
`1381dd9bb6d90cb88ea4967e9057153badf80a7eb75d21cf19cb2c9da167d23f`.
Exact commands, exits, environment, times, and output hashes are in
`.tmp/transforms-v3/cache-owner/run-public.sh`, `run-public.log`, `identity.txt`,
and `output-hashes.txt`. These are JavaScript-hosted compiler measurements;
no native runtime speed or peak-memory claim is made.
