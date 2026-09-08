# Reference instruction identity

Adding two scalar instruction declarations before the existing reference
intrinsics made the generated-source lane reject `NullableRef<t>` in the
standard `ref_is_null` and `ref_as_non_null` declarations. The native compiler
used fixed declaration ordinals 7, 8, and 9 to select these operations.

Type checking now reads the selected declaration's builtin opcode. Lowering
uses an exact declaration-to-operation map built from current source metadata.
The map covers imported modules, standalone modules, and selected compile-time
instances. It is rebuilt after interface-cache loading, as other physical
contracts are. An ordinary function cannot gain intrinsic type permissions
through its name or its position in a file.

The generated operation-ordinal dispatcher and its enum are removed. The
registry generator rejects nonempty ordinal operation tables. Existing nominal
type and standard-trait identity tables remain separate unfinished work.

Tests cover reordered user declarations, imported user builtins, ordinary
same-named functions, nullable foreign values, and invalid nullable type uses.
No speed changes are included.

## Validation

- Initial generated-source failure reproduced the source-order defect.
- The first focused reference run passed seven tests in 11.152 seconds.
- Generated sources and CLI checks passed in 17.857 seconds.
- Expanded reference suite: nine tests passed (11.528 seconds).
- Full native: 1,154 tests passed (168.824 seconds).
- Integration: 268 tests passed (57.860 seconds).
- Library: 326 tests and all shared execution corpora passed (42.437 seconds).
- Self-host hardening: 473 tests, 146 exact error records, and all execution
  corpora passed (149.935 seconds).
- Final generated checks passed (8.883 seconds).
- Clean bootstrap passed (167.524 seconds). B/C core and linked SHA-256:
  `969b9933b45cba2bfcb5c0e63efc2847be09d621fd5b9415c4f92dd0b90274f6`.
- Stress: all 15 tests passed (0.337 seconds).
- The provider is unchanged at `b3542f114`; its last full run passed all 10,994
  tests. Runs over 30 seconds remain speed bugs.
