# FixedArray library migration

FixedArray method migration is complete. Its methods already had Dew bodies, but compiler
shortcuts bypassed them. This change removes native inference and lowering
dispatch by declaration ordinal, the native checked-read builder, and self-host
method-name emission shortcuts. Raw Wasm instructions remain distinct operations.

## Regression evidence

- Inserting a declaration before the FixedArray alias broke the old native
  shortcut. The regression now checks three ordinary calls, one indexed read,
  and one indexed write, with no FixedArray library algorithm in the caller IR.
- A self-host library fixture defines `length` to return 42. Before removing the
  shortcut, the emitted program returned the raw array length instead. Removing
  the first shortcut exposed a second Array-length shortcut, which cast the raw
  array to the Array wrapper. Both shortcuts are removed.
- The shared execution fixture checks I64, checked Option results, Unit effects,
  reference values, tuple values, and Unit bounds traps.
- Raw native tuple storage lacked its box/unbox steps. It now uses the same
  product storage adapters as struct fields. Scalars keep scalar backing arrays.
- A self-host raw read inside `Option::Some` used the outer Option result as
  evidence for the array element type. Raw reads must instead use their own
  declared, specialized result type.
- Self-host indexed reads also bypassed their selected method and cast raw
  backing arrays to Array wrappers. All indexed reads now consume the frozen
  call recipe, including erased and non-returning results.
- Native specialization normalization erased packed I8/U8/I16/U16 storage
  identity. These shapes now have distinct structural keys. Their call operands
  remain i32, but their backing arrays and signed reads remain distinct.
  This fixes five stdlib failures in UTF conversion and hash/package code.
- Link tests now check semantic identity and each emitted user signature, not
  fixed indices or a fixed count of preamble type certificates.
- `Some(())` exposed a second erasure issue: the self-host constructor tested
  only physical call results for Unit. Inline raw reads have no such entry.
  Frozen Unit/Never facts now take precedence in emitted-carrier lookup, and
  variant payload scheduling uses that lookup for explicit storage markers.
  Unit stays a zero-operand logical value.

## Measured checks

- Native focused tests: three semantic tests and one backend test passed.
- Self-host method-body red run: 54.908 seconds; expected wrong-result failure.
- First shortcut removal: exposed an illegal Array-wrapper cast.
- Second shortcut removal: method-body probe passed; shared checked-read probe
  exposed an I64/eqref mismatch in `get`.
- Native shared execution: all eight cases passed; generation 7.959 seconds,
  execution 0.022 seconds.
- Final native routine lane: 915 tests passed, 113.151 seconds. All 266
  integration cases passed across the full lane and the corrected backend-file
  rerun (41 tests, 16.170 seconds). The earlier fixed-position test expectations
  failed visibly and were corrected; they were not skipped.
- Final stdlib lane: 319 tests and the shared execution checks passed,
  9.996 seconds. FixedArray now has 13 checks, including tuple writes, checked
  Unit payloads, packed widths, and packed arrays returned through a typed call.
- Final self-host hardening lane: 220 tests, 29 invariant records, existing
  shared probes, and all 13 FixedArray checks passed, 47.201 seconds.
- Generated checks passed, 14.868 seconds. The Array builtin policy has six
  passing tests, including FixedArray library-body and registry checks.
- Clean `tools/check-self-host-bootstrap.sh --clean --fast` passed,
  152.191 seconds. Compiler A built and validated; B passed semantic probes;
  B/C core and linked bytes match. SHA-256:
  `098e2f47f3873e7034e9da83a78d72f0f4543ab50cca5f146b523aa83392a6ab`.
- Self-host hardening runs above 30 seconds remain performance defects. They are
  not skipped or counted as successful until all probes pass.

## Remaining work in this tranche

Complete raw array declaration identity and storage contracts, then move the
remaining Array algorithms into Dew. Full stress and pinned Starshine lanes
remain scheduled for the end of the larger migration tranche.
The registry still identifies the raw WasmArray carrier by its legacy intrinsic
declaration; this commit does not claim to remove every raw-storage shortcut.
