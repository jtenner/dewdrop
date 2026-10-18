# Give the standard reachability fixture a real user call

`physical fragments use specialization reachability` expected the private
standard `Bytes.eq` implementation to remain in physical fragments. Its
fixture only declared a standard trait module and a standard implementation
module. It had no user call to that implementation.

Function planning marks standard callables as compiler-owned and gives them
module visibility. Specialization starts from public user functions and other
non-compiler-owned roots, then follows their calls. An unused private standard
implementation can therefore be elided. This is the intended production rule;
retaining every such body would undo dead-code removal.

The fixture now includes a small `app.consumer` module whose public `same`
function compares two Bytes values. That creates the reachability edge to the
fixture's equality implementation. The assertion still requires that equality
body to remain and the unrelated `dead` body to be elided. The two standard
modules retain both manifest-order cases and their identity assertions.

The saved full-suite module reproduced the failure in 0.155 seconds. The corrected fixture passed both tests in 0.065 seconds. Its test module
compiled in 4.464 seconds and linked in 1.077 seconds.
No production source changed.

Full prebuilt-tool validation passed all 1,344 Dew tests in 1.003 seconds.
Generation took 6.535 seconds and linking took 1.224 seconds. The emitted
short-inference execution check also passed in 0.343 seconds. Exact commands
and captured outputs are in `/tmp/dewdrop-review-2026-10-18/semantics/standard-all-*.json`.
