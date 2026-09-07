# Unit receivers and Never argument prefixes

## Scope

Keep logical receiver evaluation separate from physical call operands. Continue
the correctness audit without speed changes.

## Defects reproduced

- A Unit method receiver passed native execution but failed self-host ABI-707.
  The verifier required a receiver operand even though Unit has no stack value.
- Native and self-host method candidate trials used equality for arguments while
  selected calls used assignment. A Never argument therefore rejected a valid
  candidate before lowering could preserve its non-returning prefix.
- Self-host qualified-call lookup excluded instance methods. Native accepts
  `Type::method(receiver, ...)`; the self-host now checks that same logical list.
- Once selected, a Never argument caused right-aligned physical propagation to
  constrain an earlier reference argument as I64. BOD-601 exposed the conflict.
- The emitter treated a qualified primitive owner as a runtime receiver, even
  though name resolution had certified it as a namespace.

## Changes

The frozen call record retains `receiver_expression` even when it produces no
operand. Verification compares that identity with the selected call syntax and
expects zero operands for Unit. Evaluation scheduling reads the frozen identity,
not the operand list, when it needs to exclude an already scheduled receiver.

Argument propagation starts after the actual implicit receiver's physical slot.
It walks left to right, skips Unit operands, and stops at Never. It no longer
derives that slot by subtracting the argument count from the parameter count.

Candidate trials use the existing assignment relation. Wrong scalar arguments
remain errors. Qualified calls use the full logical parameter list, including
an explicit receiver. Namespace identity prevents a type owner from being
scheduled as a runtime expression.

## Tests

The shared member fixture checks exact effect order for a Unit receiver and
checks that a return in the explicit receiver or a later argument prevents the
method body and later argument effects. Native and imported self-host inference
tests pair valid Never arguments with invalid Bool-to-I64 arguments.

Measured checks pass:

- Native shared fixture compilation: 0.116 seconds; 10 execution checks: 0.022
  seconds.
- `tools/test-self-host-hardening.sh`: 279 tests, 61 exact failure records, and
  all shared execution probes; 36.949 seconds.
- `tools/test-native.sh`: 956 tests; 130.270 seconds. Semantic tests took 80.702
  seconds and backend tests took 37.734 seconds.
- `tools/check-self-host-bootstrap.sh --clean --fast`: clean A/B/C builds pass.
  B/C core and linked SHA-256 both equal
  `1d55b512c0a1de62608e8d0faf93869f71b9a6c84d13dd7c975230836234f772`.
  Compiler A build took 43.395 seconds and A execution took 42.162 seconds.

Earlier failing hardening runs took about 37 seconds; the cold native generator
build took 88.061 seconds. Runs above 30 seconds remain speed defects, outside
this work's scope.

## Still open

This does not complete all call recipes. Indirect calls, hidden operands, product
adapters, full reference types, and complete evaluation-recipe mutation tests
remain in the main audit list.
