# Guest type query safety in the installed stack

PR1010 https://github.com/wago-org/wago/pull/1010 is ready above main.
Public commit0889c2d926bcc07ab8ebd7a46be39269d38af99c is picked locally as
321fae779. The selected PATH install is `local-gc-321fae779` at
`/home/dev/.local/bin/wago`; runtime and manager match that source. All39 CLI
checks pass. Previous5efc install remains available.

GuestStorage.DefinedType now returns detached slice storage using the same
clone helper as ModuleView. The ordinary callback regression proves that
editing a returned query cannot change the live host result requirement. The
wrong type is rejected before native guest execution. The four slices are
Supers, Params, Results and Fields; all nested members and Array are value
fields. Cold metadata queries copy storage; ordinary native reads and the
compiler's emitted code are unchanged. No performance or memory gain claim.

The original-source overlay fails both new regressions. Public complete API
normal/checked22.598/23.875s and checked bench34.416s pass after initializing
the fresh worktree's missing pinned corpora. Combined complete API checks pass
50.864/52.125s. Both binaries relink in about3.03s each; all39 CLI/build/run
checks pass. The user's unrelated ARM64 source edit is preserved.

The separate Exact-flag hypothesis was not reproduced as supported behavior:
the public compiler rejects the exact-reference signature before execution.
That path remains unchanged. The partial draft is preserved privately, not
published as a fix or used to weaken the compiler gate.

The prior combined performance result remains37.817s versus42.821s control
and4.187s V8. That measurement predates the metadata-copy safety repair and is
not a fresh timing claim for321fa. The next type-fact matrix includes this
repair on both sides. Its type-only candidate is still private and uninstalled.

Raw results and installed hashes/checks:
[data/wago-guest-storage-types-2026-10-21](data/wago-guest-storage-types-2026-10-21/installation.json).
