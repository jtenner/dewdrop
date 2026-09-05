# Exact self-host function references

First-class named functions now instantiate their declared signature during
inference and retain the declaration and inferred generic arguments. Lowering
uses an explicit `PlannedFunctionReference`, not a module-global read.

Specialization records the reference in the owning caller specialization's exact
call map. Body planning freezes that selected function, verifies its declaration
identity, and emission uses the frozen index without another name lookup.
Consumed expressions cannot introduce specialization requests.

Syntactic direct-call targets are marked in one linear HIR scan. They retain the
existing call inference path: instantiating them as independent first-class
references created unconstrained requests, including for builtin call targets.
This is a distinction between evaluation roles, not a source-name exception.

Validation: 120 hardening tests and 22 numeric failure records pass. The existing
72 narrow conversion, 750 scalar conversion, 201 memory, 1332 arithmetic, and 238
math checks pass. New executable self-host cases cover scalar, nominal, and
product generic references over six I64 boundary values (18 checks).
The emission-only lane took 3.826 seconds.

The full 66-case callback fixture remains enabled and fails visibly at
`linked lambda captures are not emitted yet`. Captured closure emission is the
next distinct correctness gap; this commit does not claim full callback support
or a clean bootstrap.
