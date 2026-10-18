I found no blocking bugs. The main features work as intended. I found 5 small confirmed issues and 2 unconfirmed risks. I only read files; I did not run any commands or tests.

## Confirmed findings

**F1 — Low — Wrong labels in the failure records**
- **Where:** `docs/research/data/parse-cache-depth-admission-2026-10-18/test-results.txt:6`, `docs/research/parse-cache-depth-admission-2026-10-18.md:43`, `docs/research/fragment-cache-generic-enum-accounting-2026-10-18.md:21` vs `:32-33`.
- **Evidence:** Both parse-cache files say the old line-120 check "expects five hits but observes four". At baseline, line 120 checks cold fragment *misses*. The fragment note says this correctly at line 21. But at lines 32-33 it says the trace shows the old *warm-count* failure. The trace fails at line 140, after the warm step, so it came from an edited copy of the test that is not saved.
- **Risk:** A reader cannot match the evidence to the test.
- **Fix:** Change "hits" to "misses". Save the edited test that made the trace, or remove the warm-count sentence.

**F2 — Low/Medium — Lost warm cache hit, cost not measured**
- **Where:** `src/standard_loader/planning_cache_wbtest.mbt` (diff lines 3405-3431); `fragment-cache-.../validation.json`.
- **Evidence:** The new `Result` methods make `dew.std.result` skip the fragment cache, like `dew.std.option`. Warm fragment hits go from 5 to 4 on this program.
- **Risk:** Every warm build now plans `Result` again. Nobody measured the time. AGENTS.md says to measure all compiler work.
- **Fix:** Measure warm planning time before and after on the same program, and record it.

**F3 — Low — Native privacy tests are weak**
- **Where:** `src/semantic/module_private_fields_wbtest.mbt:28` and `:67`.
- **Evidence:** The tests only check `inferred.diagnostics.length() > 0`. Any unrelated error would also pass. The self-host tests check the exact error kind.
- **Fix:** Check the exact error for each case (`UnknownFieldForType`, `UnknownConstructionField`, `MissingConstructionField`, `UnknownPatternField`). Add a native test: an imported pattern without `...` must give `MissingImportedPatternField`.

**F4 — Low — Old entries stay in the cache pack**
- **Where:** `src/standard_loader/parse_event_cache.mbt:201-204`, `src/cache_binary/artifact_pack.mbt:247`.
- **Evidence:** The pack replaces entries by (kind, owner). Two cases leave old entries behind:
  - A file is edited from shallow to too deep. The store is skipped, so the old shallow entry stays.
  - The owner format changed from `file:` to `file-paths-v1:`. Every old `file:` entry is now orphaned. Nothing in the pack code removes them.
- **Risk:** The pack grows. There are no wrong hits, because lookup also checks the content digest.
- **Fix:** Remove the owner's old entry when the store is skipped. Document or remove the orphaned old entries.

**F5 — Low — Evidence is not saved in the repo**
- **Where:** `module-private-fields-2026-10-18.md` (diff lines 818, 838), `malformed-string-recovery-2026-10-18.md` (diff lines 690, 697, 702-704), `cache-owner-boundaries-2026-10-18.md:76`.
- **Evidence:** The notes point to logs in `.tmp/` and `/tmp/...`, which are not committed.
- **Fix:** Commit small summaries under `docs/research/data/`.

## Unconfirmed risks

**R1 — Medium — Item count limit can still break warm builds**
- The writer has no check for `parse_event_maximum_items` (1,048,576, `src/parser/parse_event_artifact.mbt:11`). The reader rejects larger lists (for example `:964`).
- The source limit is 16 MiB (`src/compile_request/compile_request.mbt:29`). An array literal with more than 1,048,576 elements needs only about 2.1 MiB of source.
- **Possible result:** The cold build passes. The warm build fails with "corrupt parse-event cache pack entry". This is the same kind of fault as the depth bug.
- I did not confirm that the parser accepts a list that long.
- **Test:** A loader test with a list of 1,048,577 items: build cold, then warm.
- **Fix:** Check item counts in the writer, the same way as depth.

**R2 — Low — `tools/check-generated.sh:7` runs a script the diff calls new**
- The diff marks `tools/generate_option_result_std.py` as a new file, but `check-generated.sh` is not in the changed files.
- So either the baseline check was already broken, or the line came from a commit outside this scope. I could not use git to find out.

## Checked and correct
- **Private fields, both compilers:**
  - `private` works as a contextual prefix. A field named `private` stays public.
  - All imported access paths deny private fields: reads, writes, construction (explicit and inferred), and pattern binding. Same-module and cross-file access works.
  - Privacy goes through the parse cache, frozen interface cache, declaration ABI fingerprint, and all four cache key prefixes. All versions stay 1.
  - The self-host compiler has no ABI fingerprint or binary interface codec that would need the flag.
- **JSON:** The checked JSON types (`JsonNumber`, `JsonString`) cannot be forged. Their factory functions still check input. No other `.dew` file uses the helpers that are now hidden.
- **Raw JSON limits:** Raw documents keep and use the caller's limits.
- **Depth:** Every writer depth step matches the reader. Deep trees are not stored. Corrupt stored bytes still give an error.
- **Owner key:** The counted owner key keeps the module/file boundary unique.
- **Generated sources:** Embedded JSON source matches `std/json.dew` declaration by declaration. Spot checks of the math, text, and Option/Result embeddings match key lines.
- **Library math:** Checked conversions and the decimal parser are correct at every limit and offset I traced.
- **Option/Result:** The helpers are plain Dew with no builtin. Each callback runs only on its own branch.
- **No dispatch on std names:** No rule checks a std module name or ordinal.
- **String recovery:** The native lexer recovery keeps the closing quote, the newline, and I/O error priority. The self-host recovery rescan always moves forward.

## Coverage
- **Read:** `instructions.txt`, `scope.json`, `commits.txt`, `files.txt`, and every hunk of `changes.diff`. This includes all new tests, docs, and data files.
- **Generated byte strings:** checked only by declaration lists and key lines, not byte by byte.
- **Not readable:** `/tmp/dewdrop-implementation-2026-10-18/validation/*` and `/tmp/dewdrop-review-2026-10-18/*`. Access was denied.
- **Not read:** the `.tmp/` evidence logs (listed only), `tools/generate_json_std.py`, and `tools/generate_text_iteration_std.py`.
- **Not reviewed:**
  - The string-recovery tokenizer changes are not in the diff. I read `src/tokenizer/lexer.mbt` at its current state instead. I skipped `self_host/compiler/tokenizer.dew` because it has uncommitted changes.
  - Commit `56e96b48` (pattern coverage): only its `docs/spec.md` text. Its source files are not in scope and have uncommitted changes.

## Limits of the measurements
- **Serializer benchmark:** Same process, current version first, then baseline. That order can bias the result. It uses one input: 128 functions, no struct fields, no deep trees. The difference is 0.75 µs (about 1.6%). The build hash is from before formatting. There is no memory (RSS) data. "One small allocation per encode" is a claim from the code, not a measurement.
- **Owner proof:** Uses older pack code (`7ac4abc7`), not the reviewed head. Its times include build time.
- **Privacy memory cost:** One Bool per field. This is a claim from the code; nobody measured it.
- **Option/Result, conversions, parser:** No runtime or code-size data. The notes also claim no gains.

**What to do now:** Fix F1 and F3, and measure F2. Then decide on R1. I suggest adding the item-count check to the writer, because it is the same kind of bug as the depth fix.
