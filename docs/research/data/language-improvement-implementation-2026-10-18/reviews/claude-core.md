# Review: claude-core scope (`9d86b829` → `fab20ca1`)

I read every changed hunk and every new test in `changes.diff`. This was a read-only review: I made no edits and ran no commands. I did not find a defect in the compiler code. The two confirmed defects are gaps in the performance evidence. There are also six risks that I could not prove.

## Confirmed defects

**D1 — Low. The nested-coverage timing data comes from an old build that was not committed.**
- **File:** `docs/research/data/nested-pattern-coverage-2026-10-18/footprint.json:4` records `head: 6af8898b…`.
- **Evidence:** `.git/logs/HEAD:820-821` shows `6af8898b` is the parent of `bea347a1`. That is before `56e96b48` (the matrix feature), `77d0de5f` (charging metadata scans to the budget) and `73cfa029` (the mutable-field stability check). The measured binary already gives `PatternCoverageBudgetExceeded`, so it came from uncommitted files.
- **Risk:** The times and memory figures in `nested-pattern-coverage-2026-10-18.md` do not describe the reviewed head.
- **Fix:** Build again at head. Run `measure.py` again. Also record `git status --porcelain`, or a hash of the diff, in the record.

**D2 — Low. The F32 timing data does not identify the new source or the generator.**
- **File:** `docs/research/data/f32-midpoint-bounds-2026-10-18/build.py:7` builds "after" from the working-tree `tokenizer.dew`.
- **Evidence:** `samples.json` has only the two Wasm hashes and the Node version. The "after" source, the `dew_test_gen.exe` hash and the build logs are not saved. The tokenizer SHA in the doc comes from a different test run. The "before" source is pinned exactly to `6a881286`.
- **Fix:** Pin "after" to `ee41a4b1` with `git show`, the same way "before" is pinned. Write the source and generator SHA-256 values into `samples.json`.

## Risks I could not prove

1. **Medium. In the Dew compiler, a valid match can fail the budget because of unrelated code.**
   - `semantic_body_flow.dew:1496` (`matrix_enum_variants`) scans all local and all imported variants at each enum step.
   - The native compiler uses owner spans for the same step. Both compilers scan imported variants one by one in `matrix_domain` (Dew line 1542 and after; native `body_flow.mbt:811`).
   - Effect: a large module or many imports can use up the 65,536 units. The same valid match can then pass in the native compiler and fail in Dew.
   - Test to add: a complete match over `(Option<Bit>, Option<Bit>, Option<Bit>)` in a module with about 5,000 unrelated variants. Both compilers must give the same result.

2. **Low (speed). The Dew compiler does extra scans for every imported constructor pattern.**
   - `semantic_body_flow.dew:1393-1416` (`variant_is_only_constructor`) scans all imported variants without a `break`, then calls `enum_variants`, which allocates.
   - This runs for every body, even when the matrix does not run. Nothing measured it.
   - Fix: stop at the first match, and count without allocating.

3. **Low. F32 rounding of very long literals depends on the approximate F64 path.**
   - The Dew compiler returns the approximate value when there are more than 768 digits or the exponent is outside ±400 (`tokenizer.dew:989`). The exponent saturates at 10000 (`tokenizer.dew:1330`).
   - The exact midpoint check runs only when the F64 value equals the midpoint exactly.
   - The long-literal tests only use values near 1.0, where the scale step is exact.
   - Test to add: midpoint neighbours with more than 768 digits near the subnormal range and near the largest finite value. Also `0.<20000 zeros>1…e20001f32`. Compare both compilers.

4. **Low. The Dew compiler may not report flow errors at all.**
   - I found no code under `self_host/` that turns `flow_diagnostics` into a source error.
   - So the new budget error, and the non-exhaustive match errors, may not stop a Dew build. This problem existed before this change.

5. **Low. In the Dew compiler, a match on a value with an error type can give extra errors.**
   - A value with an error type gets the open domain (`semantic_body_flow.dew:464,474`), so it can report a missing catch-all. The native compiler skips coverage for error types.
   - This existed before, but this change edited the same function.

6. **Low. Native type projections are now treated as valid open types.**
   - `BodyMemberTypeProjection` now goes to the open domain (`body_flow.mbt:556`). If an unresolved projection can be an error type, it will now give extra errors.

Two small notes:
- The budget error prints in raw debug form with internal IDs, for example `PatternCoverageBudgetExceeded(5, 65536, 64, 552)`.
- Each nested pair uses about 2 of the 64 depth steps, so the real nesting limit is about 31 pairs.

## What I checked and found correct

- **Operator folding:**
  - The exact opcode, width, signedness and parameter order must match the selected method.
  - The result type must match the operand type, or be Bool for comparisons.
  - The Bool equality proof uses a depth of 16 and allows only pure forms.
  - Methods with coercions, generics or extra statements are not folded.
  - `!=`, `>` and the other operators each select their own trait method, so a "negated equality" method cannot fold to the wrong value.
  - The proof map is built once per program context and is shared.
- **Matrix:** It charges the budget before each read and each growth. A used-up budget stays used up. Guarded rows add no coverage. Mutable fields, guards and String comparisons block the proof. Both production callers pass the imported fields.
- **Product box demand:** It marks only the needed box types. It adds no allocation sites.
- **F32:** The math is correct. The scratch array has 113 digits. The order calculation, separators, overflow to 2^128 and ties-to-even are all correct.
- **String recovery and I/O errors:** Both compilers stop at the closing quote or before a newline. I/O errors are kept.
- **Generated interfaces:** Both `.mbti` files match their source declarations.

## Performance claims

- **F32:**
  - The 24 samples match the table in the doc.
  - They are WasmGC on Node, x86_64 only. Each process makes one call.
  - Heap growth is not an allocation count. RSS is too noisy to show a change.
  - There is no native timing of the midpoint path and no code-size data.
  - The 1.7% figure comes from one fast-path microbenchmark in one process.
- **Nested coverage:**
  - There is no before/after comparison, and the inputs are tiny. RSS is mostly the compiler itself.
  - There is no timing for the worst case that stays under the budget.
  - See D1.
- **Release builds:** The release CLI builds take 26.3–26.9 s, which is close to the 30 s limit.
- I make no claim about the full suites or A/B/C runs.

## Coverage and limits

- I reviewed all 53 files in `scope.json` through the combined diff. I matched hunks to commits by their content, not by `git`.
- `72833b81`, `a747c7c6` and `0eb114c0` belong to other scopes. Only their hunks in `tools/check-generated.sh` and the semantic `.mbti` are here. I checked them: the referenced files exist, and the fields match the source.
- `fab20ca1` touches only files outside this scope.
- **Not done:**
  - I did not run any compiler or test.
  - I did not read `samples.json` row by row for the RSS values.
  - I did not review MoonBit `parse_double`.
  - I did not open the `/tmp` evidence logs.
