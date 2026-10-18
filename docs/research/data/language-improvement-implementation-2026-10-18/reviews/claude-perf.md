# Review: perf/fix range 9d86b82..73cfa02

**Result:** I found no correctness defect in the changed compiler, cache or run-host code. I found 5 small confirmed problems in tests, docs and evidence handling, and 8 risks I could not check. I did not run anything: this review had read-only tools and no shell.

## What I checked in the code

- **Function, type and callable lookups:** I checked that the linker fills each table in order, so slot N holds index N (`semantic_program_link_plan.dew:385`, `:427`). Only one place builds these tables (`:1178-1180`), and nothing later reorders them. The callable owner lookup uses the same pattern as existing code (`semantic_program_specialization.dew:727`). Out-of-range indexes still return the old "missing" value. Failure records are built only on the failure path. No new index is kept.
- **Struct field lookups:** The only two places that create a struct field role also set the matching declaration (`semantic_wasmgc_fragment_plan.dew:311`, `:406`). The `type_layouts.field()` lookup was already used before this change. Tuple, enum payload and synthetic fields still use the old paths.
- **Compiler-owned callables:** I checked one possible problem: compiler-owned callables use module IDs from 4294901760 up. These IDs are the real standard-library modules, so the new lookup still finds them.
- **BLAKE3 range hashing:** The bounds checks cannot overflow. Range hashes match full hashes at offsets 0 and 19, across all official test lengths. Both footer checks now hash in place, with no copy. Their error text is unchanged.
- **`fd_read`:**
  - It checks all guest buffer ranges before it reads any input, including buffers past the 64-view limit.
  - It reads at most 64 views on POSIX and 1 on Windows, with one read per call (plus EINTR retries).
  - The WASI error numbers are correct.

## Confirmed problems

| # | Sev | Where | Trigger and evidence | Risk | Fix or test |
|---|---|---|---|---|---|
| 1 | Low | `docs/research/run-host-input-2026-10-18.md:12-13`, `:20` | The note says "a later host error preserves a successful partial read". The final code does one read and sets the count to 0 on any error (`tools/dew-run.mjs:60-69`). The other note says the same (`run-host-readv-2026-10-18.md`). Line 20 also says "9 tests"; there are now 14. | The two docs contradict each other. | Mark that section as history, or change it to match the final code. |
| 2 | Low | `tools/test-dew-run.mjs:262-270` | The Windows-rule test checks the view count inside a patched `readvSync`. The runner catches that assertion error and returns error 29 (`dew-run.mjs:65-68`). | If the rule breaks, the test fails with a count mismatch (0 instead of 3), not the real cause. This breaks the AGENTS.md rule that failures stay diagnostic. | In the hook, write the view count to stderr and exit with a non-zero code, so the test runner reports it. |
| 3 | Low | `src/cache_binary/artifact_pack_lazy_wbtest.mbt:166-167` | The corrupt-footer test checks only that the result is an error, not which error. | A different error would also pass, so it does not prove the visible digest-mismatch message is kept. | Check for the exact `"artifact pack FOOT digest mismatch"` text in both calls. |
| 4 | Low | The 3 new `self_host/compiler/*index_lookups_test.dew` files | Only `tools/test-self-host-index-lookups.sh:14-17` runs them, and only a research note mentions that script. `test-self-host-hardening.sh:166-243` does not list them. | The ARN-106 guards and the old-vs-new comparisons can break without any routine lane noticing. | Add the 3 files to a routine self-host lane. |
| 5 | Low | `docs/research/data/run-host-readv-2026-10-18/measure.py:63` | Running it again, as the note says to, overwrites the committed `final-rss.json`. | The committed raw evidence is lost. | Add an output path option, or write to a temp file. |

## Risks I could not check

1. **Build records do not match the reviewed commits.** The recorded build commits are `a747c7c`, `f488465` and `6af8898`. The reviewed commits are `e7545e7`, `6af8898` and `ce4e70d`. The field change was measured on an uncommitted tree. Only the file hashes link the samples to the code. To check: compare `git show <commit>:<path> | sha256sum` with the recorded `source_sha256`.
2. **Harness and tool versions changed between runs.**
   - `function-samples.json` has no harness hash; it came from an older harness.
   - The metadata and field runs used different harness versions.
   - The test generator changed between runs (`cc2ab3…` → `325aaf…`).
3. **The BLAKE3 allocation probe has gaps.**
   - Its baseline is `43fd293`, not the review baseline `9d86b82`.
   - It counts only `mi_malloc` and `mi_free`, so its counts are lower bounds.
   - The copy control uses `to_owned()`, not the old `artifact_pack_copy_bytes`.
4. **Some numbers have no committed raw data.**
   - The cache bench process times (5.302 s and the rest) are not in any file.
   - The first run-host note's samples live only in `/tmp/dewdrop-review-2026-10-18/features/run-host-rss.json`. That file matches the table, but it is not committed.
5. **I could not hash the head runner.** I could not check that the claimed final runner hash `d6d545…` matches the committed `dew-run.mjs`. `red.json` also has no runner hash.
6. **EAGAIN behavior is untested.** If stdin is non-blocking, the guest now gets error 6 on each call. The old host failed at startup instead. No test covers this.
7. **The trap tests check only the trap message.** They expect "unreachable" but do not check the failure code or fields. A different invariant trap would also pass.
8. **Two new failure records carry little context.** The out-of-range branch of the new function-slot helper uses a bare code-1 record. The type-slot record sets module and declaration to 0. Production callers check bounds first, so these are only test-reachable.

## What the performance evidence supports

- **Run host:** For a 64 MiB input, peak RSS fell about 80% (304,100 → 60,580 KiB), on Linux x86-64 only. This is process RSS, not counted allocation. The elapsed times include process startup and piping.
- **Cache hashing:** The speed change is in the noise (7.49 vs 7.43 ms). The probe shows the peak requested live bytes fell by 1,048,585 (the 1 MiB copy is gone). This is not RSS.
- **Self-host lookups:** These are query-only timings in Node/V8 on one host. They do not show a whole-compiler gain, and the notes do not claim one. Function queries are about 63–520× faster. The field lookup is about 25× faster at 256 record types, and callable queries are about 7× faster. Heap growth is not an allocation count. RSS stayed about the same. No production code-size or compile-time A/B exists.
- **Not measured:** ARM, native Windows, and native Dew.

I recomputed every median and percentage in the docs from the raw samples. All of them match.

## Coverage

- **Unread:** none. I read every changed source and test hunk, every new test, every required performance input, and both harnesses. I skimmed the large hash lists in the build-identity files and checked the key entries.
- **Not read as text, as instructed:** the excluded fixture `read-stream.wasm`. I used its WAT and hash `1ec057…`.
- **Per-commit coverage:** I had only the combined diff, so I matched hunks to commits by subject.
  - `72833b8`: first `dew-run` change, its tests, and the input note.
  - `d4b976f`: BLAKE3 range, both footer callers, tests, bench and data.
  - `e7545e7`: function slots in `semantic_wasm_body_plan.dew`, its test, harness and script.
  - `6af8898`: type slot and callable lookup, metadata test and data.
  - `ce4e70d`: source field slots, `semantic_type_layouts.dew`, field test and data.
  - `ead14c9`: format only; the visible effect is the `blake3_range` line wrap.
  - `829b8dd`: the `readv` runner, the extra tests, and the readv note and data.

The main open item is risk 1: compare the recorded file hashes with the committed files. After that, fixes 1–5 are small; finding 4 (no routine lane) matters most, because without a lane the new guards can break unnoticed. Your A/B/C and full test runs are still pending.
