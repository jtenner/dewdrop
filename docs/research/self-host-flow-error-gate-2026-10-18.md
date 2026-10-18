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

The final clean bootstrap produced byte-identical compilers B and C. Compiler
C SHA-256 is `e7211b7fa9daf63b820717fe9b8b90ae0fb8668f003e32c1587951941a3e01ab`.
The final source test set passed all 1,371 tests in the main validation lane.

The [repeatable final probe](data/flow-error-gate-2026-10-18/run.py) uses this
fresh C and its matching A request. It preserves the request tail and standard
module sources. Both the original missing Boolean match and a called generic
function with only a guarded wildcard return status 1. Both print
`source flow error: non-exhaustive match` with module, expression, and source
offset. Neither writes an output module. The [record](data/flow-error-gate-2026-10-18/validation.json)
contains commands, compiler/request/source hashes, times, and exact error text.
Run it from the repository root:

```sh
python3 docs/research/data/flow-error-gate-2026-10-18/run.py .tmp/self-host-bootstrap/c/compiler.wasm .tmp/self-host-bootstrap/a/request.bin
```

This probe changes only a temporary compiler copy to export its memory for the
host runner. The record includes both compiler file hashes.
