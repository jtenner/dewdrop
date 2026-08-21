# Self-host imported selection

Date: 2026-08-21

The Dew body inferencer now accepts frozen imported semantic recipes without wrapping the large recipe aggregate in `Option`.

Implemented behavior:

- non-generic imported function calls;
- generic imported function signature instantiation;
- exact external call-target identities;
- imported call arity diagnostics;
- zonked imported call type arguments;
- imported generic field selection;
- imported field mutability and identity publication;
- imported unit, tuple, and struct variant construction;
- imported struct construction;
- imported unit, tuple, struct, and struct-variant patterns;
- imported object-field and pattern-field constraints;
- imported generic inherent method selection;
- imported method candidate rollback and deterministic ambiguity handling;
- same-interface imported free-function overload preservation;
- imported overload snapshots, concrete-over-generic ranking, and target publication;
- declaration-owned imported generic parameter spans.

The imported-recipe builder now publishes a deterministic declaration-to-generic-span map. This avoids trying to recover type generic ownership from a nominal type recipe.

A test-generation exit status of 255 was initially mistaken for a backend aggregate failure. It was caused by buffered semantic diagnostics followed by the test generator's deliberate abort. Running the same source through `tools/dew check` exposed the diagnostics. Staging aggregate field reads and using result accessors fixed the compiler-shaped test source.

Focused tests cover non-generic calls, arity failures, generic identity calls, generic imported fields, all imported construction forms, and all imported pattern forms.

Trait bounds, coherence, and selected implementation evidence remain in the next selection tranche.
