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

The second ordinary-module case places the generic producer in
`callbacks_test.dew`. Production excludes this source's declarations. Its
record captures a generic trait-bound function reference. This separates an
unused source reference from live nominal layout demand. No expected error
or snapshot is changed.

Resource incident: canceling the first lock wait sent SIGTERM to `flock`.
The initial script did not stop on that failure and briefly started a native
build without the lock. The process tree was killed before a test completed.
This is not gate evidence. The script now uses `flock -x 9 || exit $?`.
The restarted gate waits for the same exclusive lock and cleans local build
output on exit. No other worktree output or SDK setting was used.
