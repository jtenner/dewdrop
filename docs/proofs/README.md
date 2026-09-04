# Dewdrop compiler proofs

This folder contains small proofs for compiler rules that have caused real
self-host failures. It is not a proof of the full language.

## Status words

- **Proved**: a proof tool checked the statement.
- **Checked**: compiler code checks the statement at run time.
- **Tested**: a regression test covers concrete inputs.
- **Open**: the statement is a proof goal. Do not depend on it as a theorem.

## Current proof map

| Rule | Status | Code check | Test or proof |
| --- | --- | --- | --- |
| Arena span bounds | Proved and checked | `compiler_runtime_assertions.dew` | `src/compiler_proofs/span_proofs.mbtp` |
| Unsigned arena index check | Checked and tested; mechanized proof is open | `compiler_runtime_assertions.dew` | `semantic_program_specialization_test.dew` |
| One carrier through lowering | Proved for the abstract carrier model; checked at emission boundaries | `semantic_wasm_body_plan.dew`, `starshine_module.dew` | `src/compiler_proofs/span_proofs.mbtp` |
| Namespace call has no run-time receiver | Checked; formal proof is open | `semantic_program_lowering.dew`, `starshine_module.dew` | `call-namespace.md` |
| Lost zero-arity variant selection has a unique physical recovery | Open; name-only `None` recovery is not a certificate | `starshine_module.dew` | `zero-arity-variant.md` |
| Branch values inherit the `if` result type | Checked; bootstrap test is in progress | `starshine_module.dew` | `branch-expected-type.md` |
| Lost struct nominal has one name-and-field recovery | Checked; bootstrap test is open | `starshine_module.dew` | `struct-constructor.md` |
| Fixed-array get returns the declared element carrier | Checked; bootstrap test is in progress | `starshine_module.dew` | `array-get-carrier.md` |
| Retained static function call returns its declared carrier | Checked; bootstrap test is in progress | `starshine_module.dew` | `function-value-call.md` |
| Match fallthrough arms have one result carrier | Checked; bootstrap test is in progress | `starshine_module.dew` | `match-result-carrier.md` |
| Emitted call stack matches the physical signature | Open; current compiler-B failure | Starshine module validation | `call-namespace.md` |
| Dense type remap keeps valid indices and order | Proved | core linker validation | `src/compiler_proofs/type_remap_proofs.mbtp` |

## Files

- [notation.md](notation.md) defines the symbols used here.
- [call-namespace.md](call-namespace.md) records the call rule that caused the
  2026-09-04 self-host failure.
- [zero-arity-variant.md](zero-arity-variant.md) records the safe recovery rule
  for a lost unit-variant selection.
- [struct-constructor.md](struct-constructor.md) records the unique physical
  struct recovery rule.
- [branch-expected-type.md](branch-expected-type.md) records expected-type
  propagation from an `if` expression to its value-producing branches.
- [array-get-carrier.md](array-get-carrier.md) records why an array object's
  heap type cannot replace the exact carrier of a scalar element read.
- [function-value-call.md](function-value-call.md) records why a broad `ref`
  plan cannot hide a retained static callable's scalar result.
- [match-result-carrier.md](match-result-carrier.md) records the unique carrier
  join for value-producing match arms.
- [runtime-obligations.md](runtime-obligations.md) maps formal conditions to
  compiler assertions.

## Proof lane

Run:

```sh
tools/test-proofs.sh
```

The proof frontend uses mathematical integers. Machine `U32` overflow is not
covered by that model. Keep the matching range assertions in compiler code.
- [Specialization receiver proof](specialization-receiver.md)
