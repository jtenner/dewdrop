# Associated trait evidence in generic library queries

Moving Map to Dew exposed a cross-module query gap. A library's unconstrained
generic function could not find a non-foreign implementation declared beside
the nominal type supplied by its caller. The same source worked when the
function and type were in one module.

Both compilers now search the query's visible evidence plus implementations
defined in the trait's and nominal target's modules. Associated searches include
only those modules' own non-foreign, non-test implementations. A type identity
passed to generic code can carry that evidence without exporting its source
name. This is not a global scan of unrelated or foreign extensions. Recursive
prerequisite searches keep the same restriction.

Witnesses retain their owning method index; dispatch no longer reads a witness
span from another module's index. Duplicate sightings of the same declaration
are harmless; different compatible declarations remain an ambiguity error.
All scopes share the active obligation stack and resource budget. Associated
indexes/scopes are cached within a search.

Primitive types have no nominal defining module. Their implementations must
still be visible to the query. Map explicitly imports the String and Bytes
modules for that reason. This dependency is in the separate Map migration.

## Checks

- Native two-module method-call regression: red 10.474 seconds, green 10.051
  seconds; validates the emitted Wasm bytes.
- Three native scope tests pass (9.939 seconds): a module-visible nominal
  implementation, an excluded foreign implementation, and an excluded foreign
  prerequisite.
- The same three cases pass in the self-host hardening suite. All 228 tests,
  invariant records and shared execution probes pass (56.084 seconds).
- Real Map execution passes eight cases in each compiler, including a caller's
  collision-key implementation; the self-host request took 1.860 seconds.

These measurements were made with the pending Map migration in the worktree.
The first cold full run took 108.723 seconds. Both full runs exceed 30 seconds
and remain performance bugs; they were not skipped or hidden.
