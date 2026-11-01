# Wave 1 wildcard compiler regression

Base: `0b877965`. Worktree: `/data/workspace/wave1-wildcard-fix`.

## Test checkpoint

The unchanged wildcard fixture crashes in the final campaign snapshot log.
Role 53 is the external nominal storage lookup. Signature certification also
uses this lookup after converting a signature value to storage, so role 53
alone does not prove that a struct or closure field owns the bad reference.

The new ordinary-module test has a generic callback record, a callback result
from a separate generic enum module, and an unrelated scalar main. It uses no
standard module names. It checks diagnostics and the full physical invariant.
Implementation is unchanged at this checkpoint. Test results follow below.
