# StringBuilder uses the Dew builder storage path

Capacity construction, UTF-8 scalar append, and finish are ordinary Dew
functions. Private typed reference casts share BytesBuilder storage without
copying or resetting consumed state. Scalar encoding rejects surrogates and
values above U+10FFFF. It reserves the entire encoding before writing any
byte and commits the new length after the one-to-four-byte write.

Both compilers have no private text/builder algorithm bodies left. The old
runtime protocol only rejects requests until the legacy physical function
kind and provider bridge are removed. Native fragment planning no longer
classifies any builtin as a text runtime function. Removing the obsolete
protocol and rejecting unknown builtin imports remain separate cleanup work.

The String corpus grows from 35 to 47 checks. Added cases exercise all UTF-8
scalar boundaries at all sixteen destination offsets, returned functions,
zero-capacity growth, invalid scalar limits, consumed aliases, argument order,
and overflowing logical lengths. A malformed empty-storage builder must trap
on overflow before an array write. The test fixture explicitly imports Array
to iterate its scalar table; the initial omitted import was corrected.

Measured checks so far:

- Policy baseline: 13 failures in 0.113 seconds; all three tests pass after
  implementation in 0.049 seconds. The policy also scans every stdlib module
  for remaining `dew_*` algorithm builtin declarations.
- Native baseline: 47 execution checks pass in 0.026 seconds. With the Dew
  implementation, compilation takes 10.265 seconds and execution 0.025 seconds.
- Provider baseline: 19 pass and one expected failure in 6.700 seconds;
  all 20 pass after removal in 7.940 seconds.

The provider commit is `2ca841098`. Its build takes 10.562 seconds and consumer
regeneration takes 4.194 seconds. Public Core signatures remain unchanged;
physical metadata and fingerprints are refreshed.

The full native library lane passes in 45.792 seconds. Self-host hardening
passes 873 tests, 457 exact invariant records, and all shared execution probes
in 97.351 seconds, including 53 Bytes and 47 String cases. Full routine native
passes all 1,289 tests in 302.725 seconds. Runs over 30 seconds remain timing
defects; speed work is deferred.

Integration passes all 270 tests in 92.790 seconds. Generated checks pass in
20.768 seconds. The full provider suite passes all 10,994 tests in 258.898
seconds; stress passes all 15 tests in 0.346 seconds. Clean bootstrap passes
in 189.039 seconds, including core, raw, and final B/C byte comparisons.
Both final compiler hashes are
`c352115f6a299075ffbc6e35bc939c282bf04747ac59b668b274202fdf7e196f`.

This closes the text/Bytes/view/builder algorithm migration row. This change
does not complete the separate Array-literal, physical ABI, shadow-stack,
source-identity, solver, and phase-snapshot audit tasks.
