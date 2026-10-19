# Portable transform bytecode

The Native and Dew transform engines compile supported source functions to
32-bit instruction words. The low byte is an opcode; the high 24 bits are an
unsigned operand. Exact checked call targets, scalar proofs, and type-read
proofs remain in separate immutable pools. No instruction evaluates arbitrary
source or calls a host function.

Compilation is local to one expansion machine and one checked generic frame.
An unsupported function uses the tree interpreter for its entire body. A failed
compilation is cached within the same bounded cache. This includes functions
that create closures: their existing capture cells and scope rules are retained.
Supported callers can still call such functions through normal checked targets.

The initial instruction set handles scalar literals, local slots, field reads
and writes, checked calls, binary and prefix operations, blocks, conditionals,
short-circuit expressions, return, and functional loops. Binding, wildcard and
literal loop patterns are supported. Loop transfers from guards target the
current loop; a transfer from a nested loop's initial expression still targets
the surrounding loop.

## Bounds

- At most 512 local and temporary slots per compiled function.
- At most 128 expression levels, matching interpretation's depth limit.
- At most 100,000 compiler visits per function and 1,048,576 per machine.
- At most 262,144 words per function.
- A weighted code/pool estimate of at most 1 MiB per function and 8 MiB per
  machine. Cache frame maps and failed entries also consume this budget.

These estimates bound cache construction; they are not measured heap sizes.
Register frames have at most 512 values and the existing call-depth guard.
Logical allocation work remains equal to the tree interpreter within each
engine. A register frame is not charged again as a source-language allocation.
The two compiler engines still differ in some logical resource charges.

## Validation and measurements

Raw logs, samples, build hashes, and private benchmark harnesses are under
`.tmp/transforms-v4/bytecode/`. The first Native run passed 92 interpreter tests
and 54 checked source controls. The Dew suite passed 144 tests. These include
result, logical-work, allocation-work and depth comparisons between backends,
cache exhaustion, compiler-work exhaustion and closure fallback.

The first full Dew run took 30.128 seconds. This exceeds the project's 30-second
limit and remains a performance fault. The aggregate Native source lane took
74.196 seconds; the aggregate Dew lane took 43.324 seconds.

A first alternating-process benchmark used 100 stacked transforms, each with
500 loop iterations. Five measured samples followed one warmup pair. Both
builds produced a validated module whose main returned 1500. Median wall time
was 2.698 seconds for the saved tree build and 2.601 seconds for the bytecode
build. Median process peak RSS was 504,772 and 499,056 KiB. The saved tree build
also predates the loop-guard fix. These small differences do not establish a
clear speed or memory gain, and they do not isolate the backend change.
Further same-build measurements are required before a performance claim.

A second benchmark executes both backends from one Dew test module
(SHA-256 `176f4cdf9875184a19df867ec17d1d158984262b290ab7c3f1391e7d83432219`,
3,507,378 bytes). Each selected test makes 100 calls to the same 500-iteration
integer loop, expects 1500 each time, and resets logical execution limits between
calls. The fixture supplies primitive scalar proofs. The bytecode cache survives
between calls. This tests register execution and proof lookup; it does not
represent all checked scalar-proof shapes, closure fallback, or large functions.

One warmup pair and five measured process pairs alternate tree/code order.
On Node v24.21.0, Linux amd64, median process wall times were 0.168689 and
0.111171 seconds; median user CPU times were 0.196078 and 0.118776 seconds.
Median peak RSS was 80,268 and 78,944 KiB. Each process also includes Wasm engine
startup. This is evidence for this small hot-loop case, not for full compiler
speed or heap allocation. Harness, module identity and every raw sample are in
`.tmp/transforms-v4/bytecode/microbench/`.

A Node CPU profile of the full stacked example found the native source-call
helper hot (69 self samples), ahead of bytecode execution (20). Inspection shows
it scans all file annotations on each source call. The profile also includes
frontend work, JS module loading and GC. It is one profile, not a stable cost
ratio or a before/after measurement. Raw profile and exact JS snapshot are in
`.tmp/transforms-v4/bytecode/profile/`.

The independent source review read all 12 implementation and focused test files.
It found no confirmed result or loop-flow defect, and one discarded Dew local
parameter table. That allocation was removed. Name/field typed normalization
was also moved after expression-depth restoration to match the tree path.
Claude could not review the change because its usage quota was exhausted; no
Claude assessment is claimed. Further exact-boundary tests were prepared after
this review and must pass before the feature is marked complete.


Final boundary validation passed: 93/93 Native interpreter tests in 2.566 seconds
and 13/13 selected Dew bytecode tests in 0.111 seconds (13.653-second generation,
link and execution lane). Tests compare diagnostics, caller depth, work and
allocation counters across 396 combinations of work/allocation/depth boundaries,
including divide-by-zero and literal loop patterns. Dew also checks 513-local
fallback. Logs: `native-final.log` and `dew-final.log` under the same evidence
folder. This follow-up does not repeat or replace the previously recorded full
source suite, public runtime controls, or noisy full-build samples.
