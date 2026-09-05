# Lambda emission must use its own frozen plan

Named functions and lambdas can share a root body ID and the unspecialized
sentinel. Emission and local allocation previously looked up that pair and could
read the parent's plan. Both now receive the plan selected by the exact linked
physical function index. Initializer lookups retain their named-body identity.

A new executable noncapturing I64 lambda fixture checks all six I64 boundary
values. The function-reference lane now passes 24 checks; 123 hardening tests and
24 numeric records pass. The full lane took 15.878 seconds. Its one remaining
visible failure is the full callback fixture's missing captured closure emission.
