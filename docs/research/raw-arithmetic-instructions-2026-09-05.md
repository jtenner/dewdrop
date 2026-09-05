# Arithmetic policy belongs to Dew

All 64 I8/U8/I16/U16 arithmetic and comparison functions now have ordinary Dew
bodies. Forty compiler-owned multi-instruction arithmetic sequences were removed.
Narrow masks, sign extension, and logical-width shift masks are library code.
The public operator implementations still call the same library functions.

The full-width declarations now target 66 actual Wasm arithmetic/comparison
instructions. Both compilers have exact operand/result signatures for them. The
three early I32 preamble declarations use the same inventory; the old ad hoc
`i32_add`, `i32_sub`, `i32_lt`, and `i32_lte` backend targets were removed. Parser
and semantic fixtures now name real opcode targets while keeping source function
names independent of those targets.

The numeric backend has 83 single-instruction entries: 66 arithmetic operations
and 17 existing math helpers whose target-spelling migration is still pending.
The compatibility surface contains 1,036 declarations for 655 backend targets.
No replacement compiler-owned narrow arithmetic helper was added.

## Regression design

The policy tests failed on 64 non-library declarations and 40 composite backend
sequences before implementation. Native signature tests compile all 66 valid
opcodes together and check 198 one-cell signature mutations directly at the
verifier. This avoids rebuilding the same preamble for each internal-state
mutation. The self-host separately compiles and rejects all 198 invalid source
declarations before Wasm validation.

An independent BigInt/IEEE arithmetic oracle executes all 148 library functions
in both compilers. Cases cover modular overflow, signedness, logical-width shift
wrapping, division by zero, full-width signed division overflow, signed remainder,
negative zero, NaN, infinity, and float rounding. Narrow signed min/-1 division
retains the existing wrapping result; full-width Wasm signed division traps.

The native fixture harness shares one strict module loader with the scalar and
memory fixtures. Invalid Wasm, absent exports, and unexpected host calls cannot
satisfy an expected execution trap.

## Validation

- 772 native tests and 266 full integration tests passed.
- 296 library tests, 750 scalar conversions, 201 memory checks, and 1,332
  arithmetic checks passed. With the build lock uncontended, the complete library
  lane took 5.913 seconds.
- 106 self-host hardening tests, 16 invariant records, 21 existing emitted
  probes, 72 narrow-float checks, 750 scalar conversions, 201 memory checks, and
  1,332 arithmetic checks passed. The arithmetic matrix took 2.156 seconds.
- The bounded native arithmetic signature test passed in 8.364 seconds including
  the test rebuild. The routine backend lane then passed in 20.513 seconds.
- Generated preamble, numeric emission, compatibility surface, and arithmetic
  policy checks passed.

Running native compiler builds concurrently caused build-lock waits: the earlier
library lane took 172.912 seconds and hardening generation took 127.358 seconds.
These are recorded performance bugs; subsequent compiler lanes run serially.
The earlier repeated-source negative-signature test also made the backend lane
take 51.239 seconds. The one-cell mutation test preserves coverage and removes
that repeated work.

Clean B/C bootstrap passed with identical SHA-256
`50b8a598cd9f7175b7eda49cd5aaa837fd15fac4c07bb685b20db36d42a878bf`.
Compiler A build (36.272 seconds) and self-host compilation still exceed the
30-second performance limit; correctness work on the remaining library families
continues first.
