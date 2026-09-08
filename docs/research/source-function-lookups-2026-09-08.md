# Exact source function lookups

The linked function table already had checked lookup rules. Its module-local
source table still had two gaps: an out-of-range slot could reach an unchecked
array read, and a missing local slot could recover the first matching fragment.
That scan could also select a specialization or lambda instead of a plain
declaration.

The native `PlannedModuleWasmGCFragments::function_of` now uses a checked
lookup. A missing local slot returns None. A present slot must retain the
declaration, plain instance identity, and non-lambda kind. Imported signature
fragments have no local declaration slot; they require one matching plain
record. Zero matches stays missing, and two matches are an explicit SPC-304
failure. A specialization is not an imported plain-function fallback.

Source fragment preflight checks both directions of the lookup table. Every
present slot must point to its own source declaration, and every owned plain
function must retain its slot. These checks run before link reads and again at
the final emission boundary. Failures retain all nine numeric fields; source
checks use phase 5, and native module emission reports phase 7.

The self-host builtin-name lookup had an explicit fallback for malformed plans.
That scan is removed too. Its shared fragment lookup checks module ownership,
the fragment arena, declaration identity, specialization, and lambda kind.
Missing slots remain missing. The existing test that required fallback recovery
now checks a valid lookup first and then requires None after one slot is lost.
Four trap probes also check the complete numeric failure record.

## Tests

The original native missing-entry test failed on the old code (15.848 seconds),
then passed after the checked lookup was connected (13.509 seconds). Seven
native lookup mutations passed (17.234 seconds). Full native integration passed
all 268 cases (90.095 seconds).

The imported fixture initially used the reserved word `trait` in a module path.
That is invalid source, not a lookup regression. The fixture now uses `traits`
and checks all source diagnostics before examining the physical plan. A failed
fixture or an arbitrary trap is not a passing negative test.

The final suite also checks duplicate imported plain fragments, an imported
specialization without a plain record, and the native phase-7 boundary.
All nine focused native lookup tests pass (12.248 seconds).

The first hardening run correctly failed because the new trap-probe file was
not in its explicit test list (209.726 seconds). Its existing 473 tests and
execution corpora passed, but the record checker rejected the missing probes.
The file is now registered; that failed run is not counted as validation of the
four new records.

The registered fixture then exposed a test-only helper that is not part of the
hardening lane (24.455 seconds). The fixture now uses that lane's checked
lowering helper and the ordinary specialization/fragment/link pipeline. A new
normal test also exercises missing builtin lookup in the hardening lane itself.

## Final validation

- Native: 1,201 tests passed (248.091 seconds).
- Integration: all 268 tests passed (72.770 seconds).
- Library: 326 tests and all shared execution corpora passed (52.009 seconds).
- Hardening: 478 tests, 150 exact records, and all shared execution corpora
  passed (110.949 seconds).
- Generated checks passed (31.135 seconds).
- Clean bootstrap passed (199.101 seconds). Compiler B and compiler C have
  identical raw and linked SHA-256 hashes:
  `3e6c1f06a3591d020c1162beb8c0db38bd5a84506efdbe7aebe49aa10b24a62e`.
- Stress: all 15 tests passed (0.376 seconds).

This is source-function lookup work. Full physical plan freeze, late adapter
recipes, and the remaining standard-module identity cleanup remain separate
tasks. Runs above 30 seconds remain speed bugs; this batch has no speed fixes.
