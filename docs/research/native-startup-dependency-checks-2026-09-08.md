# Checked native startup dependency walks

The startup dependency walk used parallel module/body stacks and silently
skipped missing called bodies. It also skipped missing callable/module lookups
and trusted global candidate indices. A source-derived test changes only a
called body's ID to an absent body. The old walk returns an empty dependency
list, losing its read of a source global. The red focused lane passes one test
and fails that regression (10.328 seconds).

The walk now uses one typed work record per body. It checks module, declaration,
body identity, body kind, all owned syntax arenas, and roots before traversal.
Call-target maps, callable spans/slots, and stored declaration IDs are checked
before access. A known builtin, foreign callable, or bodyless trait declaration
has an explicit no-local-body result; missing metadata is an error. Global
dependencies require a present, bounded, exact candidate lookup. Duplicate
initializer keys cannot overwrite earlier candidates. Recursive calls and
repeated global reads still terminate and produce unique dependency edges.

The common source identity/arena checks are shared with initializer candidate
validation. Generic function bodies are valid for dependency traversal; only
initializer storage requires a concrete root shape. Failures retain all nine
numeric fields, with the call or global-read expression where available.

The first fixed focused lane passes both initial tests (30.782 seconds). A
wider run passes 11 of 13 tests (12.555 seconds); two expected records assumed
one module but the native fixture also includes standard prelude modules. Their
expected bounds now come from the unmodified source arena. The final focused
lane passes all 15 tests (31.605 seconds), including cross-module and recursive
calls. All 268 integration tests pass (61.363 seconds), and the routine native
lane passes 1,248 tests (173.469 seconds). The library passes 326 tests and all
shared corpora (38.713 seconds). Generated checks pass (17.252 seconds).
Hardening passes 632 tests, 270 exact failure records, and all shared corpora
(148.703 seconds). A clean Node bootstrap passes (184.053 seconds); compiler B
and C both have SHA-256
`c2e0ae580b0acdab98876581b6115d4873170909f261f96ce67df337cf603fe2`.

This guards the existing direct-call dependency analysis. It does not add
effect analysis for unresolved indirect calls or runtime trait dispatch, and
it does not close full native global-table verification or link freeze. The
source walk also needs a separate test for a selected generic/query instance
whose template reads a global only in a removed branch. The current walk does
not retain a caller specialization key; bounds checks alone cannot prove that
it visits the correct private IR instance. Cross-module initializer order in
the self-host compiler likewise needs an execution check inside a cyclic module
component. These are follow-up candidates, not failures demonstrated by this
batch. No speed work is included; runs above 30 seconds remain speed bugs.
