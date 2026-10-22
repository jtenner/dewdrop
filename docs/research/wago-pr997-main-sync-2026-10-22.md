# PR 997: resolve the live main conflict

[PR #997](https://github.com/wago-org/wago/pull/997) is maintained in the isolated
checkout `/tmp/wago-pr997-main-sync-20261022`, branch
`dewdrop/pr997-main-sync-20261022`. The merge starts at the exact PR head
`dba9d9670bc2fe1710bd4b83f7c9f70bbbfb1e46` and uses live main
`688303ebfa75384e89773e3fc865b8bccb2e6a71`. The PR API's older base SHA is not
used as the current main ref.

Seven files conflicted. Keep main's RV64 admission, typed native roots, state-only
modules, saved artifact checks, compact extern roots, and same-domain suspended
root traversal. Restore the PR's AMD64/ARM64 extern root plans, bounded fallback,
foreign identity checks, checked table mirrors, saved entry landing slots, and
bounded native caller records. Suspended activations use their supplied owner.
RV64 keeps its own adapter boundary and bridge format; it does not read the
AMD64/ARM64 saved context records. Its transient table publication roots are
unchanged. The strict AMD64 public state footprint is 23,440 bytes, including
34 new pointer words over main's 23,168-byte state.

PR 997 remains a draft with changes required. The existing unused local funcref
table and A-to-B-to-A scalar relay failures remain unresolved. A scalar edge is
not proof that no older same-domain frame exists. This merge does not include
the separate scalar adapter metadata prototype or grant new foreign-frame
traversal authority. Green ordinary tests do not establish the missing proof.
Do not merge or auto-merge the draft based on this maintenance update.

Merge commit `26d272e49f7f36d66034a7afa20b6c472ad06f5c` has both exact refs as
parents. The fast-forward push to `fix/gc-extern-local-roots` was accepted.
No force push or PR merge was made. The worktree is clean. GitHub confirms
the new head, the current main base, no merge conflict, and draft status.

All local checks pass on Go 1.27.1, GOMAXPROCS=2:

| Check | Wall seconds | Peak RSS KiB |
| --- | ---: | ---: |
| AMD64 focused GC/extern/root suite | 27.438 | 3,557,456 |
| Complete ordinary root suite | 160.230 | 2,156,456 |
| Final complete Wago suite | 48.774 | 3,555,676 |
| Complete register-check root suite | 164.779 | 3,589,696 |
| Register-check benchmark module | 30.660 | 778,736 |
| ARM64 focused GC/extern/frame QEMU suite | 26.640 | 2,708,972 |
| Final RV64 GC frame and extern source/artifact QEMU suite | 34.272 | 4,876,032 |
| Final documentation check (85 Markdown files) | 0.058 | 27,412 |

Times include building and linking. The final Wago execution phase is
23.532 seconds; the RV64 execution phase is below one second. The large
cross-target Wago test binaries dominate linking RSS. The long activities
exceed the 30-second target. This maintenance update makes no speed claim.
The checked benchmark module runs correctness tests, not speed comparisons.

The ordinary root run preceded a final RV64-only narrowing of the table
mirror guard. The complete ordinary Wago suite, complete register-check root
suite, and RV64 checks pass after that final change. ARM64 behavior is unchanged
by the added constant architecture guard. Existing tests cover typed roots,
foreign caller records, saved landing slots, null table admission, and RV64
adapter boundaries. No new test or timeout limit was added or weakened.

The pinned Release 3 corpus uses a temporary shared local Git clone, removed
after the root suites. GOWORK is unset; direct tool paths avoid untrusted mise
workspace tasks. All commands, output, CPU time, RSS, faults, and context
switch counts are retained in
[data](data/wago-pr997-main-sync-2026-10-22/identity.json).
The [resolution diff](data/wago-pr997-main-sync-2026-10-22/merge-resolutions.patch)
retains the actual conflict choices. Existing dirty Wago and Dewdrop host
checkouts are untouched. T3 will watch the pushed draft for host check results.
