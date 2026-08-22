# Self-host inference trap fixes

Date: 2026-08-22

## Imported method argument trap

Compiler A trapped while `select_imported_method_candidate` passed a nested expression-child lookup directly to `expression_type`. Materializing the child expression ID in a local first produces stable code and preserves the same semantics.

A regression test now selects an imported generic inherent method with one ordinary value argument.

## Missing callable function types

The next trap came from `-1i32` entering local unification. The value decoded to `4294967295u32` inside occurs checking and caused an out-of-bounds access.

The source was unresolved `callable_function_types` slots. `resolve_callable_function_types` used collection iteration plus a separate physical index. Replacing both callable and lambda passes with explicit indexed loops makes every slot deterministic and initialized for the full compiler module.

The local solver now also converts `BodyErrorType`, including the internal `-1i32` sentinel, to its canonical error type before occurs checking. This keeps malformed or missing types diagnostic instead of trapping.

## Validation

- Native tests: 730/730 passed.
- Self-host semantic tests: 226 passed.
- Parser corpus: 640 files passed.
- Semantic corpus: 629 files passed.
- Self-host smoke passed with byte-identical repeated compiler output.

The full bootstrap advances beyond imported method selection and local occurs checking. Its next trap is in body name resolution while converting the complete compiler program, before compiler B is emitted. This is a separate blocker.
