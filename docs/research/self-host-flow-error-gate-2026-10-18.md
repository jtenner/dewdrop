# Self-host flow error check

The self-host compiler collected flow diagnostics but did not check them before
specialization. Its inference check counted only name, signature, and type
inference errors. Its lowering check did not read `flow_diagnostics`.

## Before the fix

The saved bootstrap compiler C accepted this source, returned status 0, printed
no diagnostic, and wrote a Wasm module:

```dew
pub fn main() -> I32 {
  match false {
    true => 42
  }
}
```

The run took 1.241 seconds. This saved binary is supporting evidence; it is not
a build of the final source. A separate test module built from the current
source also showed the missing check: all four tests failed because lowering
accepted the flow errors.

## Fix

`self_host_validate_program_lowering` now rejects these errors before
specialization:

- A match with a missing case.
- A functional loop with a missing case.
- A pattern coverage budget error.
- A functional loop arm that falls through.

These classes match the native compiler in
`src/semantic/source_diagnostics.mbt`. Redundant pattern arms and unreachable
block items remain warnings and permit lowering. Error text gives the kind,
module ID, expression or arm ID, and source byte offset. The check reads the
existing diagnostic array; it does not copy it or build a report on the normal
path.

## Validation

`self_host/compiler/semantic_flow_diagnostics_test.dew` uses source fixtures for
the missing match case, missing loop case, and loop arm fallthrough. It checks
that each produces the expected flow diagnostic and that lowering rejects it.
The budget test inserts a budget diagnostic into a valid plan. This tests the
error check directly without a large fixture. The same test first inserts both
warning classes and checks that lowering still succeeds. All error tests check
the error text and location fields.

The tests use the existing native test generator and linker. No Moon build was
run. Raw commands, timing, stdout, stderr, source hashes, and the test modules
are saved in:

`/tmp/dewdrop-review-2026-10-18/semantics/flow-error-review/`

The first green run passed all four tests. Generation took 4.708 seconds,
linking took 1.130 seconds, and the test process took 0.064 seconds. These short
runs prove behavior; they do not measure a small runtime or memory change.
The final source also checks error text. Its results are in
`final-generate.json`, `final-link.json`, and `final-run.json`.

A new bootstrap compiler C must still be built and tested by the main task.
