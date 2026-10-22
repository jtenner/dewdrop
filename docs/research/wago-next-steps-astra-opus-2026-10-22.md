# Next GC steps: independent Astra and Claude Opus research

Both requested researchers completed work with high effort:

- Astra: provider `codex`, model `gpt-6-astra`, `reasoningEffort=high`.
- Claude: provider `claudeAgent`, model `claude-opus-5-5`, `effort=high`.

T3 returned the requested identities and settings. Both inspected Wago source at
`44bb8e1bc3b2b175b20600f9870d58d4a1219fef`. The briefing asked them to inspect
source first, then current evidence, and to work independently. Neither changed
compiler/runtime source, built, tested, benchmarked, used the network, or started
more agents. Claude wrote scratch analysis scripts and a WAT print only under
`/tmp/claude-research-scripts`. Parent checked the reported source locations.

This turn delivers recommendations, not an implementation or a new speed result.
The latest qualified job remains 28.581888 seconds, about 7.15 times the target.

## Recommended order

1. **Measure the existing optimizer on the exact pinned compiler Wasm.** Compare
   raw input against Starshine `speed`, with Binaryen `-O3` as a reference arm.
   This changes the compiler Wasm without changing Dew source or Wago. It is the
   first deciding experiment, ahead of building another large analysis pass.

2. **Remove unnecessary work and temporary objects in Dew output.** General
   private enum/aggregate analysis can remove loop `Option` wrappers when their
   identities do not escape. Separately, index imported callables and type keys
   once instead of scanning whole lists repeatedly. This requires a new compiler
   Wasm. Preserve first-match identities, method ordering, duplicate diagnostics,
   iterator behavior, and exact adapters at public/foreign/function-value edges.
   Apply ordinary semantic rules; do not recognize standard functions by name
   or path in the compiler.

3. **Extend Wago value/effect analysis across direct helpers and branch joins.**
   Track returned objects, aliases, escape behavior, and physical clobbers in
   bounded summaries. This can help the identical pinned Wasm and other programs.
   Keep allocation/failure obligations, first-executed traps, exact roots, and
   invalidation at collector/host boundaries. Begin with a diagnostic coverage
   pass before changing emission. Read-only alone does not prove nonescape or
   preserved registers. An internal scalar calling convention is a later use
   of these proofs.

Astra ranks Wago analysis first and Dew indexes second. Claude ranks optimizer
measurement first, Dew output second, and a young-handle redesign third. Parent
chooses the existing optimizer comparison first because it tests a missing
comparison without requiring a new representation or global analysis. Steps 2
and 3 remain hypotheses until dynamic coverage and full-job gains are measured.

## Verified source evidence

- `tools/check-self-host-bootstrap.sh:16,72` defaults the Binaryen lane off and
  validates raw/copied compiler output. Its opt-in path supplies the GC, reference,
  SIMD, bulk, tail-call, and multivalue flags for `-O3 --shrink-level=1`.
- `docs/research/compiler-cli-optimization-2026-09-10.md` documents
  `tools/dew optimize` and the Starshine `speed` schedule. Builds default to
  `--optimize none`. Its performance results concern other generated programs,
  not execution of this pinned self-host compiler. Parent found no saved matched
  optimizer comparison for the current pinned compiler in the examined records.
  This does not prove that nobody has ever run one.
- `self_host/compiler/parser_control.dew:1145` constructs `for` iteration through
  `iter()` and `next()`. `std/array.dew:1410` returns `Some` or `None` per step.
  Existing private carriers and source transformations need broader proof for
  reference and mixed payloads. The earlier zero-match census covers only an
  adjacent scalar-local pattern, not these returned wrappers.
- `self_host/compiler/semantic_impl_index.dew:1412,1432` contains repeated scans
  of imported callables. `semantic_imported_semantics.dew:463,501,542` scans the
  type table in product, applied, and function interning.
- Wago `amd64/gc_read_region.go:105` restricts read regions to small bodies with
  no declared locals. `gc_value_checks.go:130` clears facts at control boundaries.
  `gc_read_call_facts.go:19` supplies a read-only summary separate from register
  clobbers and root masks. It does not encode return provenance or escape facts.

## First experiment and decision gates

Use separate output paths for raw, Starshine `speed`, and Binaryen compiler
artifacts. Keep the pinned request, frozen final host, CPU pinning, GOMAXPROCS,
heap/nursery, disabled transform workers, and cold caches fixed. Do not replace
the installed runtime or the user's changing Facet host.

Validate each optimized input. Compare output Wasm and cache hashes, validate
output, and check `main == 42`. Investigate every mismatch or new trap; do not
update expected bytes blindly. Then run the appropriate native/self-host gates.
Use strict trap semantics and no closed-world identity assumptions.

Measure optimizer time/RSS, cold native compilation, full-job wall/CPU/RSS,
code bytes, and allocation/collection counts in separate diagnostic runs. Treat
an optimizer/compilation activity above 30 seconds as a budget fault. Compare
serial balanced pairs and record every sample. No new runtime cache is required.
Claude proposes a 10% job-RSS allowance and a 10% time gain as a strong first-arm
signal; these are proposed experiment gates, not established user requirements.

A clear gain with correct output makes the optimizer build lane worth adopting.
Flat results should end this experiment and lead to dynamic attribution for
steps 2/3. A difference between Wago and V8 results alone does not identify
per-object GC overhead as the cause. Profile the residual cost before choosing
a collector redesign.

## Important limits and disagreements

The saved V8 matrix uses identical input/request bytes and checked output:
4.001797 seconds default, 23.956034 baseline-only, 7.220931 optimizing-only.
This establishes a large tier/optimization effect within V8. It does **not**
establish a universal 24-second floor for all nonoptimizing engines, nor prove
that all of the Wago/V8 gap comes from missing optimizations. Keep default V8's
four seconds as the target. These are earlier samples, not a fresh same-turn
comparison with Wago 44bb8e1bc.

Claude's native-byte shares are static code-size attribution, not dynamic time.
Its 20–30% allocation-cost estimate is explicitly unmeasured. The saved Go CPU
profile's generated-code category includes real compiler algorithms; it cannot
be treated as removable GC overhead. Astra found no usable native leaf PCs in
that Go profile mapped into the companion code-map images. Fresh native-PC
attribution is needed before making detailed hot-operation claims after the
compact-layout changes.

Young-handle renumbering remains a major representation proposal, not the next
small fix. It needs complete rewriting of stack/register roots, heap fields,
globals, tables, cards, native reservations, host/public references, nested
invocations, and multiple collector domains. Shared zero-field variants likewise
need a proof that identity is unobservable. Neither change is authorized by a
stable virtual backing range alone.

Keep optional Immix/workers disabled by default and do not revive the rejected
address cache or held loop cache without new evidence.

[Requests, model settings, and complete independent reports](data/wago-next-steps-astra-opus-2026-10-22).
