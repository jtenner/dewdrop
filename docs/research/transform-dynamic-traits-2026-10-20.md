# Dynamic trait values in transforms

The Native interpreter now accepts checked trait values. The Dew interpreter
still needs this path. Keep the full feature unchecked until both pass.

The semantic export reads exact method targets from the ordinary compiler's
trait and generic planner. Logical transform instances do not need a physical
dictionary. Nongeneric conversions can use the ordinary checked dictionary. It exports exact trait requirements, source-order slots,
implementation method declarations, and logical method frames. Symbolic erasure
inside a closed generic instance resolves evidence through that instance's
checked specialization data. The interpreter does not search by method name.

A trait value holds its original receiver and an immutable checked method map.
Two separate conversions have distinct envelope identities. Copies preserve
envelope identity; conversions preserve mutable receiver aliases. Dynamic calls
evaluate the receiver once and ordinary arguments in source order. They require
both the exact requirement and its trait/slot key before calling a source body.
The dictionary's selected method frame retains generic prerequisite evidence.

The tree and bytecode paths use the same construction and dispatch functions.
Construction charges one work step and 40 estimated allocation bytes. This is
allocation-work accounting, not a heap measurement. Proof maps are compiler
metadata shared by values; a conversion does not copy its methods. Bytecode
stores a proof reference and executes one checked conversion instruction.

Evidence export indexes dictionaries by trait and evidence key. Base expression
scans use the existing arena directly rather than allocating an index array.
The existing transform work, allocation, recursion, and bytecode limits remain
in force. Missing or wrong method slots produce a visible transform error.

## Checks

The first source test failed at unsupported checked dispatch before this change.
After implementation, 13 source cases pass. They cover mutable receiver aliases,
scalar values, generic erasure, slot and argument order, explicit returns,
branches, closure captures, generic prerequisites, imports, generic trait
arguments, pure queries, equal reference carriers, and nested returned traits.
Two cases reject generic methods and Self results with `NoMatchingMethod`.

Review found a missing combination: erasure through a generic helper followed
by a query-sensitive implementation. Both scalar and equal-reference tests
failed with `checked dynamic trait call requires a trait value` (12.579 seconds).
The fix retains the exact method declaration with its logical frame and exports
all saved targets in checked trait slot order. It needs no physical dictionary,
second implementation search, or change to a shared physical dictionary. All
13 source tests then passed in 27.348 seconds.

Two VM tests compare tree and bytecode results, exact work and allocation
charges, restored depth, envelope identity, and a rejected wrong slot. The
interpreter lane passes 137 tests. Cache codec, compaction, family merge,
loader admission, generic instances, and method inference have targeted checks.
The full native integration lane passes 272 tests in 17 files (80.899 seconds).
The aggregate run exceeds 30 seconds and remains a performance fault.

The public native example emits valid Wasm and returns 42. The first CLI build
took 31.485 seconds, and a later build took 30.929 seconds. Both are performance
faults. The example request took 1.456 seconds. Evidence is in
`.tmp/transforms-v5/resources/dynamic-traits-*.log`.

## Cost measurements

The private harness uses 256 conversions to a 16-method trait and a matched
direct-call control. Three fresh processes per mode record elapsed time, peak
RSS, exact compiler/source/output hashes, and commands. Cache use is disabled.
All outputs have the same 596-byte Wasm and return 42. Raw samples and the
harness are in `.tmp/transforms-v5/dynamic-traits/benchmark/` and
`.tmp/transforms-v5/resources/dynamic-traits-bench.py`.

Dictionaries and source methods are indexed lazily. Values share an immutable
method map. An exact dictionary key includes every checked target and logical
frame; equal physical carriers alone cannot share a proof. Nongeneric
implementations avoid extra logical type reconstruction.

These samples include correctness changes as well as indexing. They do not
isolate an indexing speed gain. Peak process RSS is not retained proof memory;
it is dominated by source preparation. There is no native ARM64 measurement.

The current self-built Dew compiler rejects the same source example during
ordinary type checking. The red request takes 1.584 seconds. Do not count Native
success as Dew support. Dew needs checked conversions, dynamic method targets,
generic evidence, proof export, and matching VM/resource behavior.

Median request samples (direct/trait) are 1.470/1.470 seconds before the combined
correctness/index changes, 1.513/1.528 seconds after indexing, and 1.702/1.711
seconds with the nongeneric fast path. The matched control slowed too, so these
runs do not establish an absolute improvement. Median peak RSS stays within
213,728–214,556 KiB. Keep the raw samples; do not present these as heap savings.

The final read-only review found no new correctness defect after the generic
erasure fix. It identified an unnecessary empty array on the nongeneric export
path; the exporter now checks for a saved first method before allocating it.
Claude review remains unavailable because its normal account quota is exhausted.

Final native commit checks pass: 137 interpreter tests, 13 source cases, three
trait cache tests, and seven loader cache tests. The aggregate takes 41.836
seconds, a performance fault; each individual lane stays below 30 seconds.
The final scoped interface generation also passes.

The first Dew source test build passes after source-form fixes. Of 12 local
source cases, the two unsafe-method rejection tests pass and ten valid cases
fail in the missing interpreter dispatch/reference path (24.192 seconds total).
This is a visible incomplete feature, not a passing Dew implementation.
