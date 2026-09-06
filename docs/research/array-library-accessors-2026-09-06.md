# Array declared storage and size accessors

Status: complete and validated. This is a bounded step in the Array migration,
not completion of the remaining collection work.

`Array<T>` now declares its mutable raw backing, count, and capacity fields in
Dew. Their order matches existing Array producers during this transition.
The native fragment planner uses these actual field declarations and no longer
invents three fields for the standard Array declaration number.

`array_length` and `array_capacity` are ordinary Dew functions. Their methods
call these functions. Native operation dispatch and the unused capacity IR and
emitter case are removed. Self-host direct and unresolved method emission must
not replace these bodies with compiler-generated field reads.

Regression checks include ordinary-call lowering, changed declaration layouts,
and a self-host library whose size methods return 42 and 43. The latter must
return 85, not an empty Array's physical length or capacity.

The 13 remaining Array builtins, iterator representation, raw backing checks,
literal construction, and other collection producers still need migration.
No sentinel slot or new backing allocation assumption is introduced here.

## Validation

- Red test: the old native lowering aborts at the explicit library-call check,
  9.600 seconds. The first self-host method-body fixture had an invalid typed-let
  syntax; its parse diagnostic remained visible and the fixture was corrected.
- Native routine lane: 921 tests pass, 124.105 seconds.
- Native integration lane: 266 tests pass, 45.582 seconds.
- Standard library: 319 tests and all shared probes pass, 22.651 seconds. This
  includes the 17 Array, 13 FixedArray, and 14 raw-array cases.
- Self-host hardening: 223 tests, 29 invariant records, and all shared probes
  pass, 47.472 seconds. The changed size-method probe returns 85.
- Generated checks pass, 15.084 seconds.
- Clean bootstrap passes, 159.330 seconds. Compiler B and C raw/linked output
  share SHA-256 `b900f3468bef574e8bfa02c9b0069c9ebd1b25c461e62220da0eb3867712b089`.

The native semantic/backend lanes, integration lane, hardening lane, and
bootstrap exceed 30 seconds. These remain measured performance bugs, not skipped
checks. Stress and full pinned Starshine tests remain scheduled for the end of
the broader migration; this step changes no Starshine provider source.
