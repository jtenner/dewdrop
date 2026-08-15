# Mutable struct fields

Date: August 15, 2026

## Status

Implemented end to end for local and imported structs, including generic fields.

## Syntax

Struct fields are immutable by default. `mut` is an explicit field modifier:

```dew
struct Box<t> {
  mut value: t
}
```

A field write is a block item:

```dew
box.value = replacement
```

`mut` is not accepted on struct-like enum payload fields. Those payloads remain immutable.

## Semantics

Struct values are references. Assigning a struct value to another binding creates an alias; it does not copy the object. A write through one alias is visible through all aliases.

For `receiver.field = replacement`:

1. `receiver` evaluates exactly once.
2. `replacement` evaluates exactly once.
3. The receiver is written after both values are available.
4. The block item has type `Unit`.

The selected field type constrains the replacement type after generic substitution. Writing an immutable field produces `ImmutableAssignmentTarget`. Unknown fields and non-nominal receivers keep the ordinary field-access diagnostics without an additional mutation cascade.

## Compiler representation

Field mutability is retained in:

- parser `StructField` records and parser-event artifacts;
- collected field records;
- frozen and imported interface fields;
- declaration ABI fingerprints;
- planned type-layout fields and their canonical cache payload;
- WasmGC physical fields.

A mutable generic source field marks every erased physical carrier slot mutable. Closed specializations select the one carrier that matches the replacement value. Unit fields have no physical slot; their receiver and replacement effects are still evaluated in source order.

Lowering uses `PlannedFieldSet(field, receiver, replacement)`. Backend emission selects the final linked owner type and physical field index, restores the exact nominal receiver type when required, and emits `struct.set`.

## Optimization boundary

A mutable field read is not eligible for immutable field common-subexpression elimination. Aggregate scalar replacement is disabled conservatively for modules that declare or use mutable fields. Field writes are non-discardable effects, so effect summaries cannot remove, inline through, or classify a mutating function as total.

This boundary favors correctness for self-hosting compiler state. It can be narrowed later only with explicit alias and effect proofs.

## Validation

Coverage includes:

- parser retention of `mut` and field-assignment block items;
- immutable-write diagnostics;
- generic field type checking and lowering;
- physical mutable-field layout checks;
- optimizer retention of reads and writes;
- alias-visible local runtime mutation across `I32`, `I64`, and reference carriers;
- chained and call-result receivers;
- imported public generic mutable fields;
- deterministic Node and Wago WasmGC snapshots.
