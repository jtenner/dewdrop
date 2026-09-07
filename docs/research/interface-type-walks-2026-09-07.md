# Checked interface type walks

Both compilers now check interface type visibility with an explicit work stack.
Each type is unseen, active, or complete. Visiting an active type reports EVD-211;
visiting a complete type reuses the result without treating shared children as a
cycle. No fixed recursion depth can make a public type look private.

Every type ID and child span is checked before access. Failures retain the
module, queried root type, expected and actual values, and detail. The self-host
wrapper writes the numeric record before trapping; native tests check the full
structured failure returned by its checker.

Visibility is accumulated separately from graph validity. A private or Error
child does not stop validation of its siblings and hide a malformed graph.
Member type projections also check their owner's visibility; the old self-host
default case treated them as visible without visiting the owner.

The new 1,025-level self-host test failed on the old depth-limited walker. The
red hardening run took 58.648 seconds and reported that exact assertion failure.
Shared-child, private-owner, projection-owner, cycle, and child-span cases cover
the replacement. Negative cases start from a valid graph and change one node.
Compiler speed work remains excluded.

Measured final checks:

- Three native type-walk tests pass in 8.576 seconds.
- All 964 routine native tests pass in 121.741 seconds.
- All 268 integration tests pass in 48.936 seconds.
- All 293 self-host hardening tests, 63 exact failure records, and the shared
  execution probes pass in 66.897 seconds.
- Generated checks pass in 15.416 seconds.
- The clean bootstrap passes in 157.464 seconds. B/C core and linked bytes
  match. Linked SHA-256:
  `654b22b0310eccf47a2bd9a5c4d54f84a967a1a94471286fff3dbece90911ac8`.

Runs above 30 seconds remain recorded speed defects.
