# Math uses explicit Wasm instructions

The 16 floating math declarations now use their actual Wasm instruction targets:
four numeric bit reinterpretations and six unary operations for each float width.
The raw count-trailing-zeros declaration uses `i32.ctz`. Both compilers verify the
17 physical input/result signatures. Every entry in the scalar numeric backend
now names one actual Wasm instruction; the old math/helper target names are gone.

The existing higher-level math algorithms remain ordinary Dew functions. In
particular, min/max keep the first NaN payload and their signed-zero policy;
clamp still rejects NaN or reversed bounds. They are not replaced by Wasm min/max
instructions with different NaN guarantees.

The policy regression failed on all 16 declarations and 17 backend target names
before the change. Native tests compile all 17 correct signatures once and check
34 one-cell invalid input/result mutations. Self-host tests independently compile
and reject all 34 invalid source declarations.

The shared 238-case execution oracle checks the actual library operations:
round-to-even ties, negative zero, infinities, NaNs, exact integer/float bit round
trips, first-NaN min/max payloads, copy-sign payloads, clamp results and traps, and
count-trailing-zeros boundaries. NaN payload checks stay inside Wasm until they
return integer bits, so host float conversion cannot hide a defect.

## Validation

- 773 native tests and 266 full integration tests passed.
- 296 library tests and the scalar (750), memory (201), arithmetic (1,332), and
  math (238) execution matrices passed (15.767 seconds).
- 107 self-host hardening tests, 16 invariant records, 21 existing emitted
  execution probes, 72 narrow-float checks, and all four execution matrices
  passed. The self-host math matrix took 0.036 seconds.
- All generated-source, Facet, and CLI checks passed (10.459 seconds).
- Clean B/C bootstrap passed with identical SHA-256
  `abdca69943967b3512c91a128f6c354a29cce58132f5fd6c4d6057f6ff500497`.

Measured performance bugs remain: cold hardening generation took 92.383 seconds,
compiler A build took 36.679 seconds, and compiler-B generation took 59.876 seconds.
Remaining correctness work takes priority over bootstrap speed.
