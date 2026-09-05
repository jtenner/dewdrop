# Self-host lambda link identity

The shared callback source exposed a link-index assertion before emission.
Lambda fragments carried an owner/root ID in the declaration slot and were
inserted into the plain named-function index. A lambda could therefore collide
with a named function or replace it in the body planner's second index.

Linked functions now retain their explicit lambda ID. Named-call lookup,
compatible-target scans, and emitted-target identity checks exclude lambda
entries. The body planner shares the verified plain-function index instead of
building a second map which silently overwrote duplicates.

A genuine duplicate named target now reports LNK-504 with declaration, module,
expected/actual physical indices, and fragment index. The positive regression
places lambdas before and after a named function with the same owner ID; both
indexed and linear lookup must choose only the named function. The negative
regression checks the exact numeric crash record.

The hardening run passed 116 tests and 21 exact invariant records. Existing
emission and scalar/memory/arithmetic/math matrices passed. The new differential
callback matrix remains visibly failing: it now reaches inference, where three
later lambdas incorrectly report assignment to an immutable capture. Investigation
shows that inference uses lambda-relative capture IDs as global arena indices.
That separate capture fix is next, followed by callback emission checks.

Test generation took 97.060 seconds (including the native release rebuild), a
recorded compiler performance bug. The linked hardening run took 111.727 seconds
overall. The callback matrix is not disabled or treated as an expected failure.
