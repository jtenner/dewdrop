# Raw memory instruction contracts

All scalar and whole-V128 preamble loads and stores now name their exact Wasm
instruction. The shared backend inventory has 16 targets. Signed and unsigned
stores use the same physical instruction instead of duplicate compiler aliases.
Packed carrier helpers remain ordinary Dew functions using equal-carrier casts.

Both compilers verify the address, stored value, and loaded result against the
opcode's physical signature. Linear-memory selection uses the same explicit
target spellings. The migration does not add a compiler-owned runtime algorithm.
Native memory immediates retain memory zero, offset zero, and natural alignment;
the self-host bridge emits the matching single instructions.

## Regression coverage

The new signature test failed before migration because an incorrect raw opcode
signature was accepted. Native tests now cover all 16 valid signatures plus 32
single-field invalid signatures. Self-host tests reject the same 32 invalid
address/value/result signatures before final Wasm validation.

A shared DataView-based oracle executes the actual library memory functions in
both compilers. The 201 checks cover signed and unsigned narrow loads, byte order,
unaligned accesses, scalar and packed carriers, floating values, independent
loads, last-valid addresses, invalid stores and loads, and unaligned V128 copying.
Expected traps apply only to calls on already validated and instantiated modules.
Missing exports or unexpected host calls remain test failures.

The native harness exposed a separate module-name cache bug. That fix is recorded
in `interface-cache-module-origin-2026-09-05.md` and committed separately.

The generated compatibility surface has 1,100 declarations for 732 backend
targets. Legacy vector lane memory helpers, collection storage, host operations,
and other builtin families still require the worklist migration.

## Validation

- 771 native tests and 266 full integration tests passed.
- 296 library tests, 750 scalar conversion checks, and 201 native memory checks
  passed with new and warm interface caches (18.542 and 3.025 seconds).
- 105 self-host hardening tests, 16 invariant records, 21 existing execution
  probes, 72 narrow-float checks, 750 scalar conversion checks, and 201 memory
  checks passed. The memory matrix took 0.011 seconds.
- Preamble, compatibility surface, self-host emission, and memory policy checks
  passed. No old scalar memory target remains in compiler or library source.
- Clean B/C bootstrap passed with identical SHA-256
  `4a5c3e1ff0345910a2a47bd5bc6d81c86b85fae41062f5b939e0e2ba82a3c5a5`.

Cold hardening generation (94.870 seconds), compiler A build (80.328 seconds),
and B/C compilation (64.875/66.332 seconds) remain measured performance bugs.
