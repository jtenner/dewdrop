# Specialization covers nested lambda bodies

Lambda expression spans are separate from their root function's span. The
specialization worklist now scans every nested lambda once for each owning
function request, retaining the caller's generic shapes and evidence. Calls and
function references inside lambdas therefore get exact call-site records.

Bound trait selection reads the exact lowered expression target. The old path
looked up a parent inference job with a lambda-relative offset, which could read
unrelated evidence. Missing source lambda bodies now store a numeric BOD-610
record. The source-probe harness clears stale crash records before each compile.

Validation: 127 hardening tests, 25 numeric records, 132 focused execution checks,
and all 66 shared callback cases pass. New cases cover a generic call, a generic
function reference, and a trait call inside generic lambdas. Every source probe
reports its case name, and a failed case leaves the lane failing while later
cases still run. No fallback target or skipped callback check was added.
