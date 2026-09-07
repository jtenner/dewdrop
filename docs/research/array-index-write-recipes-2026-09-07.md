# Index writes use the frozen call recipe

The self-host emitter now treats every index write as its selected trait call.
It requires the declaration, exact physical target, and frozen evaluation and
operand recipe. It no longer guesses an Array wrapper from the owner's module,
derives an element carrier late, or invents an array write without a target.

The existing common call path verifies target and operand agreement, evaluates
the source expressions in order, erases Unit operands, and suppresses a call
after a non-returning evaluation. Raw `array.set` remains an explicit Wasm
intrinsic; this change concerns the language's index-assignment expression.

The shared member/index fixture now also checks a non-generic
`IndexedSet<U32, Unit>` implementation. Receiver, index, Unit value, and method
body append separate digits to a trace. Both compilers must produce `1234`, so
each step must run once and in source order. Existing generic Unit, reference,
float, and nested-field cases remain enabled. A source-policy test failed with
the old Array fallback and prevents that second emission route from returning.

Other Array method and literal shortcuts remain separate work. This change does
not claim complete Wasm heap-type/nullability or shadow-stack verification.

## Measured checks

- Array policy: 14 passed, 0.070 seconds.
- Stdlib: 326 tests and all shared corpora passed, 13.879 seconds.
- Self-host hardening: 239 tests, 29 exact failure records, and all shared probes
  passed, 57.540 seconds. Both compilers pass all 10 member/index checks,
  including the new non-generic Unit trace.
- Full native: 944 passed, 103.166 seconds. The semantic package took 71.908
  seconds and the backend took 29.251 seconds.
- Generated sources and CLI fixtures: passed, 3.462 seconds.
- Stress: 15 passed, 0.128 seconds (warm).
- Full pinned Starshine: 10,982 passed, 254.899 seconds. Its expected invalid
  module fixture prints a validation error; the suite reports zero failures.
- Clean bootstrap: passed, 170.591 seconds; B/C core and linked bytes agree.
  A build took 37.865 seconds and A/B execution took 41.995/66.762 seconds.

Linked B/C SHA-256:
`57bf987936d179da715f065bc23e6ab96ae8c90fb8cb5e170e83031f1f651b43`.

Runs above 30 seconds remain performance bugs; no slow tests were skipped.
