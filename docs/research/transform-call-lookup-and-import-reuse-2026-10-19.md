# Transform lookup cost and import reuse

Baseline: `d09e2d83b1`. Claude's read-only review found repeated generated imports
and repeated source lookup during context construction. The request for a std
map import did build, contrary to the predicted MissingImportedModule; it used
the embedded source fallback. Selected-package correctness is addressed in the
separate loader change and research note.

Both interpreters now cache source function targets after the first lookup.
Checked expression call proofs retain their existing direct target path, and an
unsupported proof cannot use the cache. The cache is shared by applications of a
fixed source plan; only initializer values are reset per application. Context
array construction keeps executing the ordinary checked Dew function body.

Named import aliases are seeded from every original file of the target module.
Repeated generated requests for that alias and path emit no duplicate import.
A conflicting path for an alias produces an explicit error. This also covers
requests from different transformed functions. Imports have module scope. The
Dew declaration renderer now uses the same newline format as the native one.

## Checks

Evidence is under `.tmp/transforms-v3/`. The five native declaration tests pass
in 9.721 seconds, including repeated imports from two target functions with an
existing import. A 5,000-function context test checks repeated type-tree lookup.
The old Dew budget reproduction exhausted 100,000 steps in 1.771 seconds. The
same saved 5,000-function request passed with lookup caching in 3.664 seconds.
The final native compiler checks pass 39/39, with six declaration checks and
three reflection checks. The combined command took 37.563 seconds, so it is a
build-speed defect under the project limit. Direct Dew tests pass 26/26. Source
library generation checks pass, and the full self-host fixed point passes.
