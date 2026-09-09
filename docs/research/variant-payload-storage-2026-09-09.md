# Variant payload storage

The scalar tuple-payload failure below is fixed by the later
[generic enum storage change](generic-enum-payload-storage-2026-09-09.md).
Frozen variant recipes and runtime adapter removal remain open.

## Confirmed generic enum failure

The self-host compiler rejects this ordinary user enum before emission:

```dew
enum GenericPayload<t> {
  Payload(t)
  Empty
}

fn make<t>(value: t) -> GenericPayload<t> {
  GenericPayload::Payload(value)
}

fn read(value: GenericPayload<I64>) -> I64 {
  match value {
    GenericPayload::Payload(value) => value
    GenericPayload::Empty => 0i64
  }
}

pub fn main() -> I64 {
  read(make(42i64))
}
```

Measured against the hardening compiler from `6a452fb`, the source probe takes
0.060 seconds and reports five body-plan errors. The first is BOD-608 at the
match subject: expected `eqref`, actual conflict. The binding has logical I64
type but inherits the physical reference storage carrier. BOD-601 then preserves
the disagreement. This is a real failure, not a successful negative test.

The native compiler has specialized generic enum layouts and compact/erased
adapters. The self-host source fragment has erased declared-generic payload
storage; scalar runtime Option/Result variants use separate adapters. Fixing the
binding carrier alone would leave construction and extraction inconsistent.
The required follow-up includes construction, extraction, nested patterns,
mixed payload positions, Unit erasure, and frozen variant operand recipes.
Do not widen unsafe bitcasts to references or turn missing shapes into Ref.

## Unit storage identity fix

The existing Unit-marker certificate checked the variant ID from the field role
but ignored the field's stored declaration. A one-field mutation therefore
retained a certificate despite contradictory IDs. The certificate now requires
both IDs to agree before checking the source payload span and declared type.
It returns false on disagreement; callers retain their existing mismatch
diagnostic. This does not add generic scalar boxing.

The first test fixture did not retain its unused enum and failed its witness
count. The corrected fixture uses the enum as a function parameter and matches
its payload. It reaches the intended assertion: 702 tests pass and the new
identity test fails before the fix.

The corrected red run takes 72.550 seconds. After the fix, all 703 hardening
tests, all 328 full numeric records, and all shared execution corpora pass
(66.868 seconds). The unused-fixture run took 61.981 seconds; it is not counted
as the intended regression witness. These runs above 30 seconds remain speed
defects. The subsequent nested packed-pattern batch includes this fix in its
passing clean bootstrap (187.826 seconds); B/C raw and linked hashes match
`3554d36c247af3d5c0393219923ccbda5adb158c2900aece9710316a35d024c1`.
