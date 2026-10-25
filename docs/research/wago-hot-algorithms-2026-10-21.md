# Independent hot-path research

User roles: Astra researches implementation proofs; Claude supplies a separate research vector; GPT-6 Sol with explicit Daybreak Blue reviews code before publication.

Both Astra and actual Claude Opus5.5 independently identified repeated complete import-callable scans in `self_host/compiler/semantic_impl_index.dew`: imported-implementation indexing at1432 and imported trait requirement lookup at1412. Source cost includes I*C and M*C where I is imported implementations, M is methods and C is callables. Ordered owner/trait chains built once per indexing call could avoid unrelated callable visits and preserve method/diagnostic order and duplicate identity assertions. Claude also found linear importer interning in semantic_imported_semantics.dew; semantic_resolved_types.dew intern_function is already hashed. These are source observations, not measured invocation totals.

These source changes cannot speed up the hash-pinned existing compiler.wasm. A separate compiler build and benchmark would be required; its V8 time could also change. No source algorithm change is mixed into Wago runtime measurements. No guarantee of4s.

For the same compiler binary, Astra recommends replacing bounded final cast/getter calls with the existing module-shared checked resolver after forwarding. It removes ordinary call root-home/pin-save work and the getter frame, adds no per-caller resolver copies, and retains physical/type checks. Static reach upper bound3910edges/23terminal getters,3409after16site/caller cap; actual admission and runtime gain remain to be measured. The prior per-caller getter lost4.7%, so it is not a control or installed change.

Claude completed read-only research in179.902s, with no edits, builds, tests or subagents. The recorded API model is claude-opus-5-5;30turns, reported cost$0.8118779. Request, model/run metadata and full report are beside this note. Root supplied bounded context and will implement/tests; Claude's concluding request for a decision is advisory and does not create an approval requirement.
