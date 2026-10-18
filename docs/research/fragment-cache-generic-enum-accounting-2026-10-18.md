# Fragment cache accounting for generic enum modules

Date: 2026-10-18

The planning-cache test assumed that only `dew.std.option` needed the
usage-dependent generic enum bypass. The new `Result` methods also introduce
applied `Result` types in signatures. Both enum modules now have observed
program-wide carrier forms and must bypass baseline fragment storage.

The test program loads six modules: `main`, `dew.std.preamble`, `dew.std.option`,
`dew.std.result`, `dew.std.text_runtime`, and `dew.std.wasm.intrinsics`. A temporary
trace found four cold misses, four warm hits, and zero warm misses. The program
context digest was unchanged. Direct post-cold lookups found entries for all
four ordinary modules and no entries for either generic enum module.

The old line-120 failure was the cold miss assertion, not a warm hit assertion.
The cache implementation was correct. The test now names the two expected
bypasses, checks the stored-entry presence for every module, and derives both
cold and warm totals from that set. This adds coverage of which modules are
stored instead of changing only a count. No production cache policy changes.

Diagnostic runs took 4.883 and 5.076 seconds. The final exact-file native test
command was:

```sh
DEW_NATIVE_TEST_PACKAGES='standard_loader/planning_cache_wbtest.mbt' bash tools/test-native.sh
```

All three tests passed in 5.044 seconds. The focused lane took 5.038 seconds.
The [diagnostic trace](data/fragment-cache-generic-enum-accounting-2026-10-18/diagnostic-trace.txt)
and [final record](data/fragment-cache-generic-enum-accounting-2026-10-18/validation.json)
contain the module checks, counts, and command. The trace also records a
failure from a temporary edited copy of the test. That source copy was not
retained, so its failure line cannot be mapped to the baseline test. Inspection
of the baseline source confirms that old line 120 checked cold fragment misses.

The [warm-cost measurement](result-helper-warm-planning-2026-10-18.md) compares
old and new Result source with one pinned CLI and a separate planning timer.
Both confirm five versus four warm fragment hits. The small timing differences
are within the observed noise; no cache policy change was made.
