# Self-host capture indices

Name resolution assigns capture references relative to each lambda. Inference
instead subtracted the lambda's global capture-span start from those references,
and checked mutability at the unadjusted global index. The first lambda could
work; later lambdas lost their read types or borrowed another capture's flags.

Inference now indexes its local capture-type array with the relative ID. It adds
the checked span start only when reading the global name-capture arena. A shared
check verifies span bounds, the local type slot, stored capture ID, and lambda
ownership, with ARN-102/ARN-106 numeric context on contract failure.

Two regressions use distinct capture spans and types. The positive form reads
I64 in the first lambda and updates a mutable I32 capture in the second. The
negative form keeps an earlier mutable capture but attempts to write a later
immutable capture; it must report exactly one immutable-assignment diagnostic.

Hardening now passes 118 tests and 21 exact invariant records. All existing
emission and scalar/memory/arithmetic/math matrices pass. Generation took 2.603
seconds, linking 5.035 seconds, and the complete hardening lane 16.377 seconds.

The shared callback source passes inference and now reports two BOD-612 errors.
The verifier finds each lambda by its root body ID and therefore checks its
parent's root expression against the lambda's result. That separate body-identity
defect is the next fix; the differential callback test remains visibly failing.
