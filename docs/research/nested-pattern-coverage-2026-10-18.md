# Bounded finite nested pattern coverage

## Behavior

Both compilers accept a complete match such as:

```dew
enum Bit {
  Zero
  One
}
enum Box {
  Wrap(Bit)
}
fn read(value: Box) -> I32 {
  match value {
    Wrap(Zero) => 0
    Wrap(One) => 1
  }
}
```

The old native checker rejected this program. The old Dew checker accepted a
match containing only `Wrap(Zero)`, because it did not check refutable payloads.
The same defect let a guarded complementary arm hide a missing case.

## Design

The existing fast whole-constructor check remains first. An incomplete check
can use a bounded matrix of source patterns. Each step checks one column:
Boolean values or enum constructors split the rows; products and payloads
supply child columns; open types use only irrefutable default rows. This keeps
field relations intact without building every possible value. Named payloads
align by frozen field names. Constructor identities and inferred applied types
are the same data used by ordinary pattern inference. Guarded rows add no
unconditional coverage. Matches and functional loops use the same check.

The Dew checker now computes whole-pattern and payload irrefutability once per
pattern. Two temporary Boolean tables belong to the body analyzer and are not
retained in its output. A partial nested pattern remains useful until earlier
whole-case coverage proves it redundant.

The matrix counts copied cells, row scans, alternatives, and variant visits.
It permits 65,536 work/cell units and 64 recursive steps. Exceeding either limit
emits `PatternCoverageBudgetExceeded` at the match/loop expression. It does not
produce a normal missing-case witness or treat a truncated check as complete.
Temporary row storage is bounded by the work limit. Common complete matches
keep the fast path. Runtime programs receive no coverage-check code.

General nested redundancy analysis remains conservative. Refutable rest
payload layouts can still need an explicit fallback; ordinary irrefutable rest
patterns keep their existing fast path.

## Validation

The new tests cover complete, missing, and guarded nested enums; Boolean product
field relations; generic applied enums; arm alternatives; functional loops;
reordered named fields; and a valid deep product that reaches the explicit depth
limit. Before the fix, the Dew tests had four failures among the first seven
cases, including the falsely accepted missing/guarded nested cases.

The native flow file passed 36 tests, including the source-valid deep-product
budget case. It took 7.414 seconds; the adjacent JSON diagnostic golden test
passed in 1.737 seconds. The root validation lane will rerun these tests after
the final counter change that charges row scans as well as copied cells.

The Dew flow file passed all 28 tests in 0.084 seconds. Generation took 4.535
seconds and linking took 1.071 seconds. This run includes the final work counter
and the valid depth-limit input. The prebuilt tools wrote only temporary files.

The combined nested-enum and Boolean-product runtime source builds a 1,663-byte
module in 0.154 seconds. Node returns `[0, 1, 10, 10, 20, 30, 1]` for both enum
paths, all four Boolean pairs, and main. The run took 0.027 seconds including
Node startup. The deep valid product is rejected at its match source line with
`PatternCoverageBudgetExceeded(..., 65536, 64, ...)` in 0.177 seconds.

This runtime check exposed a separate native backend demand-walk omission for
product match subjects and loop initial states. Its own fix and tests cover
that planning rule. The Dew backend uses exact typed pair structures instead of
the native erased scalar-box layout. An existing compiler C checkpoint builds
the equivalent wildcard-fallback Boolean-product and I32/I64-loop probe, whose
main checks all cases and returns 42. This confirms the existing emitter path;
a clean bootstrap of the new coverage checker remains in the root validation
lane.

## Time and memory samples

The [measurement harness](data/nested-pattern-coverage-2026-10-18/measure.py),
[raw samples](data/nested-pattern-coverage-2026-10-18/footprint.json), and source
inputs are retained together. Run:

```sh
python3 docs/research/data/nested-pattern-coverage-2026-10-18/measure.py
```

Each case ran three times in a fresh native process with all CLI cache layers
disabled. Linux `wait4` reports the peak resident set for each child. The raw
record includes the native binary SHA-256, HEAD, architecture, platform, exact
commands, output, and samples.

| Input | Median check time | Largest child peak RSS |
| --- | ---: | ---: |
| Simple scalar function | 0.171 s | 26,804 KiB |
| Nested enum and Boolean products | 0.169 s | 26,884 KiB |
| Explicit depth-limit error | 0.170 s | 26,768 KiB |

These figures include the compiler, standard modules, and runtime. They do not
isolate matrix allocations. Three samples under normal host load provide a
small cost envelope for these inputs; they do not establish a speedup or a
before/after memory change. The common fast path is unchanged, and the feature
adds no checks to the emitted user program.
